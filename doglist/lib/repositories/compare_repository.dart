import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/compare_sort_order.dart';

class CompareRepository {
  static const String _pinnedKey = 'compare_pinned_ids';
  static const String _sortKey = 'compare_sort_settings';

  Future<List<String>> getPinnedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_pinnedKey) ?? [];
  }

  Future<void> savePinnedIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_pinnedKey, ids);
  }

  Future<({CompareSortOrder order, bool ascending})> getSort() async {
    const defaultSort = (order: CompareSortOrder.unsorted, ascending: true);
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_sortKey);
    if (saved == null) return defaultSort;

    try {
      final data = jsonDecode(saved);
      if (data is! Map<String, dynamic>) return defaultSort;
      final order = CompareSortOrder.values.firstWhere(
        (order) => order.name == data['order'],
        orElse: () => CompareSortOrder.unsorted,
      );
      if (data['order'] != order.name) return defaultSort;
      final ascending = data['ascending'];
      return (order: order, ascending: ascending is bool ? ascending : order.defaultAscending);
    } on FormatException {
      return defaultSort;
    }
  }

  Future<void> saveSort(CompareSortOrder order, bool ascending) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortKey, jsonEncode({'order': order.name, 'ascending': ascending}));
  }
}
