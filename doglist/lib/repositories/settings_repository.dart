import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/quick_filter_buttons.dart';

class SettingsRepository {
  static const String _quickFilterVisibilityKey = 'quick_filter_visibility';
  static const String _firstXTimesDisabledKey = 'first_x_times_disabled';
  static const String _listPageDiscoveryKey = 'list_page_discovery_enabled';
  static const String _detailsPageDiscoveryKey = 'details_page_discovery_enabled';
  static const String _filterPageDiscoveryKey = 'filter_page_discovery_enabled';
  static const String _navigationPageDiscoveryKey = 'navigation_page_discovery_enabled';

  Future<QuickFilterVisibility> getQuickFilterVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final String? value = prefs.getString(_quickFilterVisibilityKey);

    if (value == null) {
      return QuickFilterVisibility.onlyBeforeXTap; // Default
    }

    return QuickFilterVisibility.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => QuickFilterVisibility.onlyBeforeXTap,
    );
  }

  Future<void> setQuickFilterVisibility(QuickFilterVisibility visibility) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_quickFilterVisibilityKey, visibility.toString());
  }

  Future<bool> getFirstXTimesDisabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstXTimesDisabledKey) ?? false;
  }

  Future<void> setFirstXTimesDisabled(bool disabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstXTimesDisabledKey, disabled);
  }

  Future<bool> getListPageDiscoveryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_listPageDiscoveryKey) ?? true;
  }

  Future<void> setListPageDiscoveryEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_listPageDiscoveryKey, value);
  }

  Future<bool> getDetailsPageDiscoveryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_detailsPageDiscoveryKey) ?? true;
  }

  Future<void> setDetailsPageDiscoveryEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_detailsPageDiscoveryKey, value);
  }

  Future<bool> getFilterPageDiscoveryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_filterPageDiscoveryKey) ?? true;
  }

  Future<void> setFilterPageDiscoveryEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_filterPageDiscoveryKey, value);
  }

  Future<bool> getNavigationPageDiscoveryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_navigationPageDiscoveryKey) ?? true;
  }

  Future<void> setNavigationPageDiscoveryEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_navigationPageDiscoveryKey, value);
  }

  /// Clears the feature discovery completion preferences for list page features.
  /// This removes the completion flags so discovery can be shown again.
  Future<void> clearListPageFeatureDiscoveryPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // Feature IDs from FeatureIds.listPageFeatures
    final listPageFeatures = [
      'nav_menu_icon',
      'list_quick_filters',
      'list_filter_button',
      'list_favorite_button',
      'list_favorite_filter_button',
    ];
    for (final featureId in listPageFeatures) {
      await prefs.remove(featureId);
    }
  }

  /// Clears the feature discovery completion preferences for details page features.
  /// This removes the completion flags so discovery can be shown again.
  Future<void> clearDetailsPageFeatureDiscoveryPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // Feature IDs from FeatureIds.detailsPageFeatures
    final detailsPageFeatures = [
      'details_favorite_button',
      'details_zoom_icon',
      'details_navigate_arrow',
      'details_vertical_paging',
    ];
    for (final featureId in detailsPageFeatures) {
      await prefs.remove(featureId);
    }
  }

  /// Clears the feature discovery completion preferences for filter page features.
  /// This removes the completion flags so discovery can be shown again.
  Future<void> clearFilterPageFeatureDiscoveryPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // Feature IDs from FeatureIds.filterPageFeatures
    final filterPageFeatures = [
      'filter_search_bar',
      'filter_advanced_filters',
    ];
    for (final featureId in filterPageFeatures) {
      await prefs.remove(featureId);
    }
  }

  /// Clears the feature discovery completion preferences for navigation page features.
  /// This removes the completion flags so discovery can be shown again.
  Future<void> clearNavigationPageFeatureDiscoveryPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // Feature IDs from FeatureIds.navigationPageFeatures
    final navigationPageFeatures = [
      'nav_best_dog',
    ];
    for (final featureId in navigationPageFeatures) {
      await prefs.remove(featureId);
    }
  }
}
