# SreerajP YouTube Shortcuts

`SreerajP YouTube Shortcuts` is an Android-only Flutter app that lets you save named YouTube shortcuts locally and open them directly in the installed YouTube app.

The app is intentionally offline-first and lightweight:
- no app-managed HTTP client
- no analytics SDK
- no cloud sync
- local JSON persistence in `SharedPreferences`

## What The App Does

- Create a shortcut with:
  - a custom shortcut name
  - a YouTube URL or channel handle
- Normalize supported inputs into canonical YouTube URLs
- Save shortcuts locally on-device
- Open shortcuts via explicit Android intent to `com.google.android.youtube`
- Edit, delete, and clear shortcuts
- Show About metadata:
  - author
  - app version/build number
  - build date
  - AI-used label

## Supported Input Formats

The formatter accepts and normalizes these inputs:

- Bare handle:
  - `MyChannel` -> `https://www.youtube.com/@MyChannel/live`
- `@handle`:
  - `@MyChannel` -> `https://www.youtube.com/@MyChannel/live`
- `youtu.be` short links:
  - `https://youtu.be/abc123` -> `https://www.youtube.com/watch?v=abc123`
- `watch` URLs:
  - `https://www.youtube.com/watch?v=abc123`
- `live` URLs:
  - `https://www.youtube.com/live/abc123` -> `https://www.youtube.com/watch?v=abc123`
- `shorts` URLs:
  - `https://www.youtube.com/shorts/xyz987`
- `playlist` URLs:
  - `https://www.youtube.com/playlist?list=PL...`
- Channel-style URLs:
  - `/@handle/...`
  - `/channel/<id>`
  - `/c/<name>`
  - `/user/<name>`

Supported hosts:
- `youtube.com`
- `www.youtube.com`
- `m.youtube.com`
- `music.youtube.com`
- `youtube-nocookie.com`
- `www.youtube-nocookie.com`
- `youtu.be`

Unsupported or malformed links are rejected with user-safe validation messages.

## Core Behavior Rules

- Shortcut names must be unique (case-insensitive).
- Shortcuts are sorted by most recently updated.
- Data is stored under a versioned key: `shortcut_entries_v1`.
- If YouTube is missing or disabled, launch errors are shown without crashing.

## Tech Stack

- Flutter `3.41.6`
- Dart SDK `^3.11.4`
- Android minimum SDK `24`
- State management: `provider` + `ChangeNotifier`
- Storage: `shared_preferences`
- Launch intents: `android_intent_plus`
- Build/app info: `package_info_plus` + Android `MethodChannel`

## Project Structure

```text
lib/
|-- main.dart
`-- src/
    |-- about_constants.dart
    |-- app_shell.dart
    |-- shortcut_models.dart
    |-- shortcut_repository.dart
    |-- shortcut_store.dart
    |-- youtube_launcher_service.dart
    |-- youtube_url_formatter.dart
    `-- screens/
        |-- home_screen.dart
        |-- add_shortcut_screen.dart
        |-- about_screen.dart
        `-- fatal_error_screen.dart
```

## Build Flavors

| Flavor | App ID | Display Name | Typical Use | Signing |
|--------|--------|--------------|-------------|---------|
| `dev` | `in.sreerajp.sreerajp_youtube_shortcut.dev` | `YT Shortcuts Dev` | Local dev and QA | Debug keystore (automatic for debug) |
| `prod` | `in.sreerajp.sreerajp_youtube_shortcut` | `YT Shortcuts` | Release artifacts | Release keystore required for `prod --release` |

`prod --release` is intentionally blocked if `android/keystore.properties` is missing.

## Security Model

- Main manifest does not request `INTERNET`.
- `android:allowBackup="false"` is enforced.
- `android:usesCleartextTraffic="false"` is set.
- User-entered shortcut names and URLs must not be logged.
- Release builds must use:
  - `--obfuscate`
  - `--split-debug-info=...`

Note:
- `android/app/src/debug/AndroidManifest.xml` and `android/app/src/profile/AndroidManifest.xml` include `INTERNET` only for Flutter development tooling (hot reload/debug transport). This is not present in the main release manifest.

## Setup

### Prerequisites

- Flutter `3.41.6`
- Android SDK (API 24+ target support)
- Java 17 (for Android Gradle build)

### Install Dependencies

```bash
flutter pub get
```

## Run Commands

Development flavor:

```bash
flutter run --flavor dev --dart-define=FLUTTER_APP_FLAVOR=dev
```

Production flavor in debug mode:

```bash
flutter run --flavor prod --dart-define=FLUTTER_APP_FLAVOR=prod
```

Optional profile run (dev flavor):

```bash
flutter run --profile --flavor dev --dart-define=FLUTTER_APP_FLAVOR=dev
```

## Release Build Commands (Android)

`prod --release` requires `android/keystore.properties`.

APK (split per ABI):

```bash
flutter build apk \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info=build/symbols/android-<version>/ \
  --split-per-abi \
  --tree-shake-icons \
  --dart-define=FLUTTER_APP_FLAVOR=prod \
  --dart-define=APP_AI_USED=<AI_LABEL>
```

App Bundle (Play):

```bash
flutter build appbundle \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info=build/symbols/android-<version>/ \
  --tree-shake-icons \
  --dart-define=FLUTTER_APP_FLAVOR=prod \
  --dart-define=APP_AI_USED=<AI_LABEL>
```

Size analysis:

```bash
flutter build apk --flavor prod --release --analyze-size
```

Optional metadata define:

```bash
--dart-define=APP_AUTHOR=<AUTHOR_LABEL>
```

## Quality Gates

Run before merge/release:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Tests In This Repository

- URL formatter unit tests:
  - `test/youtube_url_formatter_test.dart`
- Store behavior unit tests:
  - `test/shortcut_store_test.dart`
- Basic widget render test:
  - `test/widget_test.dart`

## Metadata Shown In About Screen

About data is assembled from:
- `APP_AUTHOR` (`--dart-define`, default: `SreerajP`)
- `APP_AI_USED` (`--dart-define`, default: `OpenAI GPT-5`)
- `PackageInfo` version/build
- Android `BuildConfig` values exposed over a method channel:
  - `PUBSPEC_BUILD_NUMBER`
  - `APP_BUILD_DATE`

## Key Documentation

- [docs/architecture.md](docs/architecture.md)
- [docs/flutter_project_engineering_standard.md](docs/flutter_project_engineering_standard.md)
- [docs/flutter_build_flavors_guide.md](docs/flutter_build_flavors_guide.md)
- [docs/release_process.md](docs/release_process.md)
- [docs/security.md](docs/security.md)
- [AGENTS.md](AGENTS.md)

## Troubleshooting

- `SIGNING REQUIRED - prod --release build blocked`
  - Create `android/keystore.properties` with release keystore values.
- `Only YouTube links are supported in this app.`
  - Use one of the supported host/path formats listed above.
- `The YouTube app could not be opened...`
  - Install/enable the YouTube app on the device.

## License

See [LICENSE](LICENSE).
