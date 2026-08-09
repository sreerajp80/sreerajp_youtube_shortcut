# Implementation Plan - Category A: Advanced Organization, Tagging & Favorites

**Status:** Proposed

## Overview
Implement Category A features from `docs/potential_features.md`:
1. **Custom User Tags & Category Management**: Custom tags (`#Tech`, `#Music`, `#News`, `#Education`, `#Personal`, etc.) for shortcuts with multi-select tag filter chips on the Home Screen.
2. **Pinned Favorites**: One-tap star/pin action on shortcut cards and a "Favorites first" sorting toggle.

---

## Files to Modify

1. **`lib/src/shortcut_models.dart`**
   - Add `isFavorite` (`bool`, default `false`) and `tags` (`List<String>`, default `const <String>[]`) to `ShortcutEntry`.
   - Update `toJson()`, `fromJson()`, and `copyWith()`.

2. **`lib/src/shortcut_repository.dart`**
   - Add `loadFavoritesFirstPreference()` and `saveFavoritesFirstPreference(bool favoritesFirst)` interface methods and implementations in `SharedPreferencesShortcutRepository` and `MemoryShortcutRepository`.

3. **`lib/src/shortcut_store.dart`**
   - Add `favoritesFirst` state and toggle method `setFavoritesFirst(bool value)`.
   - Add `toggleFavorite(String id)` method.
   - Update `_applySort(...)` to prioritize favorites when `favoritesFirst` is true.
   - Update `addShortcut` and `updateShortcut` to support `tags` and `isFavorite`.

4. **`lib/src/youtube_url_formatter.dart`**
   - Update `createEntry` and `updateEntry` methods to preserve/pass `tags` and `isFavorite`.

5. **`lib/src/screens/add_shortcut_screen.dart`**
   - Add custom tag input field with quick-select chip suggestions (`#Tech`, `#Music`, `#News`, `#Education`, `#Personal`).
   - Add favorite toggle option.

6. **`lib/src/screens/shortcut_detail_screen.dart`**
   - Display tags as chips.
   - Add star/favorite action button in App Bar and detail summary.
   - Allow editing tags and favorite status.

7. **`lib/src/screens/home_screen.dart`**
   - Add tag filter chips in home screen header alongside existing target type chips.
   - Include tag matching in search filter.
   - Add 1-tap star/pin action button on grid and list shortcut cards.
   - Add "Favorites first" toggle in sort menu.

8. **`docs/potential_features.md`**
   - Mark Category A features as implemented.

9. **`test/` suite**
   - Add tests for shortcut tags, favorite toggling, and favorites-first sorting.

---

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero errors/warnings.
- Run `flutter test` to ensure all existing and new unit tests pass cleanly.

### Manual Verification
- Create a shortcut with custom tags and favorite toggle.
- Toggle favorite star on shortcut cards in home screen grid and list view.
- Filter shortcuts by multi-select tag chips.
- Toggle "Favorites first" option in sort menu and verify pinned items remain at top.
