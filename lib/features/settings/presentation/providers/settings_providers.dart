import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModePrefKey = 'prepnode_theme_mode';

/// Persists the user's Light/Dark/System choice via shared_preferences
/// (already a project dependency, used elsewhere by CacheManager) — no new
/// package, and AppTheme.lightTheme/darkTheme already exist in main.dart,
/// this just wires a real user-controlled switch to them.
///
/// Defaults to Light rather than following the system, because most
/// individual screens in this app hardcode AppColors (built/verified only
/// against the light palette) rather than reading the active Theme —
/// System/Dark mode currently causes real contrast bugs (e.g. text
/// rendered in the dark theme's color on a hardcoded-light background).
/// Light is also what the design docs name as "the default theme for all
/// new installs." Dark/System remain manually selectable in Settings.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeModePrefKey);
    if (saved == null) return;
    state = ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModePrefKey, mode.name);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
