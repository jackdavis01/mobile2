import 'dart:ui';

class DetailsImageState {
  final int currentHorizontalPage;
  final List<bool> lIsLoading;
  final Map<int, bool> showError;
  final List<bool> lIsZoomed;
  final List<Size> lViewerSize;

  bool get currentPageIsLoading => lIsLoading[currentHorizontalPage];
  bool get currentPageIsZoomed => lIsZoomed[currentHorizontalPage];
  Size get currentPageViewerSize => lViewerSize[currentHorizontalPage];

  DetailsImageState({
    required this.currentHorizontalPage,
    required this.lIsLoading,
    required this.showError,
    required this.lIsZoomed,
    required this.lViewerSize});

  DetailsImageState copyWith({
    int? currentDogIndex,
    int? currentHorizontalPage,
    List<bool>? lIsLoading,
    Map<int, bool>? showError,
    List<bool>? lIsZoomed,
    List<Size>? lViewerSize}) {
    return DetailsImageState(
      currentHorizontalPage: currentHorizontalPage ?? this.currentHorizontalPage,
      lIsLoading: lIsLoading ?? this.lIsLoading,
      showError: showError ?? Map<int, bool>.from(this.showError),
      lIsZoomed: lIsZoomed ?? this.lIsZoomed,
      lViewerSize: lViewerSize ?? this.lViewerSize,
    );
  }
}
