import '../models/compare_sort_order.dart';

class CompareState {
  final List<String> pinnedIds;
  final CompareSortOrder sortOrder;
  final bool sortAscending;

  CompareState({
    required this.pinnedIds,
    this.sortOrder = CompareSortOrder.unsorted,
    this.sortAscending = true,
  });

  factory CompareState.initial() => CompareState(pinnedIds: []);

  bool get hasTwoPinned => pinnedIds.length == 2;

  CompareState copyWith({List<String>? pinnedIds, CompareSortOrder? sortOrder, bool? sortAscending}) {
    return CompareState(
      pinnedIds: pinnedIds ?? this.pinnedIds,
      sortOrder: sortOrder ?? this.sortOrder,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}
