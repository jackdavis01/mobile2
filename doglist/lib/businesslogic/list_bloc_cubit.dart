import 'package:flutter_bloc/flutter_bloc.dart';
import 'list_bloc_state.dart';
import '../models/dog.dart';
import '../repositories/dogs_data_repository.dart';

class ListCubit extends Cubit<ListState> {
  final DogsDataRepository _dogsRepository = DogsDataRepository();

  ListCubit() : super(ListState.initial()) {
    fetchDogData();
  }

  Future<void> fetchDogData() async {
    emit(state.copyWith(loading: true, showError: false));
    try {
      final List<Dog> originalItems = await _dogsRepository.getDogs();
      final List<Dog> favorites = await _dogsRepository.getFavorites();
      emit(state.copyWith(
        originalItems: originalItems,
        items: List.from(originalItems),
        favorites: favorites,
        showError: false,
        loading: false,
      ));
    } catch (e) {
      emit(state.copyWith(showError: true, loading: false));
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final Dog dog = state.originalItems.firstWhere((d) => d.id == id);
      await _dogsRepository.toggleFavorite(dog);
      final List<Dog> updatedFavorites = await _dogsRepository.getFavorites();
      _favoriteFilterAction(favorites: updatedFavorites);
    } catch (e) {
      // Handle error if needed
    }
  }



  void _favoriteFilterAction({List<Dog>? favorites, bool? toggleFavoriteFilter}) {
    final List<Dog> favs = favorites ?? state.favorites;
    final bool favoriteFilter = toggleFavoriteFilter ?? state.toggleFavoriteFilter;
    final List<Dog> items = favoriteFilter
        ? state.originalItems.where((item) => favs.any((fav) => fav.id == item.id)).toList()
        : List.from(state.originalItems);
    emit(state.copyWith(
      favorites: favs,
      toggleFavoriteFilter: favoriteFilter,
      items: items,
    ));
  }

  void toggleFavoriteFilterAction() {
    final toggleFavoriteFilter = !state.toggleFavoriteFilter;
    _favoriteFilterAction(toggleFavoriteFilter: toggleFavoriteFilter);
  }

  Future<void> refreshFavorites() async {
    try {
      final List<Dog> updatedFavorites = await _dogsRepository.getFavorites();
      _favoriteFilterAction(favorites: updatedFavorites);
    } catch (e) {
      // Handle error if needed
    }
  }

  void markFilterAsOpened() {
    emit(state.copyWith(hasOpenedFilter: true));
  }

  void reloadData() {
    emit(state.copyWith(showError: false));
    fetchDogData();
  }
}
