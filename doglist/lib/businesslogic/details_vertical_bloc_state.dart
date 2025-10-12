import '../models/dog.dart';

class DetailsVerticalState {
  final int currentDogIndex;
  final bool currentImagePageIsZoomed;
  final List<Dog> favorites;

  DetailsVerticalState({
    required this.currentDogIndex,
    required this.currentImagePageIsZoomed,
    required this.favorites,
  });

  DetailsVerticalState copyWith({
    int? currentDogIndex,
    bool? currentImagePageIsZoomed,
    List<Dog>? favorites,
  }) {
    return DetailsVerticalState(
      currentDogIndex: currentDogIndex ?? this.currentDogIndex,
      currentImagePageIsZoomed: currentImagePageIsZoomed ?? this.currentImagePageIsZoomed,
      favorites: favorites ?? this.favorites,
    );
  }

}
