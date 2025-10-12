import '../models/dog.dart';

class ListState {
  final List<Dog> originalItems;
  final List<Dog> items;
  final List<Dog> favorites;
  final bool toggleFavoriteFilter;
  final bool showError;
  final bool loading;

  ListState({
    required this.originalItems,
    required this.items,
    required this.favorites,
    required this.toggleFavoriteFilter,
    required this.showError,
    required this.loading,
  });

  factory ListState.initial() => ListState(
    originalItems: [],
    items: [],
    favorites: [],
    toggleFavoriteFilter: false,
    showError: false,
    loading: true,
  );

  ListState copyWith({
    List<Dog>? originalItems,
    List<Dog>? items,
    List<Dog>? favorites,
    bool? toggleFavoriteFilter,
    bool? showError,
    bool? loading,
  }) {
    return ListState(
      originalItems: originalItems ?? this.originalItems,
      items: items ?? this.items,
      favorites: favorites ?? this.favorites,
      toggleFavoriteFilter: toggleFavoriteFilter ?? this.toggleFavoriteFilter,
      showError: showError ?? this.showError,
      loading: loading ?? this.loading,
    );
  }
}
