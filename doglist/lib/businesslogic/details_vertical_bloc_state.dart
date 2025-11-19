
class DetailsVerticalState {
  final int currentDogIndex;
  final bool currentImagePageIsZoomed;

  DetailsVerticalState({
    required this.currentDogIndex,
    required this.currentImagePageIsZoomed,
  });

  DetailsVerticalState copyWith({
    int? currentDogIndex,
    bool? currentImagePageIsZoomed,
  }) {
    return DetailsVerticalState(
      currentDogIndex: currentDogIndex ?? this.currentDogIndex,
      currentImagePageIsZoomed: currentImagePageIsZoomed ?? this.currentImagePageIsZoomed,
    );
  }

}
