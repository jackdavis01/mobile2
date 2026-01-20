import 'package:flutter_bloc/flutter_bloc.dart';
import 'like_bloc_state.dart';
import '../services/like_manager.dart';

class LikeCubit extends Cubit<LikeState> {
  final LikeManager _likeManager = LikeManager();
  bool _hasLoadedAllCounts = false;

  LikeCubit() : super(LikeState.initial());

  /// Load all like counts from the backend (typically called once on app start)
  Future<void> loadAllLikeCounts() async {
    // Prevent multiple simultaneous loads
    if (_hasLoadedAllCounts || state.isLoading) return;
    
    _hasLoadedAllCounts = true;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final counts = await _likeManager.loadAllLikeCounts();
      emit(state.copyWith(
        likeCounts: Map.from(counts),
        isLoading: false,
      ));
    } catch (e) {
      _hasLoadedAllCounts = false; // Allow retry on error
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load like counts: $e',
      ));
    }
  }

  /// Load like counts for specific dogs (uses cache-first strategy)
  Future<void> loadLikeCounts(List<String> dogIds) async {
    if (dogIds.isEmpty) return;

    try {
      final counts = await _likeManager.getLikeCounts(dogIds);
      final updatedCounts = Map<String, int>.from(state.likeCounts)..addAll(counts);
      emit(state.copyWith(likeCounts: updatedCounts));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to load specific like counts: $e',
      ));
    }
  }

  /// Like a dog (returns true if successful, false if on cooldown or error)
  Future<bool> likeDog(String dogId) async {
    emit(state.copyWith(clearError: true));
    
    try {
      final response = await _likeManager.likeDog(dogId);
      
      if (response.success) {
        final updatedCounts = Map<String, int>.from(state.likeCounts);
        updatedCounts[dogId] = response.totalLikes ?? 0;
        
        final updatedCooldowns = Map<String, DateTime>.from(state.cooldownEndTimes);
        if (response.canLikeAgainAt != null) {
          updatedCooldowns[dogId] = response.canLikeAgainAt!;
        }
        
        emit(state.copyWith(
          likeCounts: updatedCounts,
          cooldownEndTimes: updatedCooldowns,
        ));
        return true;
      } else {
        // User is on cooldown or other error
        if (response.canLikeAgainAt != null) {
          final updatedCooldowns = Map<String, DateTime>.from(state.cooldownEndTimes);
          updatedCooldowns[dogId] = response.canLikeAgainAt!;
          emit(state.copyWith(cooldownEndTimes: updatedCooldowns));
        }
        return false;
      }
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to like dog: $e',
      ));
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
}
