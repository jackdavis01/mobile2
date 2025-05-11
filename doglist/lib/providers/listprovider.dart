import 'dart:async';
import 'package:flutter/material.dart';
import '../models/dog.dart';
import '../netservices/apidogs.dart';

class ListProvider with ChangeNotifier {
  List<Dog> originalItems = [];
  List<Dog> _items = [];
  final List<Dog> _favorites = [];
  bool _toggleFilter = false;

  List<Dog> get items => _items;
  List<Dog> get favorites => _favorites;
  bool get toggleFilter => _toggleFilter;

  bool _showError = false; // Error state
  Timer? _errorTimer; // Timer for error handling

  bool get showError => _showError;

  final ApiDogs _apiDogs = ApiDogs();

  ListProvider() {
    _fetchDogData(); // Loading of data during the initialization of this object
  }

  Future<void> _fetchDogData() async {

    try {
      originalItems = await _apiDogs.fetchData(); // API call
      _items = List.from(originalItems);
      _showError = false; // Reset error state
    } catch (e) {
      _showError = true; // Set error state
      debugPrint('Hiba: $e');
    } finally {
      notifyListeners();
    }
  
  }

  void toggleFavorite(String id) {
    final dog = originalItems.firstWhere((d) => d.id == id);
    if (_favorites.contains(dog)) {
      _favorites.remove(dog);
    } else {
      _favorites.add(dog);
    }
    _filterAction();
  }

  void toggleFilterAction() {
    _toggleFilter = !_toggleFilter;
    _filterAction();
  }

  void _filterAction() {
    if (_toggleFilter) {
      _items = originalItems.where((item) => _favorites.contains(item)).toList();
    } else {
      _items = List.from(originalItems);
    }
    notifyListeners();
  }

  void _startErrorTimer() {
    _errorTimer?.cancel(); // Cancel any existing timer
    _errorTimer = Timer(Duration(seconds: 10), () {
      if (originalItems.isEmpty) {
        _showError = true; // Show error after 10 seconds
        notifyListeners();
      }
    });
  }

  void _resetError() {
    _showError = false; // Reset error state
    notifyListeners();
  }

  void reloadData() {
    _resetError(); // Reset error state
    _fetchDogData(); // Trigger data reload
    _startErrorTimer(); // Restart the error timer
  }

  @override
  void dispose() {
    _errorTimer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

}
