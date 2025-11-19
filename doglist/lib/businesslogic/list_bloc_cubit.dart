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
      emit(state.copyWith(
        originalItems: originalItems,
        items: List.from(originalItems),
        showError: false,
        loading: false,
      ));
    } catch (e) {
      emit(state.copyWith(showError: true, loading: false));
    }
  }

  void updateFilteredItems(List<Dog> favorites) {
    final bool favoriteFilter = state.toggleFavoriteFilter;
    final List<Dog> items = favoriteFilter
        ? state.originalItems.where((item) => favorites.any((fav) => fav.id == item.id)).toList()
        : List.from(state.originalItems);
    emit(state.copyWith(items: items));
  }

  void toggleFavoriteFilterAction() {
    final toggleFavoriteFilter = !state.toggleFavoriteFilter;
    emit(state.copyWith(toggleFavoriteFilter: toggleFavoriteFilter));
  }

  void markFilterAsOpened() {
    emit(state.copyWith(filterTapCount: state.filterTapCount + 1));
  }

  void reloadData() {
    emit(state.copyWith(showError: false));
    fetchDogData();
  }
}
