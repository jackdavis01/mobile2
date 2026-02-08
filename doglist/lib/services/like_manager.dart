import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/like_response.dart';
import 'like_api_client.dart';
import 'like_cache_service.dart';
import 'like_cooldown_service.dart';
import 'udid_service.dart';

/// Unified facade for dog liking functionality.
/// Coordinates API calls, caching, and cooldown management.
class LikeManager {
  static final LikeManager _instance = LikeManager._internal();
  factory LikeManager() => _instance;
  LikeManager._internal();

  final _apiClient = LikeApiClient();
  final _cacheService = LikeCacheService();
  final _cooldownService = LikeCooldownService();
  final _udidService = UdidService();

  /// Like a dog breed.
  /// Checks cooldown first, then calls API, then updates cache and cooldown.
  Future<LikeResponse> likeDog(String dogId) async {
    // Check cooldown first (local check)
    final canLike = await _cooldownService.canLikeNow(dogId);
    if (!canLike) {
      final remaining = await _cooldownService.getRemainingCooldown(dogId);
      debugPrint('[LikeManager] Cannot like $dogId - cooldown active');
      return LikeResponse(
        success: false,
        error: 'ALREADY_LIKED_TODAY',
        dogId: dogId,
        remainingSeconds: remaining?.inSeconds,
      );
    }

    // Get UDID
    final udid = await _udidService.getUdid();

    // Call API
    debugPrint('[LikeManager] Calling API to like $dogId with UDID: $udid');
    final response = await _apiClient.likeDog(dogId, udid);

    // On success, update cooldown and cache
    if (response.success) {
      await _cooldownService.setLastLikeTime(dogId, DateTime.now().toUtc());
      if (response.totalLikes != null) {
        _cacheService.setCachedCount(dogId, response.totalLikes!);
      }
      debugPrint('[LikeManager] Successfully liked $dogId - total: ${response.totalLikes}');
    } else {
      // If backend says already liked today, update local cooldown service with the data
      if (response.error == 'ALREADY_LIKED_TODAY' && response.canLikeAgainAt != null) {
        // Calculate when the dog was last liked (24 hours before canLikeAgainAt)
        final lastLikeTime = response.canLikeAgainAt!.subtract(const Duration(hours: 24));
        await _cooldownService.setLastLikeTime(dogId, lastLikeTime);
        debugPrint('[LikeManager] Updated local cooldown for $dogId - can like again at: ${response.canLikeAgainAt}');
      }
      debugPrint('[LikeManager] Failed to like $dogId: ${response.error}');
    }

    return response;
  }

  /// Load all dog like counts from the backend.
  /// Updates cache with all results.
  /// Falls back to cached data if API call fails (offline mode).
  Future<Map<String, int>> loadAllLikeCounts() async {
    try {
      debugPrint('[LikeManager] Loading all like counts...');
      final allCounts = await _apiClient.getAllLikes();
      _cacheService.setCachedCounts(allCounts);
      debugPrint('[LikeManager] Loaded ${allCounts.length} like counts from API');
      return allCounts;
    } catch (e) {
      debugPrint('[LikeManager] Error loading all likes: $e');
      // Fall back to cached data (offline mode)
      final cachedCounts = _cacheService.getAllCachedCounts(includeExpired: true);
      debugPrint('[LikeManager] Using ${cachedCounts.length} cached counts (offline mode)');
      return cachedCounts;
    }
  }

  /// Get like counts for specific dog breeds.
  /// Checks cache first, then fetches uncached from API.
  Future<Map<String, int>> getLikeCounts(List<String> dogIds) async {
    final result = <String, int>{};
    final uncachedIds = <String>[];

    // Check cache for each dogId
    for (final dogId in dogIds) {
      final cached = _cacheService.getCachedCount(dogId);
      if (cached != null) {
        result[dogId] = cached;
      } else {
        uncachedIds.add(dogId);
      }
    }

    debugPrint('[LikeManager] Cache hits: ${result.length}, misses: ${uncachedIds.length}');

    // Fetch uncached from API
    if (uncachedIds.isNotEmpty) {
      try {
        final freshCounts = await _apiClient.getBulkLikes(uncachedIds);
        _cacheService.setCachedCounts(freshCounts);
        result.addAll(freshCounts);
        debugPrint('[LikeManager] Fetched ${freshCounts.length} fresh counts from API');
      } catch (e) {
        debugPrint('[LikeManager] Error fetching bulk likes: $e');
        // If bulk fetch fails, fill with zeros
        for (final dogId in uncachedIds) {
          result[dogId] = 0;
        }
      }
    }

    return result;
  }

  /// Get like count for a single dog breed.
  /// Checks cache first, fetches from API if not cached.
  Future<int> getSingleLikeCount(String dogId) async {
    // Check cache first
    final cached = _cacheService.getCachedCount(dogId);
    if (cached != null) {
      debugPrint('[LikeManager] Cache hit for $dogId: $cached');
      return cached;
    }

    // Fetch from API
    try {
      final counts = await _apiClient.getBulkLikes([dogId]);
      final count = counts[dogId] ?? 0;
      _cacheService.setCachedCount(dogId, count);
      debugPrint('[LikeManager] Fetched $dogId from API: $count');
      return count;
    } catch (e) {
      debugPrint('[LikeManager] Error fetching single like count: $e');
      return 0;
    }
  }

  /// Stream that emits countdown updates for a dog's cooldown.
  /// Emits remaining duration every second until cooldown expires.
  Stream<Duration> getCooldownStream(String dogId) async* {
    while (true) {
      final remaining = await _cooldownService.getRemainingCooldown(dogId);
      if (remaining == null || remaining.isNegative) {
        break;
      }
      yield remaining;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// Check if user has already liked this dog today.
  Future<bool> isLikedByUser(String dogId) async {
    return !(await _cooldownService.canLikeNow(dogId));
  }

  /// Get the exact time when user can like this dog again.
  Future<DateTime?> getCooldownEndTime(String dogId) async {
    return await _cooldownService.getCooldownEndTime(dogId);
  }

  /// Clear all cached like counts.
  void clearCache() {
    _cacheService.clearCache();
    debugPrint('[LikeManager] Cache cleared');
  }

  /// Clear all like cooldowns (for testing).
  Future<void> clearAllCooldowns() async {
    await _cooldownService.clearAllCooldowns();
    debugPrint('[LikeManager] All cooldowns cleared');
  }
}
