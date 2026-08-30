# Plan: Generate Build Metadata On Build and Display Build Date in About Screen

**Status:** Completed

## Problem & Goal
When running `flutter build apk` (or any Gradle build), the user wants build metadata generation scripts to run automatically:
1. `tool/generate_app_version.dart` updates `lib/core/constants/app_version.g.dart` and logs `app_version.g.dart updated → <version>`.
2. `tool/generate_build_date.dart` updates `lib/core/constants/build_date.g.dart` and logs `build_date.g.dart updated → <date>`.
3. The About screen displays the Build Date row with the value from `kBuildDate`.

---

## Files to Change

### 1. `tool/generate_app_version.dart` [NEW]
- Standalone Dart script that reads `pubspec.yaml`, extracts the `version:` string, writes `lib/core/constants/app_version.g.dart`, and prints `app_version.g.dart updated → <version>`.

### 2. `tool/generate_build_date.dart` [NEW]
- Standalone Dart script that gets today's date formatted as `YYYY-MM-DD`, writes `lib/core/constants/build_date.g.dart`, and prints `build_date.g.dart updated → <date>`.

### 3. `lib/core/constants/app_version.g.dart` [NEW]
- Generated file containing `const String kAppVersion = '1.5.3+24';`.

### 4. `lib/core/constants/build_date.g.dart` [NEW]
- Generated file containing `const String kBuildDate = '2026-08-30';`.

### 5. `android/app/build.gradle.kts` [MODIFY]
- Register the `generateBuildMetadata` Gradle task that runs both generator scripts using Dart.
- Attach `generateBuildMetadata` to `preBuild` and `compileFlutterBuild*` tasks so it runs before any Android build.

### 6. `lib/l10n/app_en.arb` [MODIFY]
- Add `aboutBuildDateLabel`: `"Build Date"` with description.

### 7. `lib/screens/about_screen.dart` [MODIFY]
- Import `lib/core/constants/build_date.g.dart`.
- Add an `_InfoRow` displaying `l10n.aboutBuildDateLabel` and `kBuildDate`.

### 8. `test/widget_test.dart` [MODIFY]
- Add test verifying that navigating to the About screen renders the Build Date row.

---

## Verification Plan
1. Run `dart run tool/generate_app_version.dart` and verify console output and generated file.
2. Run `dart run tool/generate_build_date.dart` and verify console output and generated file.
3. Run `flutter gen-l10n` to generate localized strings.
4. Run `dart format .` to format all code.
5. Run `flutter analyze` to ensure clean static analysis.
6. Run `flutter test` to verify all unit and widget tests pass.
7. Run `flutter build apk --flavor dev` or `flutter build apk --flavor prod --release --split-per-abi` to verify Gradle triggers the generator and prints the update messages.
