# Release Process

Use this document for repositories that ship builds to QA, external testers, enterprise
distribution, or public app stores.

If the repository is not release-tracked yet, keep this file short and mark the current release
scope clearly.

---

## 1. Release Scope

- App: `SreerajP YouTube Shortcuts`
- Framework: `Flutter 3.44.8`
- Release profile: `internal beta`
- Supported release platforms:
  - `Android`
- Engineering standard profiles in force:
  - `Core Baseline`

Current v1 release scope is Android-only distribution for developer testing and small internal
validation. The app is single-environment and ships without build flavors.

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

If git tagging is introduced later, the tag must match the semantic version in `pubspec.yaml`.

---

## 4. Branch And Merge Policy

- Release branch strategy: `main only`
- Hotfix strategy: Patch from the released baseline and bump patch version
- Required checks before merge:
  - `dart format --output=none --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test`

Current note: the workspace was not git-tracked on `2026-04-03`. Initialize source control before
the first externally shared release.

---

## 5. Environment And Flavor Matrix

| Flavor | Mode | Signing | Purpose | Example Command |
|--------|------|---------|---------|-----------------|
| `dev` | `debug` | Automatic debug keystore | Local development on emulator or device | `flutter run --flavor dev --dart-define=FLUTTER_APP_FLAVOR=dev` |
| `dev` | `profile` | Automatic debug keystore | Performance validation | `flutter run --profile --flavor dev --dart-define=FLUTTER_APP_FLAVOR=dev` |
| `prod` | `debug` | Automatic debug keystore | Production config with debug tooling | `flutter run --flavor prod --dart-define=FLUTTER_APP_FLAVOR=prod` |
| `prod` | `release apk` | Release keystore required | Internal installable artifact | See section 9 |
| `prod` | `release app bundle` | Release keystore required | Store-ready artifact | See section 9 |

Debug builds (`*--debug`) do not require `android/keystore.properties`. The SDK debug keystore is
applied automatically. `prod --release` is blocked by a Gradle guard if `keystore.properties` is
absent — see `docs/flutter_build_flavors_guide.md §Android Signing Configuration`.

---

## 6. Release Build Hardening

All production release builds MUST include the following flags. Omitting any of them is a
release-blocking issue.

### 6.1 Obfuscation And Debug Symbols

```bash
--obfuscate
--split-debug-info=build/symbols/android-<version>/
```

`--obfuscate` renames Dart class and method names in the compiled binary to meaningless
identifiers. This serves two purposes:
- **Security**: prevents trivial reverse engineering of application logic from the release binary.
- **Size**: reduces binary size marginally.

`--split-debug-info` extracts the debug symbol mapping to a separate directory. This is
mandatory when `--obfuscate` is used because the symbols are required to decode stack traces
from crash reports or manual release diagnostics.

**Symbol archive policy:**
- The symbols directory MUST be archived securely after every production release build.
- Symbols MUST be retained for the lifetime of the released version.
- Symbols MUST NOT be committed to source control.
- Store them alongside the release artifact, for example `releases/v1.2.3/symbols/`.
- Without the symbols, stack traces from that version are permanently unreadable.

### 6.2 ProGuard / R8 (Android)

Android release builds run R8 code shrinking. Verify `proguard-rules.pro` is present and keeps:
- Flutter engine classes: `io.flutter.**`
- Any native plugin code that later proves to require reflection keep rules

Expected v1 plugin set is small (`android_intent_plus`, `package_info_plus`,
`shared_preferences`). No custom reflection-heavy Android SDK is planned.

### 6.3 App Size Analysis

Run size analysis before every release to catch dependency bloat early:

```bash
flutter build apk --release --analyze-size
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
aapt2 dump badging build/app/outputs/flutter-apk/app-release.apk | grep -i debuggable
```

Expected output: no `application-debuggable` line present.

### 6.5 Manifest Review (Android)

Verify the merged release manifest before every production release:

- `INTERNET` permission is absent
- No unnecessary permissions are declared
- `android:allowBackup="false"` is present
- Only the launcher activity is exported
- `usesCleartextTraffic` remains disabled or absent

Because the app is offline-only, any accidental network permission is release-blocking.

---

## 7. Signing And Secret Handling

- Signing config location: Local keystore for development; secured release keystore for external
  distribution
- Keystore or certificate ownership: Developer
- Secret rotation process: Manual rotation as needed
- Rules:
  - Signing material must not live in source control.
  - Local signing helpers must not expose secrets in committed files.
  - CI or local logs must not print signing secrets.
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
- [ ] ProGuard / R8 configuration reviewed.
- [ ] `android:debuggable=false` confirmed in the merged release manifest.
- [ ] Manifest review completed: no `INTERNET`, no unnecessary permissions,
      `android:allowBackup=false`.
- [ ] OWASP Mobile Top 10 checklist reviewed (see `docs/security.md`).
- [ ] No user-entered YouTube URLs or shortcut names are logged in production code.

### Product And Documentation

- [ ] Version in `pubspec.yaml` updated.
- [ ] About-screen metadata updated or verified:
      author, version, build number, build date, AI-used label.
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
2. If git is active, pull the intended release commit and verify the tree is clean.
3. Confirm the version in `pubspec.yaml`.
4. Set the release metadata value for the AI-used label (build date is auto-generated at build time).
5. Fetch dependencies: `flutter pub get`.
6. Run format, analyze, and test checks.
7. Build the release APK and AAB with all hardening flags.
8. Run size analysis and record the result.
9. Review the merged manifest for `android:debuggable=false`, no `INTERNET`, and
   `android:allowBackup=false`.
10. Install the artifact on a clean Android device or emulator that has the YouTube app.
11. Validate the end-to-end flow:
    - add a shortcut from a standard watch URL
    - add a shortcut from a `youtu.be` short URL
    - add a shortcut from a Shorts or playlist URL if supported in the build
    - tap each shortcut and confirm the YouTube app receives the launch
12. Open the About screen and confirm author, version, build number, build date, and AI-used.
13. Archive the built artifact, debug symbols, and validation notes.
14. If git is active, tag the release: `git tag v<version>` and push it.

### Android Build Commands

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test

flutter build apk \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info=build/symbols/android-<version>/ \
  --split-per-abi \
  --tree-shake-icons \
  --dart-define=FLUTTER_APP_FLAVOR=prod \
  --dart-define=APP_AI_USED=<AI_LABEL>

flutter build appbundle \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info=build/symbols/android-<version>/ \
  --tree-shake-icons \
  --dart-define=FLUTTER_APP_FLAVOR=prod \
  --dart-define=APP_AI_USED=<AI_LABEL>

flutter build apk --flavor prod --release --analyze-size
```

If build metadata should also be configurable by build system, add:

```bash
--dart-define=APP_AUTHOR=<AUTHOR_LABEL>
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


