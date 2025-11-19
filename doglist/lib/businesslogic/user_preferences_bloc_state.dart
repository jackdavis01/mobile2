import '../models/dog.dart';

class UserPreferencesState {
  final List<Dog> favorites;
  final String? bestDogId;

  UserPreferencesState({
    required this.favorites,
    this.bestDogId,
  });

  factory UserPreferencesState.initial() => UserPreferencesState(
    favorites: [],
    bestDogId: null,
  );

  UserPreferencesState copyWith({
    List<Dog>? favorites,
    String? bestDogId,
    bool clearBestDogId = false,
  }) {
    return UserPreferencesState(
      favorites: favorites ?? this.favorites,
      bestDogId: clearBestDogId ? null : (bestDogId ?? this.bestDogId),
    );
  }
}
