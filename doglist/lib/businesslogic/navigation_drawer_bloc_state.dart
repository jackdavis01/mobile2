class NavigationDrawerState {
  final String dogBreedName;
  final int likes;

  NavigationDrawerState({
    required this.dogBreedName,
    required this.likes,
  });

  factory NavigationDrawerState.initial() => NavigationDrawerState(
    dogBreedName: "Dog breed",
    likes: 0,
  );

  NavigationDrawerState copyWith({
    String? dogBreedName,
    int? likes,
  }) {
    return NavigationDrawerState(
      dogBreedName: dogBreedName ?? this.dogBreedName,
      likes: likes ?? this.likes,
    );
  }
}
