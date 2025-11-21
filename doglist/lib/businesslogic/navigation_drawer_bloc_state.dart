class NavigationDrawerState {
  final String? dogBreedName;
  final int likes;
  final String? bestDogImageUrl;
  final String? bestDogId;

  NavigationDrawerState({
    this.dogBreedName,
    required this.likes,
    this.bestDogImageUrl,
    this.bestDogId,
  });

  factory NavigationDrawerState.initial() => NavigationDrawerState(
    dogBreedName: null,
    likes: 0,
    bestDogImageUrl: null,
    bestDogId: null,
  );

  NavigationDrawerState copyWith({
    String? dogBreedName,
    int? likes,
    String? bestDogImageUrl,
    String? bestDogId,
    bool clearDogBreedName = false,
    bool clearBestDogImageUrl = false,
    bool clearBestDogId = false,
  }) {
    return NavigationDrawerState(
      dogBreedName: clearDogBreedName ? null : (dogBreedName ?? this.dogBreedName),
      likes: likes ?? this.likes,
      bestDogImageUrl: clearBestDogImageUrl ? null : (bestDogImageUrl ?? this.bestDogImageUrl),
      bestDogId: clearBestDogId ? null : (bestDogId ?? this.bestDogId),
    );
  }
}
