class CompareState {
  final List<String> pinnedIds;

  CompareState({required this.pinnedIds});

  factory CompareState.initial() => CompareState(pinnedIds: []);

  bool get hasTwoPinned => pinnedIds.length == 2;

  CompareState copyWith({List<String>? pinnedIds}) {
    return CompareState(pinnedIds: pinnedIds ?? this.pinnedIds);
  }
}
