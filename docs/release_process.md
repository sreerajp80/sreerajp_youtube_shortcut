# Release Process — SreerajP YouTube Shortcuts

Use this document for repositories that ship builds to QA, external testers, enterprise
distribution, or public app stores.

**Read first:** [../CLAUDE.md](../CLAUDE.md) · [architecture.md](architecture.md) · [security.md](security.md) · [`docs/guidelines/release_process.md`](guidelines/release_process.md)

---

## 1. Release Scope

- App: `SreerajP YouTube Shortcuts`
- Framework: `Flutter 3.44.8`
- Release profile: `internal beta`
- Supported release platforms:
  - `Android`
- Engineering standard profiles in force:
  - `Core Baseline`

Current release scope is Android-only distribution for testing and release builds. The app supports
`dev` and `prod` build flavors.

---

## 2. Roles And Responsibilities

| Role | Responsibility | Owner |
|------|----------------|-------|
| Release owner | Coordinates release readiness and final sign-off | Developer |
| Engineering | Code freeze, fixes, validation | Developer |
| QA | Test execution and regression sign-off | Developer (self-testing) |
| Distribution owner | Uploads artifacts and manages release metadata | Developer |

---

## 3. Versioning Policy

- Version format: `MAJOR.MINOR.PATCH+BUILD`
- Source of truth: `pubspec.yaml`
- Build-number increment rule: Increment on every release artifact
- Git tag format: `vX.Y.Z`

When tagging a release in git, the tag must match the semantic version in `pubspec.yaml`.

---

## 4. Branch And Merge Policy

- Release branch strategy: `main only`
- Hotfix strategy: Patch from the released baseline and bump patch version
- Required checks before merge:
  - `dart format --output=none --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test`

---

## 5. Environment And Flavor Matrix

| Flavor | Mode | Signing | Purpose | Example Command |
|--------|------|---------|---------|-----------------|
| `dev` | `debug` | Automatic debug keystore | Local development on emulator or device | `flutter run --flavor dev` |
| `dev` | `profile` | Automatic debug keystore | Performance validation | `flutter run --profile --flavor dev` |
| `prod` | `debug` | Automatic debug keystore | Production config with debug tooling | `flutter run --flavor prod` |
| `prod` | `release apk` | Release keystore required | Internal installable artifact | See section 9 |
| `prod` | `release app bundle` | Release keystore required | Store-ready artifact | See section 9 |

Debug builds (`*--debug`) do not require `android/key.properties`. The SDK debug keystore is
applied automatically. `prod --release` is blocked by a Gradle guard if `key.properties` is
absent — see `docs/guidelines/flutter_build_flavors_guide.md §Android Signing Configuration`.

> Never pass `--dart-define=FLUTTER_APP_FLAVOR`. That name is owned by the framework and the
> current Flutter SDK rejects the build outright. `--flavor prod` sets it for you.

---

## 6. Release Build Hardening

All production release builds MUST include the following flags. Omitting any of them is a
release-blocking issue.

### 6.1 Obfuscation And Debug Symbols

```bash
--obfuscate
--split-debug-info=build/symbols/android-prod-<version>/
```

`--obfuscate` renames Dart class and method names in the compiled binary to meaningless
identifiers. This serves two purposes:
- **Security**: prevents trivial reverse engineering of application logic from the release binary.
- **Size**: reduces binary size marginally.

`--split-debug-info` extracts the debug symbol mapping to a separate directory outside the APK. This is
mandatory when `--obfuscate` is used because the symbols are required to decode stack traces
from crash reports or manual release diagnostics.

**Symbol archive policy:**
- The symbols directory MUST be archived securely after every production release build.
- Symbols MUST be retained for the lifetime of the released version.
- Symbols MUST NOT be committed to source control.
- Store them alongside the release artifact, for example `releases/v1.5.3/symbols/`.
- Without the symbols, stack traces from that version are permanently unreadable.

### 6.2 ProGuard / R8 (Android)

Android release builds run R8 code shrinking (`isMinifyEnabled = true`). Verify `proguard-rules.pro` is present and keeps:
- Flutter engine classes: `io.flutter.**`
- Any native plugin code that requires reflection keep rules

### 6.3 App Size Analysis

Run size analysis before every release to catch dependency bloat early:

```bash
flutter build apk --flavor prod --release --analyze-size
```

Record the output in the release evidence section. Compare against the previous release.
A size increase of more than 10% without a documented justification is a review item.

Size budgets:

| Platform | Target | Hard Limit |
|----------|--------|------------|
| Android APK arm64 | < 15 MB | 25 MB |

### 6.4 Debuggable Verification (Android)

Verify that `android:debuggable` is `false` in the merged release manifest before every
production release. A debuggable production build is a security vulnerability and a Google Play
policy violation.

Check via `aapt2`:

```bash
aapt2 dump badging build/app/outputs/apk/prod/release/app-arm64-v8a-prod-release.apk | grep -i debuggable
```

Expected output: no `application-debuggable` line present.

### 6.5 Network Security Configuration And Cleartext Traffic

Verify that cleartext HTTP traffic is disabled for production builds:
- `android:usesCleartextTraffic="false"` is enforced in `AndroidManifest.xml`.
- The app has no network access and declares no `INTERNET` permission in production.

### 6.6 Pre-Release Asset And Secret Leak Audit

While `--obfuscate` scrambles compiled Dart logic in `libapp.so`, **files in the APK's `assets/` and `res/` directories remain completely unencrypted**. Any party with access to the APK can inspect its contents with `unzip` or `tar`.

Before releasing, audit the bundled assets in the APK:

```bash
# bash / zsh
unzip -l build/app/outputs/apk/prod/release/app-arm64-v8a-prod-release.apk "assets/*"
```

```powershell
# PowerShell (Windows)
tar -tf build\app\outputs\apk\prod\release\app-arm64-v8a-prod-release.apk | Select-String "assets/"
```

**Audit checklist:**
- [ ] No `.env`, secret credentials, or private keys are packaged in `assets/`.
- [ ] Only declared runtime config (`assets/config/app_config.json`) is included.

### 6.7 Exported Component Audit

Inspect all declared activities, services, and broadcast receivers in the merged manifest:
- Every component with an `<intent-filter>` must have an explicit `android:exported` attribute.
- Components intended strictly for internal app usage MUST specify `android:exported="false"`.
- `MainActivity` has `android:exported="true"` for launcher and `SEND` intent actions.

---

## 7. Signing And Secret Handling

- Signing config location: `android/key.properties` pointing to `android/<name>.jks`
- Keystore or certificate ownership: Developer
- Secret rotation process: Manual rotation as needed
- Rules:
  - Signing material must not live in source control.
  - `key.properties`, `*.jks`, and `*.keystore` must be git-ignored.
  - Keystore files MUST be backed up in at least two separate secure locations.

---

## 8. Release Checklist

Complete these items before every release.

### Code And Quality

- [ ] Local Flutter SDK is `3.44.8`.
- [ ] `flutter pub get` completed successfully.
- [ ] `dart format --output=none --set-exit-if-changed .` passed.
- [ ] `flutter analyze` passed with zero warnings.
- [ ] `flutter test` passed.
- [ ] No critical or release-blocking bugs remain open.

### Performance

- [ ] Release build profiled for startup and primary list interaction.
- [ ] App size analyzed and within budget (see section 6.3).
- [ ] Startup time verified under 2 seconds on a representative Android device.

### Security

- [ ] `--obfuscate` and `--split-debug-info` applied to all release builds.
- [ ] Debug symbols archived securely for this version.
- [ ] ProGuard / R8 configuration verified (`proguard-rules.pro`).
- [ ] `android:debuggable=false` confirmed in the merged release manifest.
- [ ] `android:allowBackup=false` verified in the merged release manifest.
- [ ] Cleartext traffic disabled (`usesCleartextTraffic=false`).
- [ ] Pre-release asset audit passed — no secrets bundled in APK `assets/` (§6.6).
- [ ] Manifest component export audit completed — only expected components exported (§6.7).
- [ ] Manifest review completed: no `INTERNET` permission in release.
- [ ] OWASP Mobile Top 10 checklist reviewed (see `docs/security.md`).
- [ ] No user-entered YouTube URLs or shortcut names are logged in production code.

### Product And Documentation

- [ ] Version in `pubspec.yaml` updated.
- [ ] About-screen metadata in `assets/config/app_config.json` updated to match `pubspec.yaml`.
- [ ] Build metadata generated (`dart run tool/generate_app_version.dart` and `dart run tool/generate_build_date.dart`).
- [ ] Supported YouTube URL formats documented.
- [ ] Release notes updated.

### Artifact Validation

- [ ] Intended release artifact built successfully.
- [ ] Artifact installs and launches correctly on a clean device or emulator.
- [ ] Existing shortcuts still load after app restart.
- [ ] Creating shortcuts from representative URL shapes succeeds.
- [ ] Invalid or unsupported URLs are rejected with a clear error.
- [ ] Tapping a shortcut opens the YouTube app on a device where YouTube is installed.
- [ ] About screen displays the expected metadata values.

---

## 9. Android Release Steps

1. Verify the local SDK is Flutter `3.44.8` with `flutter --version`.
2. Confirm the git tree is clean and on the intended release commit.
3. Confirm the version in `pubspec.yaml` and `assets/config/app_config.json`.
4. Run pre-build metadata generation:
   - `dart run tool/generate_app_version.dart`
   - `dart run tool/generate_build_date.dart`
5. Fetch dependencies: `flutter pub get`.
6. Run format, analyze, and test checks.
7. Build the release APK and AAB with all hardening flags.
8. Run size analysis and record the result.
9. Verify `android:debuggable=false` and `android:allowBackup=false` in the merged manifest.
10. Perform pre-release asset extraction audit (§6.6).
11. Install the artifact on a clean Android device or emulator with YouTube.
12. Validate the end-to-end flow:
    - add a shortcut from a standard watch URL
    - add a shortcut from a `youtu.be` short URL
    - add a shortcut from Shorts, playlist, and channel URLs
    - tap each shortcut and confirm the YouTube app receives the launch
13. Open the About screen and confirm author, version, build number, and build date.
14. Archive the built artifact and debug symbols from `build/symbols/` to secure storage.
15. Tag the release: `git tag v<version>` and push.

### Android Build Commands & Examples

#### Bash / macOS / Linux

```bash
# 1. Pre-build checks & metadata generation
flutter pub get
dart run tool/generate_app_version.dart
dart run tool/generate_build_date.dart
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test

# 2. Extract version from pubspec.yaml
VERSION=$(grep '^version:' pubspec.yaml | cut -d' ' -f2)

# 3. Build Split APKs for direct distribution
flutter build apk \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info=build/symbols/android-prod-$VERSION/ \
  --split-per-abi \
  --dart-define=APP_AI_USED="Anthropic Claude, Google Gemini"

# 4. Build App Bundle for Google Play Store
flutter build appbundle \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info=build/symbols/android-prod-$VERSION/ \
  --dart-define=APP_AI_USED="Anthropic Claude, Google Gemini"

# 5. Size analysis
flutter build apk --flavor prod --release --analyze-size
```

#### PowerShell (Windows)

```powershell
# 1. Pre-build checks & metadata generation
flutter pub get
dart run tool/generate_app_version.dart
dart run tool/generate_build_date.dart
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test

# 2. Extract version from pubspec.yaml
$VERSION = (Get-Content pubspec.yaml | Select-String '^version:').ToString().Split(' ')[1].Trim()

# 3. Build Split APKs for direct distribution
flutter build apk `
  --flavor prod `
  --release `
  --obfuscate `
  --split-debug-info="build/symbols/android-prod-$VERSION/" `
  --split-per-abi `
  --dart-define=APP_AI_USED="Anthropic Claude, Google Gemini"

# 4. Build App Bundle for Google Play Store
flutter build appbundle `
  --flavor prod `
  --release `
  --obfuscate `
  --split-debug-info="build/symbols/android-prod-$VERSION/" `
  --dart-define=APP_AI_USED="Anthropic Claude, Google Gemini"

# 5. Size analysis
flutter build apk --flavor prod --release --analyze-size
```

#### Post-Build APK Verification Commands

```bash
# Verify no debuggable flag and verify allowBackup=false
aapt2 dump badging build/app/outputs/apk/prod/release/app-arm64-v8a-prod-release.apk | grep -i debuggable
aapt2 dump xmltree build/app/outputs/apk/prod/release/app-arm64-v8a-prod-release.apk --file AndroidManifest.xml | grep -i allowBackup

# Audit asset bundle for unencrypted secrets
unzip -l build/app/outputs/apk/prod/release/app-arm64-v8a-prod-release.apk "assets/*"
```

```powershell
# Windows PowerShell asset audit
tar -tf build\app\outputs\apk\prod\release\app-arm64-v8a-prod-release.apk | Select-String "assets/"
```

---

## 10. iOS Release Steps

Not applicable (Android only).

---

## 11. Windows Release Steps

Not applicable (Android only).

---

## 12. Distribution Channels

| Channel | Artifact | Audience | Notes |
|---------|----------|----------|-------|
| Direct APK | APK | Internal testers / developer devices | Primary v1 path |
| Google Play Internal Testing | AAB | Optional later step | Use only after package naming, signing, and store copy are finalized |

---

## 13. Rollback And Hotfix Process

- Rollback trigger: Launch regression, broken shortcut persistence, or failure to open YouTube app
- Rollback method: Stop distribution of the affected APK / pause any store rollout
- Hotfix branch naming: `hotfix-vX.Y.Z`
- Verification after rollback or hotfix:
  - Full release checklist MUST be completed even for hotfixes.
  - Debug symbols for the hotfix build MUST be archived.

---

## 14. Release Evidence

Store links or references to release evidence here after each release.

- Flutter version check: Local terminal output
- Test report: Local `flutter test` output
- Size analysis output: Local logs
- Manifest verification: Local inspection notes or screenshots
- Debug symbols archive: Local secure storage
- Built artifact: Local APK/AAB archive
- Manual validation notes: Shortcut creation and launch checks
- About-screen validation: Local screenshot or note
- Release notes: Local changelog or store draft

---

## 15. Post-Release Checks

- [ ] Smoke test completed on a clean install.
- [ ] Shortcut persistence verified after relaunch.
- [ ] Any user-reported issues triaged.
- [ ] Release tag created and pushed if git tracking is active.
- [ ] Debug symbols confirmed in secure archive.
- [ ] Follow-up tasks recorded.
