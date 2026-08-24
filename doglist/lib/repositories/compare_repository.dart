import 'package:shared_preferences/shared_preferences.dart';

class CompareRepository {
  static const String _pinnedKey = 'compare_pinned_ids';

  Future<List<String>> getPinnedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_pinnedKey) ?? [];
  }

  Future<void> savePinnedIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_pinnedKey, ids);
  }
}
