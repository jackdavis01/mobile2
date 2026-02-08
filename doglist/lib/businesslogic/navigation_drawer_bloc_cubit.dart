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

  Future<void> loadBestDog({Map<String, int>? likeCounts}) async {
    try {
      final String? bestDogId = await _userPrefsRepository.getBestDogId();
      if (bestDogId != null) {
        final List<Dog> allDogs = await _dogsRepository.getDogs();
        final Dog bestDog = allDogs.firstWhere(
          (dog) => dog.id == bestDogId,
          orElse: () => allDogs.first,
        );
        
        // Get like count for best dog if likeCounts provided
        int? bestDogLikes;
        if (likeCounts != null && likeCounts.containsKey(bestDogId)) {
          bestDogLikes = likeCounts[bestDogId];
        }
        
        emit(state.copyWith(
          dogBreedName: bestDog.name,
          bestDogImageUrl: bestDog.images.smallOutdoors,
          bestDogId: bestDog.id,
          likes: bestDogLikes,
          clearLikes: bestDogLikes == null,
        ));
      } else {
        emit(state.copyWith(
          clearDogBreedName: true,
          clearBestDogImageUrl: true,
          clearBestDogId: true,
          clearLikes: true,
        ));
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void updateDogBreedName(String name) {
    emit(state.copyWith(dogBreedName: name));
  }

  void updateLikes(int? likes) {
    emit(state.copyWith(likes: likes, clearLikes: likes == null));
  }

  Future<List<Dog>> getAllDogs() async {
    return await _dogsRepository.getDogs();
  }
}
