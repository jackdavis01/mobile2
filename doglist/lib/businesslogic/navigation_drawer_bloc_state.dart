class NavigationDrawerState {
  final String dogBreedName;
  final int likes;
  final String? bestDogImageUrl;
  final String? bestDogId;

  NavigationDrawerState({
    required this.dogBreedName,
    required this.likes,
    this.bestDogImageUrl,
    this.bestDogId,
  });

  factory NavigationDrawerState.initial() => NavigationDrawerState(
    dogBreedName: "Dog breed",
    likes: 0,
    bestDogImageUrl: null,
    bestDogId: null,
  );

  NavigationDrawerState copyWith({
    String? dogBreedName,
    int? likes,
    String? bestDogImageUrl,
    String? bestDogId,
    bool clearBestDogImageUrl = false,
    bool clearBestDogId = false,
  }) {
    return NavigationDrawerState(
      dogBreedName: dogBreedName ?? this.dogBreedName,
      likes: likes ?? this.likes,
      bestDogImageUrl: clearBestDogImageUrl ? null : (bestDogImageUrl ?? this.bestDogImageUrl),
      bestDogId: clearBestDogId ? null : (bestDogId ?? this.bestDogId),
    );
  }
}
