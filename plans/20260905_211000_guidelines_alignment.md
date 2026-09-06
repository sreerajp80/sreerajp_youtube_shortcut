# Guidelines Alignment Plan

**Status:** completed

**Change log:** [../change_log/20260905_211000_guidelines_alignment.md](../change_log/20260905_211000_guidelines_alignment.md)

## Problem

A full audit against `docs/guidelines/` (`guideline.md`, `flutter_project_engineering_standard.md`, `DOCS_FOLDER_GUIDELINE.md`, `release_process.md`, `AGENTS_MD_GUIDELINE.md`, and `CLAUDE_MD_GUIDELINE.md`) revealed several discrepancies across documentation, configuration, and code:

1. **`docs/release_process.md`**:
   - Uses the forbidden `--dart-define=FLUTTER_APP_FLAVOR=...` flag in run and build commands. The Flutter SDK rejects this define and `AGENTS.md` explicitly forbids it.
   - Does not have the new guidelines from submodule update `7e664ba`: missing PowerShell build command snippets, cleartext network traffic rules (§6.5), pre-release asset secret audits (§6.6), exported component audits (§6.7), post-build APK check commands, and updated release checklist items.
   - H1 title lacks the required em dash: `# Release Process` instead of `# Release Process — SreerajP YouTube Shortcuts`.

2. **`docs/security.md`**:
   - H1 title lacks the required em dash: `# Security` instead of `# Security — SreerajP YouTube Shortcuts`.
   - Out of date with current implementation: still claims no cryptography or locking exists, even though the app implements AES-256 + PBKDF2 encrypted backups, biometric authentication (`local_auth`), and salted SHA-256 PIN hashing (`PrivacyLockStore`).
   - Omits the camera permission (`CAMERA`) used for offline QR scanning and the text share intent receiver (`android.intent.action.SEND`).

3. **`docs/architecture.md`**:
   - H1 title lacks the required em dash: `# Architecture` instead of `# Architecture — SreerajP YouTube Shortcuts`.
   - File tree is missing multiple screens (`appearance_screen.dart`, `features_screen.dart`, `help/` directory and its 7 help screens), `tool/` scripts, generated constants files (`app_version.g.dart`, `build_date.g.dart`), and widgets (`glass_add_fab.dart`, `home_states.dart`, `shortcut_card.dart`, `shortcut_filter_bar.dart`, `shortcut_grid.dart`).

4. **`docs/project_structure.md`**:
   - Missing `tool/` directory, the `help/` screens subfolder, and recent widgets in the layout tree.

5. **`docs/sreerajp_youtube_shortcut_idea.md`**:
   - Section 3 incorrectly claims `ShortcutBackupException` does not extend `AppException`. It was refactored and does extend the sealed `AppException` in `lib/core/errors/app_exception.dart`.

6. **`android/app/build.gradle.kts`**:
   - Line 204 points to `docs/flutter_build_flavors_guide.md`, which does not exist locally (it lives at `docs/guidelines/flutter_build_flavors_guide.md`).

7. **`.gitignore`**:
   - Missing an explicit `build/symbols/` line required by `AGENTS.md`.

8. **`lib/core/config/app_config.dart`**:
   - `AppConfig.fallback` has outdated version `1.3.15` and build `1`, which should align with current `1.5.3` and `24`.

## Files to be changed

- `docs/release_process.md`
- `docs/security.md`
- `docs/architecture.md`
- `docs/project_structure.md`
- `docs/sreerajp_youtube_shortcut_idea.md`
- `android/app/build.gradle.kts`
- `.gitignore`
- `lib/core/config/app_config.dart`

## Plan for the fix

1. **Update `docs/release_process.md`**:
   - Fix H1 title to `# Release Process — SreerajP YouTube Shortcuts`.
   - Remove `--dart-define=FLUTTER_APP_FLAVOR=...` from all command snippets.
   - Add PowerShell production build commands alongside Bash commands per `guideline.md §2.4`.
   - Add sections 6.5 (Network Security & Cleartext Traffic), 6.6 (Pre-Release Asset & Secret Leak Audit), and 6.7 (Exported Component Audit).
   - Add post-build APK verification commands (`aapt2`, `tar -tf / unzip`).
   - Update the release checklist with the new hardening points.

2. **Update `docs/security.md`**:
   - Fix H1 title to `# Security — SreerajP YouTube Shortcuts`.
   - Update Section 6 (Cryptography Design) to document AES-256 + PBKDF2 encryption for backup files and SHA-256 + salt for the privacy lock PIN.
   - Update Section 7 (Authentication & Access Control) to document the PIN lock, biometric authentication via `local_auth`, and lifecycle pause locking.
   - Update Section 10 & 11 (Permissions & Platform Controls) to document `android.permission.CAMERA` for QR scanning and `android.intent.action.SEND` for receiving shared YouTube URLs.

3. **Update `docs/architecture.md`**:
   - Fix H1 title to `# Architecture — SreerajP YouTube Shortcuts`.
   - Update the directory tree and component tables to include all screens (Appearance, Features, Help screens), all widgets, `tool/` scripts, and generated build constants.

4. **Update `docs/project_structure.md`**:
   - Add `tool/` directory, `screens/help/`, and missing widgets to the project tree.

5. **Update `docs/sreerajp_youtube_shortcut_idea.md`**:
   - Correct the note in Section 3 to state that `ShortcutBackupException` extends the sealed `AppException` hierarchy.

6. **Update `android/app/build.gradle.kts`**:
   - Correct the doc link in line 204 to `docs/guidelines/flutter_build_flavors_guide.md`.

7. **Update `.gitignore`**:
   - Add `build/symbols/` explicitly under symbolication rules.

8. **Update `lib/core/config/app_config.dart`**:
   - Update `AppConfig.fallback` version to `1.5.3` and build to `24`.

9. **Verification**:
   - Run `flutter analyze` to ensure zero errors or warnings.
   - Run `flutter test` to ensure all tests pass.
   - Run `dart format --output=none --set-exit-if-changed .` to ensure formatting is clean.
   - Create change log in `change_log/20260905_121000_guidelines_alignment.md`.
   - Update this plan status to `completed`.
