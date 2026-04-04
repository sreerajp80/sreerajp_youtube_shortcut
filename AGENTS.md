# AGENTS.md — Project Instructions For AI Coding Agents

This file is read by AI coding agents (Codex, Copilot, Cursor, and others) at the start of
every session. Follow these instructions for all work in this repository.

---

## Project Summary

- **App**: SreerajP YouTube Shortcuts (`YT Shortcuts`)
- **Framework**: Flutter 3.41.6 / Dart
- **Platform**: Android only (API 24 minimum)
- **State management**: `provider` + `ChangeNotifier`
- **Local storage**: `shared_preferences` (versioned JSON)
- **Network**: None. The app is fully offline. `INTERNET` permission must never be added.

---

## Required Reading Before Making Changes

The `docs/` folder contains the authoritative design documents for this project. Read the
relevant document before proposing or applying any change.

| Document | When To Read |
|----------|--------------|
| `docs/architecture.md` | Any structural change: new files, layers, screens, models, services, or repositories |
| `docs/flutter_project_engineering_standard.md` | Any code change — defines layer rules, naming conventions, and testing requirements |
| `docs/flutter_build_flavors_guide.md` | Changes to Gradle, build types, flavors, signing, or ProGuard |
| `docs/release_process.md` | Release builds, version bumps, build commands, and release checklist |
| `docs/security.md` | Permissions, logging policy, manifest, storage, and binary protections |

Do not propose code changes that conflict with these documents without noting the conflict
explicitly and explaining the reason for deviating.

---

## Architecture Constraints

- **Layer-first structure** (`lib/`): screens, widgets, state, services, models, repositories,
  core. See `docs/architecture.md §4` for the canonical source layout.
- **Layer boundaries**: widgets must not import `SharedPreferences`, intent details, or URL
  parsing logic. Services must not import `BuildContext` or widget state.
- **Error handling**: use sealed exceptions from `lib/core/errors/`. Do not throw raw strings.
- **No analytics or HTTP**: any dependency that introduces network traffic, analytics SDKs, or
  transitive `INTERNET` usage is forbidden. Audit `pubspec.lock` and the merged manifest.

---

## Build Flavors

| Flavor | App ID | Display Name | Needs Signing Key? |
|--------|--------|--------------|-------------------|
| `dev` | `in.sreerajp.sreerajp_youtube_shortcut.dev` | YT Shortcuts Dev | No — debug keystore is automatic |
| `prod` | `in.sreerajp.sreerajp_youtube_shortcut` | YT Shortcuts | Yes for `--release` only |

`prod --release` is hard-blocked by a Gradle guard if `android/keystore.properties` is absent.
Debug builds (`--debug`) always work without any signing setup.

### Run Commands

```bash
# Dev debug (no setup needed)
flutter run --flavor dev --dart-define=FLUTTER_APP_FLAVOR=dev

# Prod release APK (requires android/keystore.properties)
flutter build apk --flavor prod --release \
  --dart-define=FLUTTER_APP_FLAVOR=prod \
  --obfuscate \
  --split-debug-info=build/symbols/android-<version>/ \
  --split-per-abi \
  --dart-define=APP_BUILD_DATE=<YYYY-MM-DD> \
  --dart-define=APP_AI_USED=<AI_LABEL>
```

---

## Security Rules — Non-Negotiable

- Never add `INTERNET` or any network permission to the manifest.
- Never log user-entered shortcut names or YouTube URLs.
- `android:allowBackup="false"` must remain in `AndroidManifest.xml`.
- All release builds must include `--obfuscate` and `--split-debug-info`.
- Never commit `android/keystore.properties`, `*.jks`, or `*.keystore`.

---

## Code Quality Gates

Every proposed change must pass:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Do not propose changes that introduce analyzer warnings or failing tests.

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `lib/main.dart` | Entry point, bootstrap, global error handling |
| `lib/src/app_shell.dart` | App root, `MultiProvider`, routing |
| `lib/src/shortcut_models.dart` | Immutable domain models |
| `lib/src/shortcut_store.dart` | Root `ChangeNotifier` |
| `lib/src/shortcut_services.dart` | URL formatter, YouTube launcher service |
| `android/app/build.gradle.kts` | Flavors, signing config, ProGuard, R8 |
| `android/app/proguard-rules.pro` | R8 keep rules for Flutter engine |
| `android/app/src/main/AndroidManifest.xml` | Android manifest |
| `docs/architecture.md` | System design, layer rules, decisions log |
| `docs/security.md` | Security objectives, threat model, logging policy |
| `docs/release_process.md` | Release checklist, build commands, versioning |
| `docs/flutter_build_flavors_guide.md` | Signing setup, flavor configuration reference |
