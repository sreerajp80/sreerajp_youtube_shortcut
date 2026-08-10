# Plan: Enhanced Visual Customization & Themes

**Status:** Pending Approval

## Problem & Goal
The app currently provides basic Light, Dark, and System theme preferences, and shortcuts use auto-generated letters and default color palettes for card avatars. To enhance visual customization and deliver a premium user experience inspired by SreerajP_Devi and chronotune-smart-clock, we will implement:
1. **Expanded Theme System**: Add curated dark and themed color schemes (AMOLED Pure Black, Warm Sepia, Forest Dark, Cyberpunk Neon) alongside System, Light, and Classic Dark.
2. **Custom Card Accent Colors & Custom Icons**: Allow users to pick custom background colors and icons for shortcut cards in Add/Edit shortcut screens so launcher cards are immediately distinct.

## Files to Change

### 1. `lib/src/shortcut_models.dart`
- Expand `AppThemePreference` enum values: `system`, `light`, `dark`, `amoled`, `warmSepia`, `forestDark`, `cyberpunkNeon`.
- Update `AppThemePreference.fromStorageValue` mapping.
- Add optional fields `customColorHex` (`String?`) and `customIconName` (`String?`) to `ShortcutEntry`.
- Update `copyWith`, `toJson`, and `fromJson` methods in `ShortcutEntry`.

### 2. `lib/src/app_shell.dart`
- Update theme builder to handle all curated theme options (`light`, `dark`, `amoled`, `warmSepia`, `forestDark`, `cyberpunkNeon`).
- Define distinct color palettes for AMOLED (pure black `#000000`), Warm Sepia (creamy parchment `#FBF0D9`), Forest Dark (deep pine `#0B1A15`), and Cyberpunk Neon (synth night `#0A0915`).
- Ensure `MaterialApp` theme mapping correctly sets theme and darkTheme based on the active theme preference.

### 3. `lib/src/shortcut_store.dart`
- Update `addShortcut` and `updateShortcut` methods to accept optional `customColorHex` and `customIconName` parameters and pass them to `ShortcutEntry`.

### 4. `lib/src/screens/settings_screen.dart`
- Upgrade Appearance section to present a rich Theme Picker for selecting among the 7 theme preferences with title badges and descriptions.

### 5. `lib/src/screens/add_shortcut_screen.dart`
- Add a custom accent color picker section with curated preset swatches and a clear option.
- Add a custom card icon picker section with curated icon options (e.g., Default/Initials, Play, Star, Music, Game, Code, TV, Flame, Headphones, Bookmark, Video, Heart, Lightning, Sparkles).
- Add live avatar preview in card header displaying chosen color and icon.

### 6. `lib/src/screens/home_screen.dart` & `lib/src/screens/shortcut_detail_screen.dart`
- Update `_ShortcutCard` avatar rendering: parse `customColorHex` when present and render `customIconName` icon when set (fallback to initials/auto-palette if null).
- Update `ShortcutDetailScreen` header avatar to render custom accent color and icon.

### 7. `test/shortcut_store_test.dart` & `test/widget_test.dart`
- Add tests for `customColorHex` and `customIconName` JSON serialization and copyWith.
- Add tests for new theme preference selection in `ShortcutStore` and UI settings.

## Verification Plan
1. Run `flutter analyze` to ensure zero static analysis warnings.
2. Run `flutter test` to verify all unit and widget tests pass.
