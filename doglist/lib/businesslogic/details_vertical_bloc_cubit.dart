import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'details_vertical_bloc_state.dart';
import 'details_image_bloc_cubit.dart';
import '../repositories/dogs_data_repository.dart';
import '../models/dog.dart';

class DetailsVerticalCubit extends Cubit<DetailsVerticalState> {
  final PageController verticalPageController;
  final DogsDataRepository _dogsRepository = DogsDataRepository();
  late DetailsImageCubit detailsImageCubit;

  DetailsVerticalCubit({required int initialDogIndex}) :
    verticalPageController = PageController(initialPage: initialDogIndex),
    detailsImageCubit = DetailsImageCubit(initialDogIndex: initialDogIndex),
    super(
      DetailsVerticalState(
        currentDogIndex: initialDogIndex,
        currentImagePageIsZoomed: false,
        favorites: [],
      )
    ) {
    _loadFavorites();
  }

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

  Future<void> _loadFavorites() async {
    try {
      final List<Dog> favorites = await _dogsRepository.getFavorites();
      emit(state.copyWith(favorites: favorites));
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> toggleFavorite(Dog dog) async {
    try {
      await _dogsRepository.toggleFavorite(dog);
      final List<Dog> updatedFavorites = await _dogsRepository.getFavorites();
      emit(state.copyWith(favorites: updatedFavorites));
    } catch (e) {
      // Handle error if needed
    }
  }

  bool isFavorite(Dog dog) {
    return state.favorites.any((fav) => fav.id == dog.id);
  }

  @override
  Future<void> close() {
    verticalPageController.dispose();
    return super.close();
  }
}
