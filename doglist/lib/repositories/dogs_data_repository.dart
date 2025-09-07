import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../parameters/netservices.dart';
import '../models/dog.dart';
import '../netservices/apidogs.dart';

class DogsDataRepository {
  static const String _jsonKey = 'dogs_json_data';
  static const String _jsonExpiryKey = 'dogs_json_expiry';

  final ApiDogs _apiDogs = ApiDogs();

  Future<List<Dog>> getDogs() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiry = prefs.getInt(_jsonExpiryKey) ?? 0;

    if (prefs.containsKey(_jsonKey) && now < expiry) {
      // Load from cache
      final jsonString = prefs.getString(_jsonKey)!;
      final List<dynamic> ldData = json.decode(jsonString);
      return ldData.map((map) => Dog.fromMap(map)).toList();
    } else {
      // Fetch from network
      final dogs = await _apiDogs.fetchData();
      final jsonString = json.encode(dogs.map((d) => d.toMap()).toList());
      await prefs.setString(_jsonKey, jsonString);
      await prefs.setInt(
        _jsonExpiryKey,
        now + NS.expirationIntervalDays * 24 * 60 * 60 * 1000,
      );
      return dogs;
    }
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jsonKey);
    await prefs.remove(_jsonExpiryKey);
  }
}