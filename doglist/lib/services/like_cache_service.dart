import 'package:flutter/foundation.dart';
import '../models/cached_like_count.dart';
import '../parameters/env_config.dart';

/// In-memory cache service for dog like counts.
/// Caches expire after a configurable duration (default 5 minutes).
class LikeCacheService {
  static final LikeCacheService _instance = LikeCacheService._internal();
  factory LikeCacheService() => _instance;
  LikeCacheService._internal();

  final Map<String, CachedLikeCount> _cache = {};
  final int _cacheDurationMinutes = EnvConfig.likeCacheDurationMinutes;

  /// Get cached like count for a dog breed.
  /// Returns null if not cached or expired.
  int? getCachedCount(String dogId) {
    final cached = _cache[dogId];
    if (cached == null) return null;
    
    if (cached.isExpired()) {
      _cache.remove(dogId);
      debugPrint('[LikeCacheService] Expired cache for $dogId');
      return null;
    }
    
    return cached.count;
  }

  /// Cache a like count for a dog breed.
  void setCachedCount(String dogId, int count) {
    _cache[dogId] = CachedLikeCount(
      count: count,
      cachedAt: DateTime.now(),
      cacheDurationMinutes: _cacheDurationMinutes,
    );
    debugPrint('[LikeCacheService] Cached $dogId: $count likes');
  }

  /// Cache multiple like counts at once.
  void setCachedCounts(Map<String, int> counts) {
    final now = DateTime.now();
    counts.forEach((dogId, count) {
      _cache[dogId] = CachedLikeCount(
        count: count,
        cachedAt: now,
        cacheDurationMinutes: _cacheDurationMinutes,
      );
    });
    debugPrint('[LikeCacheService] Cached ${counts.length} dog like counts');
  }

  /// Remove a specific dog from cache.
  void removeCached(String dogId) {
    _cache.remove(dogId);
    debugPrint('[LikeCacheService] Removed cache for $dogId');
  }

  /// Clear all cached like counts.
  void clearCache() {
    final size = _cache.length;
    _cache.clear();
    debugPrint('[LikeCacheService] Cleared $size cached entries');
  }

  /// Remove expired entries from cache.
  void clearExpired() {
    final before = _cache.length;
    _cache.removeWhere((key, value) => value.isExpired());
    final removed = before - _cache.length;
    if (removed > 0) {
      debugPrint('[LikeCacheService] Removed $removed expired entries');
    }
  }

  /// Get the number of cached entries.
  int get cacheSize => _cache.length;

  /// Check if a dog breed has a valid cached count.
  bool hasCachedCount(String dogId) {
    final cached = _cache[dogId];
    return cached != null && !cached.isExpired();
  }
}
