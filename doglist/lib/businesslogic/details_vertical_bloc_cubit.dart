import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'details_vertical_bloc_state.dart';
import 'details_image_bloc_cubit.dart';

class DetailsVerticalCubit extends Cubit<DetailsVerticalState> {
  final PageController verticalPageController;
  late DetailsImageCubit detailsImageCubit;

  DetailsVerticalCubit({required int initialDogIndex}) :
    verticalPageController = PageController(initialPage: initialDogIndex),
    detailsImageCubit = DetailsImageCubit(initialDogIndex: initialDogIndex),
    super(
      DetailsVerticalState(
        currentDogIndex: initialDogIndex,
        currentImagePageIsZoomed: false,
      )
    );

  int get currentDogIndex => state.currentDogIndex;

  void updateDogIndex(int index) {
    emit(state.copyWith(
      currentDogIndex: index,
    ));
    detailsImageCubit = DetailsImageCubit(initialDogIndex: currentDogIndex);
  }

  void setCurrentImagePageIsZoomed(bool isZoomed) {
    emit(state.copyWith(currentImagePageIsZoomed: isZoomed));
  }

  @override
  Future<void> close() {
    verticalPageController.dispose();
    return super.close();
  }
}
