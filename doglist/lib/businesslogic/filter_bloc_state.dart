import '../models/dog.dart';

class FilterState {
  final String searchQuery;
  final String? selectedCoatStyle;
  final String? selectedCoatTexture;
  final List<String> selectedPersonalityTraits;
  final List<String> selectedQuickFilters; // New field for quick filters
  final List<Dog> allDogs;
  final List<Dog> filteredDogs;
  final List<Dog> favorites;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool shouldScrollToQuickFilters; // Trigger for initial scroll

  FilterState({
    required this.searchQuery,
    this.selectedCoatStyle,
    this.selectedCoatTexture,
    required this.selectedPersonalityTraits,
    required this.selectedQuickFilters,
    required this.allDogs,
    required this.filteredDogs,
    required this.favorites,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.shouldScrollToQuickFilters,
  });

  factory FilterState.initial() => FilterState(
    searchQuery: '',
    selectedCoatStyle: null,
    selectedCoatTexture: null,
    selectedPersonalityTraits: [],
    selectedQuickFilters: [],
    allDogs: [],
    filteredDogs: [],
    favorites: [],
    isLoading: false,
    hasError: false,
    errorMessage: null,
    shouldScrollToQuickFilters: false,
  );

  bool get isSearchQueryValid => searchQuery.length >= 3;
  bool get showValidationError => searchQuery.isNotEmpty && !isSearchQueryValid;
  int get matchCount => filteredDogs.length;
  bool get hasActiveFilters => isSearchQueryValid || selectedCoatStyle != null || selectedCoatTexture != null || selectedPersonalityTraits.isNotEmpty || selectedQuickFilters.isNotEmpty;

  FilterState copyWith({
    String? searchQuery,
    String? selectedCoatStyle,
    bool clearCoatStyle = false,
    String? selectedCoatTexture,
    bool clearCoatTexture = false,
    List<String>? selectedPersonalityTraits,
    bool clearPersonalityTraits = false,
    List<String>? selectedQuickFilters,
    bool clearQuickFilters = false,
    List<Dog>? allDogs,
    List<Dog>? filteredDogs,
    List<Dog>? favorites,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? shouldScrollToQuickFilters,
  }) {
    return FilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCoatStyle: clearCoatStyle ? null : (selectedCoatStyle ?? this.selectedCoatStyle),
      selectedCoatTexture: clearCoatTexture ? null : (selectedCoatTexture ?? this.selectedCoatTexture),
      selectedPersonalityTraits: clearPersonalityTraits ? [] : (selectedPersonalityTraits ?? this.selectedPersonalityTraits),
      selectedQuickFilters: clearQuickFilters ? [] : (selectedQuickFilters ?? this.selectedQuickFilters),
      allDogs: allDogs ?? this.allDogs,
      filteredDogs: filteredDogs ?? this.filteredDogs,
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      shouldScrollToQuickFilters: shouldScrollToQuickFilters ?? this.shouldScrollToQuickFilters,
    );
  }
}