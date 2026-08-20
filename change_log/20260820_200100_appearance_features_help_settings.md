# Change Log: Add Appearance, Features, and Help Cards & Screens Under Settings

**Plan Reference:** `plans/20260820_194700_appearance_features_help_settings.md`
**Date:** 2026-08-20

## Summary of Changes

We redesigned the Settings screen and added dedicated screens for **Appearance**, **Features**, and **Help & User Guides** based on the design pattern in `ContactSphere`.

1. **Modernized Settings Hub**:
   - Upgraded `lib/screens/settings_screen.dart` with rounded 48x48 icon cards with soft background tints.
   - Added cards for **Appearance**, **Features**, **Channel handles**, **Backup & Restore**, **Permissions**, **Help & User Guides**, **About**, and **Privacy & Security**.

2. **Dedicated Appearance Screen (`lib/screens/appearance_screen.dart`)**:
   - Added a screen to customize themes.
   - Users can select from 7 curated theme palettes (System, Light, Classic Dark, AMOLED Pure Black, Warm Sepia, Forest Dark, Cyberpunk Neon).
   - Shows live preview swatches, selection checkmarks, and theme descriptions.

3. **Comprehensive Features Screen (`lib/screens/features_screen.dart`)**:
   - Added a feature explorer with a hero card and 5 categorized sections:
     - Quick-Launch & Playback
     - Organization & Visual Styling
     - Air-Gapped QR Code System
     - Privacy, Vault & Security
     - Local Backup & Data Portability
   - Each feature item displays an icon, title, description, and highlight tags.

4. **Help & User Guides Hub and Topic Screens (`lib/screens/help/`)**:
   - `lib/screens/help/help_home_screen.dart`: Central help hub with navigation cards.
   - `lib/screens/help/getting_started_help_screen.dart`: Guide on creating and managing shortcuts.
   - `lib/screens/help/handles_routing_help_screen.dart`: Guide on channel handles and live streaming behavior.
   - `lib/screens/help/qr_sharing_help_screen.dart`: Guide on single QR codes, camera scanner, and animated backup QR streaming.
   - `lib/screens/help/privacy_security_help_screen.dart`: Guide on PIN setup, biometric unlock, and private vault gating.
   - `lib/screens/help/backup_restore_help_screen.dart`: Guide on JSON file backups, AES-256 encryption, and merge/replace restore modes.
   - `lib/screens/help/faq_troubleshooting_help_screen.dart`: Answers to common questions and troubleshooting steps.

5. **Full Localization**:
   - Added all user-facing strings to `lib/l10n/app_en.arb` with `@key` description metadata.
   - Regenerated `AppLocalizations` via `flutter gen-l10n`.

6. **Tests**:
   - Updated `test/widget_test.dart` to verify Appearance, Features, Help navigation, and existing settings options.
   - Verified that all 74 tests pass cleanly.

---

## Files Changed / Created

- `lib/l10n/app_en.arb` [MODIFY]
- `lib/screens/appearance_screen.dart` [NEW]
- `lib/screens/features_screen.dart` [NEW]
- `lib/screens/help/help_home_screen.dart` [NEW]
- `lib/screens/help/getting_started_help_screen.dart` [NEW]
- `lib/screens/help/handles_routing_help_screen.dart` [NEW]
- `lib/screens/help/qr_sharing_help_screen.dart` [NEW]
- `lib/screens/help/privacy_security_help_screen.dart` [NEW]
- `lib/screens/help/backup_restore_help_screen.dart` [NEW]
- `lib/screens/help/faq_troubleshooting_help_screen.dart` [NEW]
- `lib/screens/settings_screen.dart` [MODIFY]
- `test/widget_test.dart` [MODIFY]
- `plans/20260820_114700_appearance_features_help_settings.md` [MODIFY]
