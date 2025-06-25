import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/dog.dart';
import '../netservices/apidogs.dart';

class ListState {
  final List<Dog> originalItems;
  final List<Dog> items;
  final List<Dog> favorites;
  final bool toggleFilter;
  final bool showError;
  final bool loading;

  ListState({
    required this.originalItems,
    required this.items,
    required this.favorites,
    required this.toggleFilter,
    required this.showError,
    required this.loading,
  });

  factory ListState.initial() => ListState(
    originalItems: [],
    items: [],
    favorites: [],
    toggleFilter: false,
    showError: false,
    loading: true,
  );

  ListState copyWith({
    List<Dog>? originalItems,
    List<Dog>? items,
    List<Dog>? favorites,
    bool? toggleFilter,
    bool? showError,
    bool? loading,
  }) {
    return ListState(
      originalItems: originalItems ?? this.originalItems,
      items: items ?? this.items,
      favorites: favorites ?? this.favorites,
      toggleFilter: toggleFilter ?? this.toggleFilter,
      showError: showError ?? this.showError,
      loading: loading ?? this.loading,
    );
  }
}

class ListCubit extends Cubit<ListState> {
  final ApiDogs _apiDogs = ApiDogs();

  ListCubit() : super(ListState.initial()) {
    fetchDogData();
  }

  Future<void> fetchDogData() async {
    emit(state.copyWith(loading: true, showError: false));
    try {
      final List<Dog> originalItems = await _apiDogs.fetchData();
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

  void toggleFavorite(String id) {
    final Dog dog = state.originalItems.firstWhere((d) => d.id == id);
    final List<Dog> favorites = List<Dog>.from(state.favorites);
    if (favorites.contains(dog)) {
      favorites.remove(dog);
    } else {
      favorites.add(dog);
    }
    _filterAction(favorites: favorites);
  }

  void toggleFilterAction() {
    final toggleFilter = !state.toggleFilter;
    _filterAction(toggleFilter: toggleFilter);
  }

  void _filterAction({List<Dog>? favorites, bool? toggleFilter}) {
    final List<Dog> favs = favorites ?? state.favorites;
    final bool filter = toggleFilter ?? state.toggleFilter;
    final List<Dog> items = filter
        ? state.originalItems.where((item) => favs.contains(item)).toList()
        : List.from(state.originalItems);
    emit(state.copyWith(
      favorites: favs,
      toggleFilter: filter,
      items: items,
    ));
  }

  void reloadData() {
    emit(state.copyWith(showError: false));
    fetchDogData();
  }
}
