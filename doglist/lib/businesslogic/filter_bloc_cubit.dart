import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/dog.dart';
import '../repositories/dogs_data_repository.dart';
import '../repositories/user_preferences_repository.dart';
import 'filter_bloc_state.dart';

class FilterCubit extends Cubit<FilterState> {
  final DogsDataRepository _dogsRepository = DogsDataRepository();
  final UserPreferencesRepository _userPrefsRepository =
      UserPreferencesRepository();
  Timer? _debounceTimer;
  final String? _initialQuickFilter;

  FilterCubit({String? initialQuickFilter})
      : _initialQuickFilter = initialQuickFilter,
        super(FilterState.initial()) {
    _loadAllDogs();
  }

  Future<void> _loadAllDogs() async {
    emit(state.copyWith(isLoading: true, hasError: false));
    try {
      final List<Dog> allDogs = await _dogsRepository.getDogs();
      emit(state.copyWith(
        allDogs: allDogs,
        filteredDogs: allDogs,
        isLoading: false,
        hasError: false,
      ));

      // Apply initial quick filter after data is loaded
      if (_initialQuickFilter != null) {
        emit(state.copyWith(selectedQuickFilters: [_initialQuickFilter]));
        _performFilter();
        // Set flag to trigger scroll on first render
        emit(state.copyWith(shouldScrollToQuickFilters: true));
      }
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
    if (traits.length <= 3) {
      // Enforce 0-3 limit
      emit(state.copyWith(selectedPersonalityTraits: traits));
      _performFilter();
    }
  }

  void updateQuickFilters(List<String> filters) {
    if (filters.length <= 3) {
      // Enforce 0-3 limit
      emit(state.copyWith(selectedQuickFilters: filters));
      _performFilter();
    }
  }

  void clearScrollFlag() {
    emit(state.copyWith(shouldScrollToQuickFilters: false));
  }

  void toggleFavoriteFilterAction() {
    final toggleFavoriteFilter = !state.toggleFavoriteFilter;
    emit(state.copyWith(toggleFavoriteFilter: toggleFavoriteFilter));
    _performFilter();
  }

  void refreshFilters() {
    _performFilter();
  }

  Future<void> _performFilter() async {
    List<Dog> filteredDogs = state.allDogs;

    // Apply favorite filter first
    if (state.toggleFavoriteFilter) {
      final List<Dog> favorites = await _userPrefsRepository.getFavorites();
      filteredDogs = filteredDogs
          .where((dog) => favorites.any((fav) => fav.id == dog.id))
          .toList();
    }

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
        return dog.coatStyle.toLowerCase() ==
            state.selectedCoatStyle!.toLowerCase();
      }).toList();
    }

    // Apply coat texture filter
    if (state.selectedCoatTexture != null) {
      filteredDogs = filteredDogs.where((dog) {
        return dog.coatTexture.toLowerCase() ==
            state.selectedCoatTexture!.toLowerCase();
      }).toList();
    }

    // Apply personality traits filter
    if (state.selectedPersonalityTraits.isNotEmpty) {
      filteredDogs = filteredDogs.where((dog) {
        return state.selectedPersonalityTraits
            .every((trait) => dog.personalityTraits.contains(trait));
      }).toList();
    }

    // Apply quick filters
    if (state.selectedQuickFilters.isNotEmpty) {
      filteredDogs = filteredDogs.where((dog) {
        return state.selectedQuickFilters.every((filter) {
          switch (filter) {
            case 'family-friendly':
              return dog.childFriendly >= 4;
            case 'low-maintenance':
              return dog.groomingFrequency <= 2;
            case 'active-dogs':
              return dog.exerciseNeeds >= 4;
            case 'apartment-friendly':
              return dog.size <= 2 && dog.barkingFrequency <= 3;
            case 'first-time-owners':
              return dog.trainingDifficulty <= 2;
            case 'clean-tidy':
              return dog.sheddingAmount <= 2 && dog.droolingFrequency == 1;
            default:
              return true;
          }
        });
      }).toList();
    }

    emit(state.copyWith(filteredDogs: filteredDogs));
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
      clearQuickFilters: true,
      toggleFavoriteFilter: false,
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
