import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/dog.dart';
import '../repositories/dogs_data_repository.dart';
import 'filter_bloc_state.dart';

class FilterCubit extends Cubit<FilterState> {
  final DogsDataRepository _dogsRepository = DogsDataRepository();
  Timer? _debounceTimer;

  FilterCubit() : super(FilterState.initial()) {
    _loadAllDogs();
  }

  Future<void> _loadAllDogs() async {
    emit(state.copyWith(isLoading: true, hasError: false));
    try {
      final List<Dog> allDogs = await _dogsRepository.getDogs();
      final List<Dog> favorites = await _dogsRepository.getFavorites();
      emit(state.copyWith(
        allDogs: allDogs,
        filteredDogs: allDogs,
        favorites: favorites,
        isLoading: false,
        hasError: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));

    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Only filter if query meets minimum length requirement
    if (query.isEmpty || query.length >= 3) {
      // Debounce the filtering to avoid excessive filtering on every keystroke
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _performFilter();
      });
    } else {
      // Clear filtered results if query is too short but not empty
      emit(state.copyWith(filteredDogs: []));
    }
  }

  void updateCoatStyle(String? coatStyle) {
    emit(state.copyWith(
      selectedCoatStyle: coatStyle,
      clearCoatStyle: coatStyle == null,
    ));
    _performFilter();
  }

  void updateCoatTexture(String? coatTexture) {
    emit(state.copyWith(
      selectedCoatTexture: coatTexture,
      clearCoatTexture: coatTexture == null,
    ));
    _performFilter();
  }

  void updatePersonalityTraits(List<String> traits) {
    if (traits.length <= 3) { // Enforce 0-3 limit
      emit(state.copyWith(selectedPersonalityTraits: traits));
      _performFilter();
    }
  }

  void _performFilter() {
    List<Dog> filteredDogs = state.allDogs;

    // Apply breed name filter
    final String query = state.searchQuery;
    if (query.isNotEmpty && query.length >= 3) {
      filteredDogs = filteredDogs.where((dog) {
        return dog.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } else if (query.isNotEmpty && query.length < 3) {
      // If query is too short but not empty, show no results
      emit(state.copyWith(filteredDogs: []));
      return;
    }

    // Apply coat style filter
    if (state.selectedCoatStyle != null) {
      filteredDogs = filteredDogs.where((dog) {
        return dog.coatStyle.toLowerCase() == state.selectedCoatStyle!.toLowerCase();
      }).toList();
    }

    // Apply coat texture filter
    if (state.selectedCoatTexture != null) {
      filteredDogs = filteredDogs.where((dog) {
        return dog.coatTexture.toLowerCase() == state.selectedCoatTexture!.toLowerCase();
      }).toList();
    }

    // Apply personality traits filter
    if (state.selectedPersonalityTraits.isNotEmpty) {
      filteredDogs = filteredDogs.where((dog) {
        return state.selectedPersonalityTraits.every((trait) => 
          dog.personalityTraits.contains(trait));
      }).toList();
    }

    emit(state.copyWith(filteredDogs: filteredDogs));
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final Dog dog = state.allDogs.firstWhere((d) => d.id == id);
      await _dogsRepository.toggleFavorite(dog);
      final List<Dog> updatedFavorites = await _dogsRepository.getFavorites();
      emit(state.copyWith(favorites: updatedFavorites));
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> refreshFavorites() async {
    try {
      final List<Dog> updatedFavorites = await _dogsRepository.getFavorites();
      emit(state.copyWith(favorites: updatedFavorites));
    } catch (e) {
      // Handle error if needed
    }
  }

  void clearSearchQuery() {
    emit(state.copyWith(searchQuery: ''));
    // Trigger filtering with empty search query to update results
    _performFilter();
  }

  void clearAllFilters() {
    emit(state.copyWith(
      searchQuery: '',
      clearCoatStyle: true,
      clearCoatTexture: true,
      clearPersonalityTraits: true,
      filteredDogs: state.allDogs,
    ));
  }

  void reloadData() {
    _loadAllDogs();
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}