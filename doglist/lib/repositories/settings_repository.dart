import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/quick_filter_buttons.dart';

class SettingsRepository {
  static const String _quickFilterVisibilityKey = 'quick_filter_visibility';
  static const String _firstXTimesDisabledKey = 'first_x_times_disabled';

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
}
