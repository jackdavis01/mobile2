import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dog.dart';

class UserPreferencesRepository {
  static const String _favoritesKey = 'user_favorites';
  static const String _bestDogKey = 'best_dog_id';

  // Favorites methods
  Future<List<Dog>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);

    if (favoritesJson == null || favoritesJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList.map((map) => Dog.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveFavorites(List<Dog> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = json.encode(favorites.map((dog) => dog.toMap()).toList());
    await prefs.setString(_favoritesKey, favoritesJson);
  }

  Future<void> toggleFavorite(Dog dog) async {
    final favorites = await getFavorites();
    final existingIndex = favorites.indexWhere((fav) => fav.id == dog.id);

    if (existingIndex >= 0) {
      favorites.removeAt(existingIndex);
    } else {
      favorites.add(dog);
    }

    await saveFavorites(favorites);
  }

  Future<bool> isFavorite(String dogId) async {
    final favorites = await getFavorites();
    return favorites.any((dog) => dog.id == dogId);
  }

  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }

  // Best dog methods
  Future<String?> getBestDogId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bestDogKey);
  }

  Future<void> setBestDogId(String dogId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bestDogKey, dogId);
  }

  Future<void> clearBestDogId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bestDogKey);
  }
}
