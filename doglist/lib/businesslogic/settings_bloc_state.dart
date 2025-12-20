import '../widgets/quick_filter_buttons.dart';

class SettingsState {
  final QuickFilterVisibility quickFilterVisibility;
  final bool isFirstXTimesDisabled;
  final bool listPageDiscoveryEnabled;
  final bool detailsPageDiscoveryEnabled;
  final bool filterPageDiscoveryEnabled;
  final bool navigationPageDiscoveryEnabled;

  SettingsState({
    required this.quickFilterVisibility,
    required this.isFirstXTimesDisabled,
    required this.listPageDiscoveryEnabled,
    required this.detailsPageDiscoveryEnabled,
    required this.filterPageDiscoveryEnabled,
    required this.navigationPageDiscoveryEnabled,
  });

  factory SettingsState.initial() => SettingsState(
    quickFilterVisibility: QuickFilterVisibility.onlyBeforeXTap,
    isFirstXTimesDisabled: false,
    listPageDiscoveryEnabled: true,
    detailsPageDiscoveryEnabled: true,
    filterPageDiscoveryEnabled: true,
    navigationPageDiscoveryEnabled: true,
  );

  SettingsState copyWith({
    QuickFilterVisibility? quickFilterVisibility,
    bool? isFirstXTimesDisabled,
    bool? listPageDiscoveryEnabled,
    bool? detailsPageDiscoveryEnabled,
    bool? filterPageDiscoveryEnabled,
    bool? navigationPageDiscoveryEnabled,
  }) {
    return SettingsState(
      quickFilterVisibility: quickFilterVisibility ?? this.quickFilterVisibility,
      isFirstXTimesDisabled: isFirstXTimesDisabled ?? this.isFirstXTimesDisabled,
      listPageDiscoveryEnabled: listPageDiscoveryEnabled ?? this.listPageDiscoveryEnabled,
      detailsPageDiscoveryEnabled: detailsPageDiscoveryEnabled ?? this.detailsPageDiscoveryEnabled,
      filterPageDiscoveryEnabled: filterPageDiscoveryEnabled ?? this.filterPageDiscoveryEnabled,
      navigationPageDiscoveryEnabled: navigationPageDiscoveryEnabled ?? this.navigationPageDiscoveryEnabled,
    );
  }
}
