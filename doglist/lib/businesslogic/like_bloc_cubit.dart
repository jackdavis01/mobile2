import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../platform/platform_info.dart';
import 'like_bloc_state.dart';
import '../services/like_manager.dart';

class LikeCubit extends Cubit<LikeState> {
  final LikeManager _likeManager = LikeManager();
  bool _hasLoadedAllCounts = false;
  
  // Batching for lazy loading expired counts
  final Set<String> _pendingRefreshDogIds = {};
  Timer? _batchRefreshTimer;
  static const Duration _batchDelay = Duration(milliseconds: 500);

  LikeCubit() : super(LikeState.initial());

  /// Load all like counts from the backend (typically called once on app start)
  Future<void> loadAllLikeCounts() async {
    // Prevent multiple simultaneous loads
    if (_hasLoadedAllCounts || state.isLoading) return;

    // Skip loading all like counts on web to avoid unnecessary API calls
    if (PlatformInfo.isWeb) {
      debugPrint('Running on Web - loadAllLikeCounts is disabled');
      return;
    }

    _hasLoadedAllCounts = true;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final counts = await _likeManager.loadAllLikeCounts();
      emit(state.copyWith(likeCounts: Map.from(counts), isLoading: false));
      
      // Clear any pending batch refresh since we just loaded everything
      _batchRefreshTimer?.cancel();
      _pendingRefreshDogIds.clear();
      debugPrint('[LikeCubit] Loaded all counts (${counts.length}), cleared pending refreshes');
    } catch (e) {
      _hasLoadedAllCounts = false; // Allow retry on error
      emit(state.copyWith(isLoading: false, error: 'FAILED_TO_LOAD_COUNTS'));
    }
  }

  /// Load like counts for specific dogs (uses cache-first strategy)
  Future<void> loadLikeCounts(List<String> dogIds) async {

    if (dogIds.isEmpty) return;

    // Skip loading specific like counts on web to avoid unnecessary API calls
    if (PlatformInfo.isWeb) {
      debugPrint('Running on Web - loadLikeCounts is disabled');
      return;
    }

    debugPrint('[LikeCubit] loadLikeCounts called for: ${dogIds.join(", ")}');

    try {
      final counts = await _likeManager.getLikeCounts(dogIds);
      debugPrint('[LikeCubit] Received ${counts.length} counts from LikeManager');
      final updatedCounts = Map<String, int>.from(state.likeCounts)..addAll(counts);
      emit(state.copyWith(likeCounts: updatedCounts));
    } catch (e) {
      debugPrint('[LikeCubit] Error loading like counts: $e');
      emit(state.copyWith(error: 'FAILED_TO_LOAD_SPECIFIC_COUNTS'));
    }
  }

  /// Like a dog (returns true if successful, false if on cooldown or error)
  Future<bool> likeDog(String dogId) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final response = await _likeManager.likeDog(dogId);

      if (response.success) {
        final updatedCounts = Map<String, int>.from(state.likeCounts);
        updatedCounts[dogId] = response.totalLikes ?? 0;

        final updatedCooldowns = Map<String, DateTime>.from(state.cooldownEndTimes);
        if (response.canLikeAgainAt != null) {
          updatedCooldowns[dogId] = response.canLikeAgainAt!;
        }

        emit(state.copyWith(likeCounts: updatedCounts, cooldownEndTimes: updatedCooldowns, isLoading: false));
        return true;
      } else {
        // User is on cooldown or other error
        if (response.canLikeAgainAt != null) {
          final updatedCooldowns = Map<String, DateTime>.from(state.cooldownEndTimes);
          updatedCooldowns[dogId] = response.canLikeAgainAt!;
          emit(state.copyWith(cooldownEndTimes: updatedCooldowns, isLoading: false, error: response.error));
        } else {
          emit(state.copyWith(isLoading: false, error: response.error ?? 'FAILED_TO_LIKE'));
        }
        return false;
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'UNEXPECTED_ERROR'));
      return false;
    }
  }

  /// Get the like count for a specific dog (from state)
  int getLikeCount(String dogId) {
    return state.likeCounts[dogId] ?? 0;
  }

  /// Check if user has liked this dog (on cooldown)
  Future<bool> isLikedByUser(String dogId) async {
    return await _likeManager.isLikedByUser(dogId);
  }

  /// Get remaining cooldown duration for a dog
  Future<Duration?> getRemainingCooldown(String dogId) async {
    return await _likeManager.getCooldownStream(dogId).first;
  }

  /// Get a stream of cooldown updates (for countdown UI)
  Stream<Duration> getCooldownStream(String dogId) {
    return _likeManager.getCooldownStream(dogId);
  }

  /// Refresh all like counts (force reload from backend)
  Future<void> refreshAllCounts() async {
    _hasLoadedAllCounts = false; // Reset flag to allow reload
    await loadAllLikeCounts();
  }

  /// Clear any error message
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Optimistically increment like count (for immediate UI feedback)
  void incrementLikeCountOptimistically(String dogId) {
    final updatedCounts = Map<String, int>.from(state.likeCounts);
    updatedCounts[dogId] = (updatedCounts[dogId] ?? 0) + 1;
    emit(state.copyWith(likeCounts: updatedCounts));
  }

  /// Revert like count (if API call fails)
  void revertLikeCount(String dogId) {
    final updatedCounts = Map<String, int>.from(state.likeCounts);
    final currentCount = updatedCounts[dogId] ?? 0;
    if (currentCount > 0) {
      updatedCounts[dogId] = currentCount - 1;
      emit(state.copyWith(likeCounts: updatedCounts));
    }
  }

  /// Queue a dog for like count refresh (batched with debounce)
  void queueLikeCountRefresh(String dogId) {
    // Check if already queued to avoid resetting timer unnecessarily
    final bool isNewDog = !_pendingRefreshDogIds.contains(dogId);
    
    _pendingRefreshDogIds.add(dogId);
    
    if (isNewDog) {
      debugPrint('[LikeCubit] Queued $dogId for refresh (total queued: ${_pendingRefreshDogIds.length})');
      
      // Only reset timer if this is a new dog
      _batchRefreshTimer?.cancel();
      _batchRefreshTimer = Timer(_batchDelay, _executeBatchRefresh);
    }
  }

  /// Execute batched refresh for all queued dog IDs
  Future<void> _executeBatchRefresh() async {
    if (_pendingRefreshDogIds.isEmpty) return;
    
    final dogIds = _pendingRefreshDogIds.toList();
    _pendingRefreshDogIds.clear();
    
    debugPrint('[LikeCubit] Executing batch refresh for ${dogIds.length} dogs: ${dogIds.join(", ")}');
    
    // Load counts for the batched dogs
    await loadLikeCounts(dogIds);
  }

  @override
  Future<void> close() {
    _batchRefreshTimer?.cancel();
    return super.close();
  }
}
