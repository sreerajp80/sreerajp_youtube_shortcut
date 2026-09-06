# Guidelines Alignment Change Log

**Plan:** [../plans/20260905_211000_guidelines_alignment.md](../plans/20260905_211000_guidelines_alignment.md)

**Date:** 2026-09-05

## What Changed

1. **`docs/release_process.md`**:
   - Updated H1 title to `# Release Process — SreerajP YouTube Shortcuts` per `DOCS_FOLDER_GUIDELINE.md`.
   - Removed deprecated/forbidden `--dart-define=FLUTTER_APP_FLAVOR=...` parameter from all commands and examples.
   - Added Windows PowerShell build snippets alongside Bash examples.
   - Incorporated new hardening sections: Network Security & Cleartext Traffic (§6.5), Pre-Release Asset & Secret Leak Audit (§6.6), Exported Component Audit (§6.7), and post-build verification commands (`aapt2`, `unzip` / `tar -tf`).
   - Updated the release checklist to include all new security and hardening verification steps.

2. **`docs/security.md`**:
   - Updated H1 title to `# Security — SreerajP YouTube Shortcuts`.
   - Fully documented AES-256-CBC and PBKDF2 encryption for backups.
   - Documented salted SHA-256 PIN hashing and biometric authentication (`local_auth`) in `PrivacyLockStore`.
   - Documented the `android.permission.CAMERA` permission used for offline QR scanning and `android.intent.action.SEND` for capturing shared URLs.
   - Updated the OWASP Mobile Top 10 compliance table to reflect implemented features.

3. **`docs/architecture.md`**:
   - Updated H1 title to `# Architecture — SreerajP YouTube Shortcuts`.
   - Updated directory overview and component lists to include `appearance_screen.dart`, `features_screen.dart`, `help/` screens directory, `tool/` scripts, and all UI widgets (`glass_add_fab.dart`, `home_states.dart`, `shortcut_card.dart`, `shortcut_filter_bar.dart`, `shortcut_grid.dart`).
   - Removed obsolete `--dart-define=FLUTTER_APP_FLAVOR` references.

4. **`docs/project_structure.md`**:
   - Updated directory overview to include `tool/`, `screens/help/`, and complete widgets list.

5. **`docs/sreerajp_youtube_shortcut_idea.md`**:
   - Corrected Section 3 error notes to reflect that `ShortcutBackupException` extends the sealed `AppException` in `lib/core/errors/app_exception.dart`.

6. **`android/app/build.gradle.kts`**:
   - Corrected documentation path link in line 204 to point to `docs/guidelines/flutter_build_flavors_guide.md`.

7. **`.gitignore`**:
   - Added explicit `build/symbols/` entry under symbolication rules.

8. **`lib/core/config/app_config.dart`**:
   - Aligned `AppConfig.fallback` version (`1.5.3`), build number (`24`), and details map with `app_config.json` and `pubspec.yaml`.

9. **`lib/core/constants/build_date.g.dart`**:
   - Refreshed generated build date to `2026-09-05` via `tool/generate_build_date.dart`.

## Verification

- `dart format --output=none --set-exit-if-changed .`: Passed (clean formatting across all 59 files).
- `flutter analyze`: Passed with zero issues.
- `flutter test`: Passed with all 74 tests passing.
