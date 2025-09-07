import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'details_image_bloc_state.dart';

class DetailsImageCubit extends Cubit<DetailsImageState> {
  final PageController horizontalPageController = PageController();
  final Map<int, Timer?> _timers = {};
  final List<TransformationController> lTransformationController = <TransformationController>[
    TransformationController(),
    TransformationController(),
    TransformationController(),
  ];
  void Function(bool isZoomed)? onZoomChanged;

  DetailsImageCubit({
    required int initialDogIndex,
    this.onZoomChanged,
  }) :
    super(DetailsImageState(
      currentHorizontalPage: 0,
      lIsLoading: [false, false, false],
      showError: {},
      lIsZoomed: [false, false, false],
      lViewerSize: [Size.zero, Size.zero, Size.zero],
    ));

  int get currentHorizontalPage => state.currentHorizontalPage;
  List<bool> get lIsLoading => state.lIsLoading;
  Map<int, bool> get showErrorMap => state.showError;
  List<bool> get lIsZoomed => state.lIsZoomed;
  List<Size> get lViewerSize => state.lViewerSize;

  bool get currentPageIsLoading => state.currentPageIsLoading;
  bool get currentPageIsZoomed => state.currentPageIsZoomed;
  Size get currentPageViewerSize => state.currentPageViewerSize;

  void updateHorizontalPage(int pageIndex) {
    _cancelAllTimers();
    final newShowError = Map<int, bool>.from(state.showError);
    newShowError[pageIndex] = false;
    emit(state.copyWith(
      currentHorizontalPage: pageIndex,
      showError: newShowError,
    ));
    onZoomChanged?.call(state.lIsZoomed[pageIndex]);
  }

  void startErrorTimer() {
    _timers[state.currentHorizontalPage]?.cancel();
    _timers[state.currentHorizontalPage] = Timer(const Duration(seconds: 10), () {
      final newShowError = Map<int, bool>.from(state.showError);
      newShowError[state.currentHorizontalPage] = true;
      emit(state.copyWith(showError: newShowError));
    });
  }

  void cancelErrorTimer() {
    _timers[state.currentHorizontalPage]?.cancel();
    final newShowError = Map<int, bool>.from(state.showError);
    newShowError[state.currentHorizontalPage] = false;
    emit(state.copyWith(showError: newShowError));
  }

  bool showError() => state.showError[state.currentHorizontalPage] ?? false;

  void _cancelAllTimers() {
    for (var timer in _timers.values) {
      timer?.cancel();
    }
    _timers.clear();
  }

  // The nullable parameter (`{int? pageIndex}`) is a
  // **defensive design**: it allows the method to be called
  // without specifying a page, in which case it defaults to the
  // current horizontal page.
  // This can be useful for future-proofing or for generic code.

  void updateIsLoading(bool newIsLoading, {int? pageIndex}) {
    final int idx = pageIndex ?? state.currentHorizontalPage;
    if (state.lIsLoading[idx] != newIsLoading) {
      final updated = List<bool>.from(state.lIsLoading);
      updated[idx] = newIsLoading;
      emit(state.copyWith(lIsLoading: updated));
    }
  }

  void updateIsZoomed(bool newIsZoomed) {
    final List<bool> updatedlIsZoomed = List<bool>.from(state.lIsZoomed);
    updatedlIsZoomed[state.currentHorizontalPage] = newIsZoomed;
    emit(state.copyWith(lIsZoomed: updatedlIsZoomed));
    onZoomChanged?.call(newIsZoomed);
  }

  void toggleZoom(int pageIndex) {
    final List<bool> updatedlIsZoomed = List<bool>.from(state.lIsZoomed);
    if (state.lIsZoomed[pageIndex]) {
      lTransformationController[pageIndex].value = Matrix4.identity();
      updatedlIsZoomed[pageIndex] = false;
      emit(state.copyWith(lIsZoomed: updatedlIsZoomed));
    } else {
      final double x = state.lViewerSize[pageIndex].width / 2;
      final double y = state.lViewerSize[pageIndex].height / 2;
      final double newScale = 1.28;
      lTransformationController[pageIndex].value = Matrix4.translationValues(x, y, 0)
        ..multiply(Matrix4.diagonal3Values(newScale, newScale, 1.0))
        ..multiply(Matrix4.translationValues(-x, -y, 0));
      updatedlIsZoomed[pageIndex] = true;
      emit(state.copyWith(lIsZoomed: updatedlIsZoomed));
    }
    onZoomChanged?.call(updatedlIsZoomed[pageIndex]);
   }

  void updateViewerSize(List<Size> newlViewerSize) {
    emit(state.copyWith(lViewerSize: newlViewerSize));
  }

  @override
  Future<void> close() {
    horizontalPageController.dispose();
    _cancelAllTimers();
    return super.close();
  }
}
