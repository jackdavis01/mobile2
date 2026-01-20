import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to track 24-hour like cooldowns per dog breed.
/// Persists cooldown timestamps in SharedPreferences.
class LikeCooldownService {
  static final LikeCooldownService _instance = LikeCooldownService._internal();
  factory LikeCooldownService() => _instance;
  LikeCooldownService._internal();

  static const String _cooldownKey = 'like_cooldowns';
  Map<String, DateTime>? _cachedCooldowns;

  /// Load cooldowns from SharedPreferences.
  Future<Map<String, DateTime>> _loadCooldowns() async {
    if (_cachedCooldowns != null) {
      return _cachedCooldowns!;
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cooldownKey);
    
    if (jsonString == null) {
      _cachedCooldowns = {};
      return _cachedCooldowns!;
    }

    try {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      _cachedCooldowns = decoded.map(
        (key, value) => MapEntry(key, DateTime.parse(value as String)),
      );
      debugPrint('[LikeCooldownService] Loaded ${_cachedCooldowns!.length} cooldowns');
      return _cachedCooldowns!;
    } catch (e) {
      debugPrint('[LikeCooldownService] Error loading cooldowns: $e');
      _cachedCooldowns = {};
      return _cachedCooldowns!;
    }
  }

  /// Save cooldowns to SharedPreferences.
  Future<void> _saveCooldowns() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _cachedCooldowns!.map(
      (key, value) => MapEntry(key, value.toIso8601String()),
    );
    await prefs.setString(_cooldownKey, json.encode(encoded));
    debugPrint('[LikeCooldownService] Saved ${_cachedCooldowns!.length} cooldowns');
  }

  /// Get the last time a dog was liked.
  Future<DateTime?> getLastLikeTime(String dogId) async {
    final cooldowns = await _loadCooldowns();
    return cooldowns[dogId];
  }

  /// Record that a dog was liked at a specific time.
  Future<void> setLastLikeTime(String dogId, DateTime time) async {
    final cooldowns = await _loadCooldowns();
    cooldowns[dogId] = time;
    _cachedCooldowns = cooldowns;
    await _saveCooldowns();
    debugPrint('[LikeCooldownService] Set cooldown for $dogId at $time');
  }

  /// Check if a dog can be liked now (24 hours have passed).
  Future<bool> canLikeNow(String dogId) async {
    final lastLikeTime = await getLastLikeTime(dogId);
    if (lastLikeTime == null) return true;

    final now = DateTime.now();
    final cooldownEnd = lastLikeTime.add(const Duration(hours: 24));
    return now.isAfter(cooldownEnd);
  }

  /// Get the remaining cooldown duration for a dog.
  /// Returns null if cooldown has expired.
  Future<Duration?> getRemainingCooldown(String dogId) async {
    final lastLikeTime = await getLastLikeTime(dogId);
    if (lastLikeTime == null) return null;

    final now = DateTime.now();
    final cooldownEnd = lastLikeTime.add(const Duration(hours: 24));
    
    if (now.isAfter(cooldownEnd)) {
      return null;
    }

    return cooldownEnd.difference(now);
  }

  /// Get the exact time when cooldown expires.
  /// Returns null if dog has never been liked.
  Future<DateTime?> getCooldownEndTime(String dogId) async {
    final lastLikeTime = await getLastLikeTime(dogId);
    if (lastLikeTime == null) return null;

    return lastLikeTime.add(const Duration(hours: 24));
  }

  /// Clear all cooldowns (for testing purposes).
  Future<void> clearAllCooldowns() async {
    _cachedCooldowns = {};
    await _saveCooldowns();
    debugPrint('[LikeCooldownService] Cleared all cooldowns');
  }

  /// Remove cooldown for a specific dog.
  Future<void> removeCooldown(String dogId) async {
    final cooldowns = await _loadCooldowns();
    cooldowns.remove(dogId);
    _cachedCooldowns = cooldowns;
    await _saveCooldowns();
    debugPrint('[LikeCooldownService] Removed cooldown for $dogId');
  }
}
