import '../widgets/quick_filter_buttons.dart';

class SettingsState {
  final QuickFilterVisibility quickFilterVisibility;
  final bool isFirstXTimesDisabled;

  SettingsState({
    required this.quickFilterVisibility,
    required this.isFirstXTimesDisabled,
  });

  factory SettingsState.initial() => SettingsState(
    quickFilterVisibility: QuickFilterVisibility.onlyBeforeXTap,
    isFirstXTimesDisabled: false,
  );

  SettingsState copyWith({
    QuickFilterVisibility? quickFilterVisibility,
    bool? isFirstXTimesDisabled,
  }) {
    return SettingsState(
      quickFilterVisibility: quickFilterVisibility ?? this.quickFilterVisibility,
      isFirstXTimesDisabled: isFirstXTimesDisabled ?? this.isFirstXTimesDisabled,
    );
  }
}
