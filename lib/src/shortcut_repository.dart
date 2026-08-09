import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/errors/app_exception.dart';
import 'shortcut_models.dart';

abstract class ShortcutRepository {
  Future<List<ShortcutEntry>> loadShortcuts();

  Future<void> saveShortcuts(List<ShortcutEntry> entries);

  Future<AppThemePreference> loadThemePreference();

  Future<void> saveThemePreference(AppThemePreference preference);

  Future<AppLayoutPreference> loadLayoutPreference();

  Future<void> saveLayoutPreference(AppLayoutPreference preference);

  Future<ShortcutSortPreference> loadSortPreference();

  Future<void> saveSortPreference(ShortcutSortPreference preference);

  Future<bool> loadFavoritesFirstPreference();

  Future<void> saveFavoritesFirstPreference(bool favoritesFirst);
}

class SharedPreferencesShortcutRepository implements ShortcutRepository {
  SharedPreferencesShortcutRepository(this._preferences);

  final SharedPreferences _preferences;

  static const String _shortcutStorageKey = 'shortcut_entries_v1';
  static const String _themePreferenceStorageKey = 'app_theme_preference_v1';

  @override
  Future<List<ShortcutEntry>> loadShortcuts() async {
    try {
      final String? raw = _preferences.getString(_shortcutStorageKey);
      if (raw == null || raw.trim().isEmpty) {
        return const <ShortcutEntry>[];
      }

      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (dynamic item) =>
                ShortcutEntry.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false);
    } catch (_) {
      throw const ShortcutStorageException(
        'Saved shortcuts could not be read from local storage.',
      );
    }
  }

  @override
  Future<void> saveShortcuts(List<ShortcutEntry> entries) async {
    try {
      final String encoded = jsonEncode(
        entries
            .map((ShortcutEntry entry) => entry.toJson())
            .toList(growable: false),
      );
      final bool saved = await _preferences.setString(
        _shortcutStorageKey,
        encoded,
      );
      if (!saved) {
        throw const ShortcutStorageException(
          'Local shortcut save was rejected.',
        );
      }
    } catch (error) {
      if (error is ShortcutStorageException) {
        rethrow;
      }
      throw const ShortcutStorageException(
        'Local shortcut save failed. Please try again.',
      );
    }
  }

  @override
  Future<AppThemePreference> loadThemePreference() async {
    final String? raw = _preferences.getString(_themePreferenceStorageKey);
    return AppThemePreference.fromStorageValue(raw);
  }

  @override
  Future<void> saveThemePreference(AppThemePreference preference) async {
    final bool saved = await _preferences.setString(
      _themePreferenceStorageKey,
      preference.storageValue,
    );
    if (!saved) {
      throw const ShortcutStorageException(
        'Theme preference could not be saved locally.',
      );
    }
  }

  static const String _layoutPreferenceStorageKey = 'app_layout_preference_v1';

  @override
  Future<AppLayoutPreference> loadLayoutPreference() async {
    final String? raw = _preferences.getString(_layoutPreferenceStorageKey);
    return AppLayoutPreference.fromStorageValue(raw);
  }

  @override
  Future<void> saveLayoutPreference(AppLayoutPreference preference) async {
    final bool saved = await _preferences.setString(
      _layoutPreferenceStorageKey,
      preference.storageValue,
    );
    if (!saved) {
      throw const ShortcutStorageException(
        'Layout preference could not be saved locally.',
      );
    }
  }

  static const String _sortPreferenceStorageKey = 'app_sort_preference_v1';

  @override
  Future<ShortcutSortPreference> loadSortPreference() async {
    final String? raw = _preferences.getString(_sortPreferenceStorageKey);
    return ShortcutSortPreference.fromStorageValue(raw);
  }

  @override
  Future<void> saveSortPreference(ShortcutSortPreference preference) async {
    final bool saved = await _preferences.setString(
      _sortPreferenceStorageKey,
      preference.storageValue,
    );
    if (!saved) {
      throw const ShortcutStorageException(
        'Sort preference could not be saved locally.',
      );
    }
  }

  static const String _favoritesFirstStorageKey = 'app_favorites_first_v1';

  @override
  Future<bool> loadFavoritesFirstPreference() async {
    return _preferences.getBool(_favoritesFirstStorageKey) ?? false;
  }

  @override
  Future<void> saveFavoritesFirstPreference(bool favoritesFirst) async {
    final bool saved = await _preferences.setBool(
      _favoritesFirstStorageKey,
      favoritesFirst,
    );
    if (!saved) {
      throw const ShortcutStorageException(
        'Favorites-first preference could not be saved locally.',
      );
    }
  }
}

class MemoryShortcutRepository implements ShortcutRepository {
  MemoryShortcutRepository([List<ShortcutEntry>? initialEntries])
    : _entries = List<ShortcutEntry>.from(
        initialEntries ?? const <ShortcutEntry>[],
      );

  List<ShortcutEntry> _entries;
  AppThemePreference _themePreference = AppThemePreference.system;
  AppLayoutPreference _layoutPreference = AppLayoutPreference.grid;
  ShortcutSortPreference _sortPreference = ShortcutSortPreference.manual;
  bool _favoritesFirst = false;

  @override
  Future<List<ShortcutEntry>> loadShortcuts() async {
    return List<ShortcutEntry>.from(_entries);
  }

  @override
  Future<void> saveShortcuts(List<ShortcutEntry> entries) async {
    _entries = List<ShortcutEntry>.from(entries);
  }

  @override
  Future<AppThemePreference> loadThemePreference() async {
    return _themePreference;
  }

  @override
  Future<void> saveThemePreference(AppThemePreference preference) async {
    _themePreference = preference;
  }

  @override
  Future<AppLayoutPreference> loadLayoutPreference() async {
    return _layoutPreference;
  }

  @override
  Future<void> saveLayoutPreference(AppLayoutPreference preference) async {
    _layoutPreference = preference;
  }

  @override
  Future<ShortcutSortPreference> loadSortPreference() async {
    return _sortPreference;
  }

  @override
  Future<void> saveSortPreference(ShortcutSortPreference preference) async {
    _sortPreference = preference;
  }

  @override
  Future<bool> loadFavoritesFirstPreference() async {
    return _favoritesFirst;
  }

  @override
  Future<void> saveFavoritesFirstPreference(bool favoritesFirst) async {
    _favoritesFirst = favoritesFirst;
  }
}
