# Change Log — Complete and Audit docs/features.md

**Plan Reference:** `plans/20260810_082037_complete_features_doc.md`

## Summary
Audited `docs/features.md` against the Flutter codebase (`lib/src/`) to ensure complete accuracy and full feature coverage. Updated the documentation to capture missing domain model fields (`isFavorite`, `isPrivate`, `tags`), Favorites Pinning (`favoritesFirst`), custom tag filtering, tag-aware search queries, and the selection mode QR code quick action button.

## Changes Made

### Documentation
- Updated `docs/features.md`:
  - **Section 1 (App Overview & Value Pillars)**: Added mention of Favorites Pinning and custom tag organization to Power User Productivity.
  - **Section 3 (Shortcut Domain & Data Model)**: Added `isFavorite` (bool, default `false`), `isPrivate` (bool, default `false`), and `tags` (`List<String>`, default empty) to the `ShortcutEntry` field list.
  - **Section 5.1 (Home Screen)**: Documented `favoritesFirst` sorting priority, custom dynamic tag filter chips alongside category target type chips, tag-aware inline search query matching, and single-item selection bar "Show QR Code" action button.
  - **Section 5.2 (Add / Edit Shortcut Screen)**: Updated form inputs description to list custom Tags field, Favorites star toggle, Private Shortcut lock toggle, and Card Customization options (colors and icon picker).

## Verification
- Verified static analysis with `flutter analyze` (0 issues).
- Verified test suite with `flutter test` (all 70 tests passed).
