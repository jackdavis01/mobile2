import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cached_like_count.dart';
import '../parameters/env_config.dart';

/// Persistent cache service for dog like counts using SharedPreferences.
/// Caches expire after a configurable duration (default 5 minutes).
/// Data persists across app restarts, showing stale data when offline.
class LikeCacheService {
  static final LikeCacheService _instance = LikeCacheService._internal();
  factory LikeCacheService() => _instance;
  LikeCacheService._internal();

  final Map<String, CachedLikeCount> _cache = {};
  final int _cacheDurationMinutes = EnvConfig.likeCacheDurationMinutes;
  
  /// Maximum cache size to prevent memory issues (209 dog breeds)
  static const int _maxCacheSize = 500;
  
  /// SharedPreferences storage key
  static const String _storageKey = 'like_cache_v1';
  
  /// Flag to track if service has been initialized
  bool _isInitialized = false;
  SharedPreferences? _prefs;
  
  /// Initialize the service by loading cached data from SharedPreferences.
  /// Must be called before using other methods.
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadFromStorage();
      _isInitialized = true;
      debugPrint('[LikeCacheService] Initialized with ${_cache.length} cached entries');
    } catch (e) {
      debugPrint('[LikeCacheService] Error initializing: $e');
      _isInitialized = true; // Mark as initialized even on error to prevent blocking
    }
  }
  
  /// Load cached data from SharedPreferences.
  Future<void> _loadFromStorage() async {
    try {
      final jsonString = _prefs?.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        debugPrint('[LikeCacheService] No cached data found in storage');
        return;
      }
      
      final Map<String, dynamic> data = jsonDecode(jsonString);
      _cache.clear();
      
      data.forEach((dogId, entry) {
        try {
          final map = entry as Map<String, dynamic>;
          final count = map['count'] as int;
          final cachedAtMs = map['cachedAtMs'] as int;
          
          _cache[dogId] = CachedLikeCount(
            count: count,
            cachedAt: DateTime.fromMillisecondsSinceEpoch(cachedAtMs),
            cacheDurationMinutes: _cacheDurationMinutes,
          );
        } catch (e) {
          debugPrint('[LikeCacheService] Error parsing entry for $dogId: $e');
        }
      });
      
      debugPrint('[LikeCacheService] Loaded ${_cache.length} entries from storage');
    } catch (e) {
      debugPrint('[LikeCacheService] Error loading from storage: $e');
    }
  }
  
  /// Save the entire cache to SharedPreferences.
  Future<void> _saveToStorage() async {
    if (_prefs == null) return;
    
    try {
      final Map<String, dynamic> data = {};
      
      _cache.forEach((dogId, cached) {
        data[dogId] = {
          'count': cached.count,
          'cachedAtMs': cached.cachedAt.millisecondsSinceEpoch,
        };
      });
      
      final jsonString = jsonEncode(data);
      await _prefs!.setString(_storageKey, jsonString);
      debugPrint('[LikeCacheService] Saved ${_cache.length} entries to storage');
    } catch (e) {
      debugPrint('[LikeCacheService] Error saving to storage: $e');
    }
  }

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
    _cleanupIfNeeded();
    _cache[dogId] = CachedLikeCount(
      count: count,
      cachedAt: DateTime.now(),
      cacheDurationMinutes: _cacheDurationMinutes,
    );
    debugPrint('[LikeCacheService] Cached $dogId: $count likes');
    _saveToStorage(); // Persist to storage
  }

  /// Cache multiple like counts at once.
  void setCachedCounts(Map<String, int> counts) {
    _cleanupIfNeeded();
    final now = DateTime.now();
    counts.forEach((dogId, count) {
      _cache[dogId] = CachedLikeCount(
        count: count,
        cachedAt: now,
        cacheDurationMinutes: _cacheDurationMinutes,
      );
    });
    debugPrint('[LikeCacheService] Cached ${counts.length} dog like counts');
    _saveToStorage(); // Persist to storage
  }
  
  /// Clean up expired entries if cache size exceeds limit.
  void _cleanupIfNeeded() {
    if (_cache.length >= _maxCacheSize) {
      clearExpired();
      // If still too large after clearing expired, remove oldest entries
      if (_cache.length >= _maxCacheSize) {
        final entriesToRemove = _cache.length - (_maxCacheSize ~/ 2);
        final sortedKeys = _cache.keys.toList()
          ..sort((a, b) => _cache[a]!.cachedAt.compareTo(_cache[b]!.cachedAt));
        for (var i = 0; i < entriesToRemove && i < sortedKeys.length; i++) {
          _cache.remove(sortedKeys[i]);
        }
        debugPrint('[LikeCacheService] Removed $entriesToRemove oldest entries');
      }
    }
  }

  /// Remove a specific dog from cache.
  void removeCached(String dogId) {
    _cache.remove(dogId);
    debugPrint('[LikeCacheService] Removed cache for $dogId');
    _saveToStorage(); // Persist to storage
  }

  /// Clear all cached like counts.
  void clearCache() {
    final size = _cache.length;
    _cache.clear();
    debugPrint('[LikeCacheService] Cleared $size cached entries');
    _saveToStorage(); // Persist to storage
  }

  /// Remove expired entries from cache.
  void clearExpired() {
    final before = _cache.length;
    _cache.removeWhere((key, value) => value.isExpired());
    final removed = before - _cache.length;
    if (removed > 0) {
      debugPrint('[LikeCacheService] Removed $removed expired entries');
      _saveToStorage(); // Persist to storage
    }
  }

  /// Get the number of cached entries.
  int get cacheSize => _cache.length;

  /// Check if a dog breed has a valid cached count.
  bool hasCachedCount(String dogId) {
    final cached = _cache[dogId];
    return cached != null && !cached.isExpired();
  }
  
  /// Get all cached counts (including expired ones for offline mode).
  /// Returns a map of dogId -> count for all cached entries.
  Map<String, int> getAllCachedCounts({bool includeExpired = true}) {
    final result = <String, int>{};
    
    _cache.forEach((dogId, cached) {
      if (includeExpired || !cached.isExpired()) {
        result[dogId] = cached.count;
      }
    });
    
    return result;
  }
  
  /// Check if the service has been initialized.
  bool get isInitialized => _isInitialized;
}
