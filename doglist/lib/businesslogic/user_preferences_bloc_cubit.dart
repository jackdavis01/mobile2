import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_preferences_bloc_state.dart';
import '../models/dog.dart';
import '../repositories/user_preferences_repository.dart';

class UserPreferencesCubit extends Cubit<UserPreferencesState> {
  final UserPreferencesRepository _repository = UserPreferencesRepository();

  UserPreferencesCubit() : super(UserPreferencesState.initial()) {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    try {
      final List<Dog> favorites = await _repository.getFavorites();
      final String? bestDogId = await _repository.getBestDogId();
      emit(state.copyWith(favorites: favorites, bestDogId: bestDogId));
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> toggleFavorite(Dog dog) async {
    try {
      await _repository.toggleFavorite(dog);
      final List<Dog> updatedFavorites = await _repository.getFavorites();
      final String? updatedBestDogId = await _repository.getBestDogId();
      emit(state.copyWith(
        favorites: updatedFavorites,
        bestDogId: updatedBestDogId,
        clearBestDogId: updatedBestDogId == null,
      ));
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> toggleBestDog(String dogId) async {
    try {
      if (isBest(dogId)) {
        // If already best, clear it
        await _repository.clearBestDogId();
        emit(state.copyWith(clearBestDogId: true));
      } else {
        // Set as best (will automatically replace previous best)
        await _repository.setBestDogId(dogId);
        emit(state.copyWith(bestDogId: dogId));
      }
    } catch (e) {
      // Handle error if needed
    }
  }

  bool isFavorite(String dogId) {
    return state.favorites.any((dog) => dog.id == dogId);
  }

  bool isBest(String dogId) {
    return state.bestDogId == dogId;
  }

  Future<void> refreshPreferences() async {
    await loadPreferences();
  }
}
