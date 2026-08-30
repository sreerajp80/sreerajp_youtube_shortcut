# Change Log: Generate Build Metadata On Build and Display Build Date in About Screen

**Plan Reference:** `plans/20260830_112500_generate_build_metadata_and_show_build_date.md`
**Date:** 2026-08-30

## Summary of Changes

We added automatic generation of build metadata constants during Android builds and displayed the build date on the About screen.

1. **Build Metadata Generator Scripts**:
   - Added `tool/generate_app_version.dart`: Extracts the version string from `pubspec.yaml` and writes `lib/core/constants/app_version.g.dart` with `kAppVersion`, printing `app_version.g.dart updated → <version>`.
   - Added `tool/generate_build_date.dart`: Gets today's date formatted as `YYYY-MM-DD` and writes `lib/core/constants/build_date.g.dart` with `kBuildDate`, printing `build_date.g.dart updated → <date>`.

2. **Android Gradle Task Integration**:
   - Configured `generateBuildMetadata` task in `android/app/build.gradle.kts`.
   - Hooked `generateBuildMetadata` to run before Android builds (`preBuild` and `compileFlutterBuild*`).

3. **About Screen & Localization**:
   - Added `aboutBuildDateLabel` (`"Build Date"`) to `lib/l10n/app_en.arb` and regenerated `AppLocalizations`.
   - Updated `lib/screens/about_screen.dart` to display the Build Date row using `kBuildDate`.

4. **Testing and Verification**:
   - Updated `test/widget_test.dart` to verify that the About screen renders the Version and Build Date rows.
   - Ran `flutter analyze` with 0 issues and `flutter test` with all 74 tests passing.
   - Built the dev APK to confirm Gradle automatically triggers the generators and outputs update messages to the terminal.

---

## Files Changed / Created

- `tool/generate_app_version.dart` [NEW]
- `tool/generate_build_date.dart` [NEW]
- `lib/core/constants/app_version.g.dart` [NEW]
- `lib/core/constants/build_date.g.dart` [NEW]
- `android/app/build.gradle.kts` [MODIFY]
- `lib/l10n/app_en.arb` [MODIFY]
- `lib/l10n/app_localizations.dart` [MODIFY]
- `lib/l10n/app_localizations_en.dart` [MODIFY]
- `lib/screens/about_screen.dart` [MODIFY]
- `test/widget_test.dart` [MODIFY]
- `plans/20260830_112500_generate_build_metadata_and_show_build_date.md` [MODIFY]
