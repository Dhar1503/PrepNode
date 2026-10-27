import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _cutoffCategoryPrefKey = 'prepnode_cutoff_category';

/// The seven real TNPSC reservation categories (matches the category values
/// seeded in cutoff_data — see seed_data.dart).
const List<String> tnpscReservationCategories = ['OC', 'BC', 'BCM', 'MBC', 'SC', 'SCA', 'ST'];

/// Persists the student's reservation category (used to compare their score
/// against the *right* cutoff, not a generic OC number) via
/// shared_preferences — same pattern as ThemeModeNotifier. This is
/// intentionally not a database column: it's a user-editable filter, not a
/// durable profile fact, and avoiding a schema migration keeps this safe to
/// ship without touching anyone's existing local database.
class CutoffCategoryNotifier extends StateNotifier<String> {
  CutoffCategoryNotifier() : super('OC') {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_cutoffCategoryPrefKey);
    if (saved != null && tnpscReservationCategories.contains(saved)) {
      state = saved;
    }
  }

  Future<void> setCategory(String category) async {
    if (!tnpscReservationCategories.contains(category)) return;
    state = category;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cutoffCategoryPrefKey, category);
  }
}

final selectedCutoffCategoryProvider =
    StateNotifierProvider<CutoffCategoryNotifier, String>((ref) {
  return CutoffCategoryNotifier();
});
