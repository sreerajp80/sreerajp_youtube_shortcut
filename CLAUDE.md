# CLAUDE.md — Project Instructions

This file is read by Claude Code at the start of every session. Follow these instructions for
all work in this repository.

---

## Project At A Glance

- **App**: SreerajP YouTube Shortcuts (`YT Shortcuts`)
- **Framework**: Flutter 3.41.6
- **Platform**: Android only (API 24+)
- **Language**: Dart
- **State management**: `provider` + `ChangeNotifier`
- **Local storage**: `shared_preferences` (JSON)
- **No network**: The app is fully offline. `INTERNET` permission must never be added.

---

## Read These Docs Before Working

Always consult the relevant document before making changes. The `docs/` folder is the source of
truth for this project's design and standards.

| Document | Read When |
|----------|-----------|
| `docs/architecture.md` | Changing app structure, adding screens, state, services, models, or repositories |
| `docs/flutter_project_engineering_standard.md` | Any code change — governs layer boundaries, naming, testing, and code quality rules |
| `docs/flutter_build_flavors_guide.md` | Any change to build config, signing, flavors, Gradle, or ProGuard |
| `docs/release_process.md` | Building a release, updating version, running the release checklist |
| `docs/security.md` | Any change touching permissions, logging, storage, manifest, or binary protections |

---

## Architecture Rules

- **Layer boundaries** — widgets must not know about `SharedPreferences`, intent details, or URL
  parsing. Services must not know about `BuildContext` or widget state. See `docs/architecture.md §9`.
- **Tier 1 structure** — layer-first layout under `lib/`. Do not promote to Tier 2 without
  discussion. See `docs/architecture.md §4` for the full source layout.
- **Error hierarchy** — use sealed exceptions in `lib/core/errors/`. Do not throw raw strings or
  generic `Exception`. See `docs/architecture.md §10`.
- **No INTERNET** — the merged Android manifest must never contain the `INTERNET` permission.
  Audit every new dependency before adding it.

---

## Build Flavors

Two flavors: `dev` and `prod`.

| Flavor | App ID | Display Name | Signing |
|--------|--------|--------------|---------|
| `dev` | `in.sreerajp.sreerajp_youtube_shortcut.dev` | YT Shortcuts Dev | Debug keystore (automatic) |
| `prod` | `in.sreerajp.sreerajp_youtube_shortcut` | YT Shortcuts | Release keystore (`android/keystore.properties`) |

**Debug builds never need a signing key.** `prod --release` is blocked by a Gradle guard if
`android/keystore.properties` is absent.

### Common Commands

```bash
# Development — no signing setup needed
flutter run --flavor dev --dart-define=FLUTTER_APP_FLAVOR=dev

# Production debug — no signing setup needed
flutter run --flavor prod --dart-define=FLUTTER_APP_FLAVOR=prod

# Production release APK — requires android/keystore.properties
flutter build apk --flavor prod --release \
  --dart-define=FLUTTER_APP_FLAVOR=prod \
  --obfuscate \
  --split-debug-info=build/symbols/android-<version>/ \
  --split-per-abi \
  --dart-define=APP_BUILD_DATE=<YYYY-MM-DD> \
  --dart-define=APP_AI_USED=<AI_LABEL>

# Production Play Store bundle — requires android/keystore.properties
flutter build appbundle --flavor prod --release \
  --dart-define=FLUTTER_APP_FLAVOR=prod \
  --obfuscate \
  --split-debug-info=build/symbols/android-<version>/ \
  --dart-define=APP_BUILD_DATE=<YYYY-MM-DD> \
  --dart-define=APP_AI_USED=<AI_LABEL>
```

Full build hardening requirements: `docs/release_process.md §6`.

---

## Security Rules

- Never log user-entered shortcut names or YouTube URLs.
- Never add `INTERNET`, storage, or unnecessary permissions to the manifest.
- `android:allowBackup="false"` must remain in the manifest.
- All release builds require `--obfuscate` and `--split-debug-info`. See `docs/security.md §8`.
- Never commit `android/keystore.properties`, `*.jks`, or `*.keystore` — they are gitignored.

---

## Code Quality

Before proposing or merging any change, verify:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

All three must pass with zero errors and zero warnings.

---

## Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | Bootstrap, error handling, `runApp` |
| `lib/src/app_shell.dart` | App root and provider wiring |
| `lib/src/shortcut_models.dart` | Core immutable models |
| `lib/src/shortcut_store.dart` | Root `ChangeNotifier` state holder |
| `lib/src/shortcut_services.dart` | URL formatter and launcher service |
| `android/app/build.gradle.kts` | Android build config, flavors, signing |
| `android/app/proguard-rules.pro` | R8 keep rules |
| `android/app/src/main/AndroidManifest.xml` | Android manifest |
