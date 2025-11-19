import '../models/dog.dart';

class ListState {
  final List<Dog> originalItems;
  final List<Dog> items;
  final bool toggleFavoriteFilter;
  final bool showError;
  final bool loading;
  final int filterTapCount;

  ListState({
    required this.originalItems,
    required this.items,
    required this.toggleFavoriteFilter,
    required this.showError,
    required this.loading,
    required this.filterTapCount,
  });

  factory ListState.initial() => ListState(
    originalItems: [],
    items: [],
    toggleFavoriteFilter: false,
    showError: false,
    loading: true,
    filterTapCount: 0,
  );

  ListState copyWith({
    List<Dog>? originalItems,
    List<Dog>? items,
    bool? toggleFavoriteFilter,
    bool? showError,
    bool? loading,
    int? filterTapCount,
  }) {
    return ListState(
      originalItems: originalItems ?? this.originalItems,
      items: items ?? this.items,
      toggleFavoriteFilter: toggleFavoriteFilter ?? this.toggleFavoriteFilter,
      showError: showError ?? this.showError,
      loading: loading ?? this.loading,
      filterTapCount: filterTapCount ?? this.filterTapCount,
    );
  }
}
