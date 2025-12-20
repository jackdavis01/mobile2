import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../parameters/netservices.dart';
import '../models/dog.dart';
import '../models/dog_extended_info.dart';
import '../netservices/apidogs.dart';

class DogsDataRepository {
  static const String _jsonKey = 'dogs_json_data';
  static const String _jsonExpiryKey = 'dogs_json_expiry';
  static const String _cacheVersionKey = 'cache_version';
  static const int _currentCacheVersion = 3; // Increment when Dog model structure changes

  final ApiDogs _apiDogs = ApiDogs();

  Future<List<Dog>> getDogs() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiry = prefs.getInt(_jsonExpiryKey) ?? 0;
    final cacheVersion = prefs.getInt(_cacheVersionKey) ?? 0;

    // Check if cache is valid (not expired and correct version)
    if (prefs.containsKey(_jsonKey) && 
        now < expiry && 
        cacheVersion == _currentCacheVersion) {
      // Load from cache
      try {
        final jsonString = prefs.getString(_jsonKey)!;
        final List<dynamic> ldData = json.decode(jsonString);
        return ldData.map((map) => Dog.fromMap(map)).toList();
      } catch (e) {
        // If parsing fails, clear cache and fetch fresh data
        await clearCache();
      }
    }

    // Fetch from network (cache invalid, expired, wrong version, or parse error)
    final response = await _apiDogs.fetchRawData();
    await prefs.setString(_jsonKey, response);
    await prefs.setInt(
      _jsonExpiryKey,
      now + NS.expirationIntervalDays * 24 * 60 * 60 * 1000,
    );
    await prefs.setInt(_cacheVersionKey, _currentCacheVersion);

    // Parse and return Dog objects
    final List<dynamic> ldData = json.decode(response);
    return ldData.map((map) => Dog.fromMap(map)).toList();
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jsonKey);
    await prefs.remove(_jsonExpiryKey);
  }

  /// Get extended information for a specific dog by ID
  /// This parses the extended fields from the cached JSON on-demand
  Future<DogExtendedInfo?> getExtendedInfo(String dogId) async {
    final prefs = await SharedPreferences.getInstance();

    // Try to get from cache first
    if (prefs.containsKey(_jsonKey)) {
      final jsonString = prefs.getString(_jsonKey)!;
      final List<dynamic> ldData = json.decode(jsonString);

      // Find the breed with matching ID
      final breedData = ldData.firstWhere(
        (map) => map['id'] == dogId,
        orElse: () => null,
      );

      if (breedData != null) {
        return DogExtendedInfo.fromMap(dogId, breedData);
      }
    }

    // If not in cache, fetch from network
    try {
      await getDogs(); // This will cache the data
      // Now try again from cache
      return getExtendedInfo(dogId);
    } catch (e) {
      return null;
    }
  }
}