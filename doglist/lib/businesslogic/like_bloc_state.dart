class LikeState {
  final Map<String, int> likeCounts;
  final Map<String, DateTime> cooldownEndTimes;
  final bool isLoading;
  final String? error;

  LikeState({
    required this.likeCounts,
    required this.cooldownEndTimes,
    required this.isLoading,
    this.error,
  });

  factory LikeState.initial() => LikeState(
    likeCounts: {},
    cooldownEndTimes: {},
    isLoading: false,
    error: null,
  );

  LikeState copyWith({
    Map<String, int>? likeCounts,
    Map<String, DateTime>? cooldownEndTimes,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return LikeState(
      likeCounts: likeCounts ?? this.likeCounts,
      cooldownEndTimes: cooldownEndTimes ?? this.cooldownEndTimes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
