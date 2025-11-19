import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_drawer_bloc_state.dart';
import '../repositories/user_preferences_repository.dart';
import '../repositories/dogs_data_repository.dart';
import '../models/dog.dart';

class NavigationDrawerCubit extends Cubit<NavigationDrawerState> {
  final UserPreferencesRepository _userPrefsRepository = UserPreferencesRepository();
  final DogsDataRepository _dogsRepository = DogsDataRepository();

  NavigationDrawerCubit() : super(NavigationDrawerState.initial()) {
    loadBestDog();
  }

  Future<void> loadBestDog() async {
    try {
      final String? bestDogId = await _userPrefsRepository.getBestDogId();
      if (bestDogId != null) {
        final List<Dog> allDogs = await _dogsRepository.getDogs();
        final Dog bestDog = allDogs.firstWhere(
          (dog) => dog.id == bestDogId,
          orElse: () => allDogs.first,
        );
        emit(state.copyWith(
          dogBreedName: bestDog.name,
          bestDogImageUrl: bestDog.images.smallOutdoors,
          bestDogId: bestDog.id,
        ));
      } else {
        emit(state.copyWith(
          clearBestDogImageUrl: true,
          clearBestDogId: true,
        ));
      }
      // Count favorites as likes
      final List<Dog> favorites = await _userPrefsRepository.getFavorites();
      emit(state.copyWith(likes: favorites.length));
    } catch (e) {
      // Handle error silently
    }
  }

  void updateDogBreedName(String name) {
    emit(state.copyWith(dogBreedName: name));
  }

  void updateLikes(int likes) {
    emit(state.copyWith(likes: likes));
  }

  void incrementLikes() {
    emit(state.copyWith(likes: state.likes + 1));
  }

  void decrementLikes() {
    emit(state.copyWith(likes: state.likes - 1));
  }

  Future<List<Dog>> getAllDogs() async {
    return await _dogsRepository.getDogs();
  }
}
