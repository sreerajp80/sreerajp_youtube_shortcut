# Architecture

Use this document to describe the current system design of the Flutter app.

## 1. Scope

- Product: `SreerajP YouTube Shortcuts`
- Suggested short display names:
  - `YT Shortcuts`
  - `SP YT Shortcuts`
  - `YT Quick Open`
- Repository type: `application`
- Framework: `Flutter 3.44.8`
- Engineering standard profiles in force:
  - `Core Baseline`
- Platforms:
  - `Android`

---

## 2. Goals And Non-Goals

### Goals

- Let the user create a named shortcut entry from a YouTube URL and a custom shortcut name.
- Normalize supported YouTube URLs into a canonical launch target that can be handed directly to
  the YouTube Android app.
- Store all shortcut entries locally on-device and keep them available after app restart.
- Render a shortcut section on the home screen where tapping an item opens the installed YouTube
  app.
- Provide an About screen that shows author details, app version, build number, build date, and
  AI used.
- Keep the Flutter app itself fully offline with no app-managed HTTP traffic and no
  `INTERNET` permission.

### Non-Goals

- Streaming, downloading, or controlling playback inside this app.
- Google account sign-in, YouTube API integration, sync, or cloud backup.
- Home-screen pinned shortcuts, widgets, or notification shortcuts in v1.
- Browser fallback when the YouTube app is missing; v1 shows a clear local error instead.
- Support for platforms other than Android.

---

## 3. Architecture Summary

The app is a small Android-only Flutter 3.44.8 application using a Tier 1 layer-first structure.
The user enters a shortcut name and a YouTube URL on the Add Shortcut screen. A formatter service
validates the host and path, normalizes supported YouTube links into a canonical HTTPS YouTube
URI, and produces an immutable `ShortcutEntry`. Entries are persisted locally as JSON in
`SharedPreferences`. The home screen renders the saved shortcuts as tappable cards. Tapping a
shortcut delegates to an Android launcher service that sends an explicit intent to the YouTube
package (`com.google.android.youtube`) so the target opens in the YouTube app rather than a
browser. The app contains no network client and must not request `INTERNET`.

---

## 4. Repository Structure

### Current Structure Tier

- `Tier 1`
- Why this tier is appropriate now:
  - The app has a small feature surface and one local data source.
  - A layer-first layout keeps the code easy to scan while still preserving boundaries.

### Top-Level Source Layout

```text
lib/
|-- app/
|   |-- app.dart
|   |-- routes.dart
|   `-- theme/
|       |-- app_theme.dart
|       `-- app_tokens.dart
|-- core/
|   |-- errors/
|   |   `-- app_exception.dart
|   `-- metadata/
|       `-- build_metadata.dart
|-- models/
|   |-- about_info.dart
|   |-- shortcut_entry.dart
|   `-- youtube_target.dart
|-- repositories/
|   `-- shortcut_repository.dart
|-- services/
|   |-- build_info_service.dart
|   |-- youtube_launcher_service.dart
|   `-- youtube_url_formatter.dart
|-- state/
|   |-- add_shortcut_controller.dart
|   `-- shortcut_store.dart
|-- screens/
|   |-- about_screen.dart
|   |-- add_shortcut_screen.dart
|   |-- fatal_error_screen.dart
|   `-- home_screen.dart
|-- widgets/
|   |-- empty_state.dart
|   `-- shortcut_card.dart
`-- main.dart
```

### Ownership Rules

| Path | Responsibility |
|------|----------------|
| `lib/app/` | App shell, routing, theme, app-wide configuration |
| `lib/core/` | Cross-cutting metadata and error primitives |
| `lib/models/` | Immutable app models and typed parsing results |
| `lib/repositories/` | Local persistence and storage migrations |
| `lib/services/` | URL normalization, external app launching, build info assembly |
| `lib/state/` | `ChangeNotifier` state holders for screens and app data |
| `lib/screens/` | Full-screen UI |
| `lib/widgets/` | Shared presentational widgets |

---

## 5. App Initialization Sequence

Document the exact order of initialization steps that run in `main()` before `runApp`. Getting
this order wrong causes platform crashes that only appear in release builds.

| Step | Code / Call | Notes |
|------|-------------|-------|
| 1 | `WidgetsFlutterBinding.ensureInitialized()` | Always first |
| 2 | Configure `FlutterError.onError` and `PlatformDispatcher.instance.onError` | Required by engineering standard before UI startup |
| 3 | `final prefs = await SharedPreferences.getInstance()` | Initializes local shortcut storage |
| 4 | `final packageInfo = await PackageInfo.fromPlatform()` | Supplies version and a fallback build number for About screen |
| 5 | Resolve About metadata from Android build config and `String.fromEnvironment(...)` | Build date and pubspec build number come from Android build config; AI-used label comes from `--dart-define` |
| 6 | Construct repository, services, and root state objects | Manual dependency wiring |
| 7 | `runApp(...)` | Launches the app with providers attached |

No deferred startup work is planned in v1. Shortcut loading should happen during root state
initialization and complete quickly because the data set is small.

---

## 6. App Lifecycle Behavior

Document what the app does in response to each lifecycle state change.

| Lifecycle State | App Behavior |
|----------------|--------------|
| `resumed` | Return to normal UI state; no background sync or refresh required |
| `inactive` | No special behavior |
| `paused` | No special behavior; writes are already committed when the user saves a shortcut |
| `detached` | No explicit cleanup required beyond normal widget disposal |
| Memory pressure | Clear Flutter image cache if any local icons have been decoded |

The app keeps no long-running background work, no sockets, and no pending network operations.

---

## 7. Offline Behavior

State whether the app is online, offline-first, or cache-assisted, and document the implications.

- **Connectivity requirement**: `fully offline`
- **Network permission**: `INTERNET permission absent`
- **Offline data source**: `SharedPreferences` JSON payload

If the app is **fully offline**:
- The merged Android release manifest MUST NOT contain
  `<uses-permission android:name="android.permission.INTERNET" />`.
- Every new dependency MUST be audited to verify it does not introduce HTTP clients, analytics,
  or transitive network activity.
- Create, edit, delete, and list flows MUST work with device networking disabled.
- Launching a shortcut is an external intent handoff only; the Flutter app itself still performs
  no network traffic.

---

## 8. State Management

- Primary pattern: `ChangeNotifier` with `provider`
- Why this pattern was chosen:
  - The state surface is small: a shortcut list, add-form state, and launch/save errors.
  - It keeps dependencies light and easy to test without code generation or complex indirection.
- State boundaries:
  - Widgets own: text controllers, focus nodes, transient animations, and presentation-only state
  - State layer owns: loaded shortcuts, form submission state, validation results, and user-facing
    error state
  - Services own: URL normalization rules, explicit YouTube launch behavior, and metadata assembly

---

## 9. Data Flow

Describe the expected request and update path.

```text
AddShortcutScreen
  -> AddShortcutController
  -> YoutubeUrlFormatter
  -> ShortcutRepository
  -> SharedPreferences

HomeScreen shortcut tap
  -> ShortcutStore
  -> YoutubeLauncherService
  -> Android intent for com.google.android.youtube
```

The app intentionally omits a separate datasource layer in v1. `ShortcutRepository` wraps the
single local persistence mechanism directly.

### Rules

- Widgets must not know: `SharedPreferences`, intent details, package names, or URL parsing rules
- Services must not know: `BuildContext`, `Navigator`, SnackBar text, or widget state
- Repositories abstract: local JSON persistence, storage key names, and future payload migration

---

## 10. Error Handling Architecture

Document how errors are classified and propagated from the datasource layer to the UI.

- **Global error handler**: `FlutterError.onError` and `PlatformDispatcher.instance.onError`
  configured in `main()`
- **Domain exception hierarchy**: sealed app-level exceptions in `lib/core/errors/app_exception.dart`

| Exception Class | Thrown By | Meaning |
|----------------|-----------|---------|
| `ShortcutValidationException` | `YoutubeUrlFormatter` | Name empty, unsupported host/path, or malformed YouTube URL |
| `ShortcutStorageException` | `ShortcutRepository` | Local read/write or decode failure |
| `YoutubeLaunchException` | `YoutubeLauncherService` | YouTube app not installed, disabled, or launch rejected |
| `AppInitializationException` | Startup wiring | Required local dependency failed during boot |

- **Error escalation policy**:
  - Validation errors stay local to the Add Shortcut form and are shown inline.
  - Launch and storage errors surface as non-fatal UI messages and preserve current screen state.
  - Boot-time dependency failures route to the fatal error screen.
- **Fatal error screen**: `lib/screens/fatal_error_screen.dart`

---

## 11. Domain Model

### Current Schema Version

Persistence schema version: `1`

This app does not use SQLite in v1. Versioning applies to the JSON payload stored in
`SharedPreferences`.

Migration history:

| Version | Change Summary |
|---------|---------------|
| 1 | Initial payload stored under a versioned key for shortcut entries |

### Core Models Or Entities

| Type | Purpose | Mutable? | Notes |
|------|---------|----------|-------|
| `ShortcutEntry` | Saved user shortcut record | `No` | Contains id, name, source URL, canonical URL, target kind, created/updated timestamps |
| `YoutubeTarget` | Validated parsed YouTube destination | `No` | Holds normalized host/path/query information used for launch |
| `AboutInfo` | About-screen metadata | `No` | Contains author, version, build number, build date, and AI-used label |

### Serialization Strategy

- JSON models: `yes`
- Database models: `no`
- Separate domain entities from transport models: `no`; the app reuses the same immutable model
  for UI and local JSON persistence because the shape is small

### Database Indexes

| Table | Indexed Columns | Reason |
|-------|----------------|--------|
| Not applicable | Not applicable | No relational database in v1 |

---

## 12. Dependency Management And Injection

- DI approach: manual wiring with `MultiProvider`
- App-root dependencies:
  - `SharedPreferences`
  - `ShortcutRepository`
  - `YoutubeUrlFormatter`
  - `YoutubeLauncherService`
  - `BuildInfoService`
- Test replacement strategy:
  - Constructor injection for services and repository
  - Provider overrides with fakes for widget and integration tests

Planned dependency set should stay minimal: `provider`, `shared_preferences`,
`android_intent_plus`, and `package_info_plus`.

---

## 13. Navigation

- Navigation approach: `Navigator 1.0` with `MaterialPageRoute`
- Route definition location: `lib/app/routes.dart`
- Protected-route strategy: none in v1
- Deep-link support: outbound only; the app launches YouTube targets but does not register inbound
  deep links

The route surface is intentionally small:
- Home
- Add Shortcut
- About
- Fatal Error

---

## 14. Persistence And External Systems

### Local Storage

- Database: none
- WAL mode: not applicable
- Key-value storage: `shared_preferences`
- Secure storage: none

### Network

- Network client: none
- Offline behavior: `fully offline`

### Platform Channels Or Native Integrations

- `android_intent_plus`: launches canonical YouTube URLs in the YouTube Android app package
- `package_info_plus`: reads version and fallback build number for the About screen
- Android `MethodChannel` (`build_metadata`): reads build date and pubspec build number generated by Gradle
- `shared_preferences`: stores shortcut list JSON locally

---

## 15. Environment And Build Model

- Flavors used: `dev`, `prod` (Android product flavors, `environment` dimension)

| Flavor | Application ID | Display Name | Purpose |
|--------|---------------|--------------|---------|
| `dev` | `in.sreerajp.sreerajp_youtube_shortcut.dev` | YT Shortcuts Dev | Local development and QA |
| `prod` | `in.sreerajp.sreerajp_youtube_shortcut` | YT Shortcuts | Store submission and public distribution |

- Signing strategy: Strategy A — local file-based (`android/keystore.properties`).
  - `dev --debug`: automatic debug keystore, no setup required.
  - `dev --release`: uses release keystore if `keystore.properties` is present; no guard.
  - `prod --release`: release keystore required; build blocked by Gradle guard if `keystore.properties`
    is absent. See `docs/flutter_build_flavors_guide.md §Android Signing Configuration`.
- Runtime config mechanism:
  - `pubspec.yaml` version for version name
  - Android build config `PUBSPEC_BUILD_NUMBER` sourced from `pubspec.yaml`
  - Android build config `APP_BUILD_DATE` generated automatically at build time
  - `--dart-define=APP_AI_USED=<label>`
  - `--dart-define=FLUTTER_APP_FLAVOR=<dev|prod>` passed alongside `--flavor`
- Build outputs supported:
  - `debug apk` (dev or prod flavor)
  - `release apk` split per ABI (prod flavor)
  - `release app bundle` (prod flavor, Play Store)
- Obfuscation: enabled for release builds; symbols stored at `build/symbols/android-<version>/`

---

## 16. UI System

- Theme source of truth: `lib/app/theme/app_theme.dart`
- Design tokens location: `lib/app/theme/app_tokens.dart`
- Shared widget strategy: reusable cards, empty states, and metadata rows live in `lib/widgets/`
- Typography strategy: bundle font assets locally; do not fetch fonts at runtime
- Accessibility expectations:
  - Minimum touch target: 48 x 48 dp on mobile
  - Color contrast: WCAG AA minimum (4.5:1 normal text, 3:1 large text)
  - Screen reader: TalkBack tested before release
  - Text scale: layouts verified at 1.0x, 1.5x, and 2.0x

The shortcut section should support both empty and populated states cleanly and keep the primary
tap target obvious even at high text scale.

---

## 17. Logging

- Logger implementation: thin app wrapper around `debugPrint` / `dart:developer`
- Log file location (if applicable): none
- Log rotation policy: not applicable
- Verbose logging gate: debug mode only
- Sensitive data policy: user-entered shortcut names, source URLs, and canonical URLs are never
  logged

Allowed production log context is limited to operation names, counts, and coarse error category.

---

## 18. Testing Strategy

| Test Type | Scope | Notes |
|-----------|-------|-------|
| Unit | URL normalization, validation, local JSON serialization | Cover `watch`, `youtu.be`, `shorts`, playlist, and channel-style inputs |
| Widget | Home, Add Shortcut, and About screens | Verify validation messaging, empty state, and metadata rendering |
| Integration | Save shortcut, persist across restart, tap shortcut to invoke launcher service | Stub or fake external launch result where direct device validation is not practical |
| Performance | Startup and scroll smoothness on the shortcut list | Manual validation is acceptable in v1 |

### Test Layout

```text
test/
|-- models/
|-- repositories/
|-- screens/
|-- services/
|-- state/
|-- widgets/
`-- helpers/
```

### Critical Test Areas

- Supported and unsupported YouTube URL parsing
- Duplicate-name handling and empty-input validation
- Persistence round-trip for saved shortcuts
- Launch error handling when YouTube is unavailable
- About metadata fallback behavior when a build define is missing
- Global error screen routing for startup failures

---

## 19. Operational Constraints

Document constraints that shape implementation choices.

- Minimum supported OS versions: Android 7.0 / API 24
- Performance constraints:
  - Cold startup target: under 2 seconds to first meaningful frame in release mode
  - Frame budget: 16 ms at 60 Hz; sustained jank above 5% is release-blocking
  - APK size budget: target `< 15 MB`, hard limit `25 MB`
- Regulatory or store constraints:
  - The app must be clearly described as an unofficial YouTube shortcut utility.
  - Do not ship Google or YouTube trademarked artwork unless usage has been reviewed.
- Team constraints: single developer, manual QA, low release cadence
- Offline constraints: no `INTERNET` permission and no packages that introduce analytics or HTTP

---

## 20. Decisions And Tradeoffs

Record the decisions that are likely to be questioned later.

| Decision | Chosen Option | Why | Tradeoff |
|----------|---------------|-----|----------|
| Persistence | `SharedPreferences` JSON | Small local dataset and no relational queries | Future migrations are manual if the model grows |
| State management | `provider` + `ChangeNotifier` | Small state surface and low setup cost | Less scalable than a larger feature-driven state stack |
| Launch strategy | Explicit Android intent to `com.google.android.youtube` | Meets the requirement to open the YouTube app directly | No browser fallback when YouTube is unavailable |
| Build model | No flavors in v1 | Single environment and no parallel install need | Flavors must be added later if release lanes diverge |

---

## 21. Known Risks And Follow-Ups

- Risk: Users may paste unsupported or oddly formatted YouTube links.
  Mitigation: Document supported formats, normalize aggressively, and cover parser edge cases with
  unit tests.
- Risk: The YouTube app may be missing or disabled on the device.
  Mitigation: Catch launch failure, keep the app stable, and show a clear install/enable message.
- Risk: A future request for launcher-level pinned shortcuts will require new Android integration.
  Mitigation: Keep launch behavior isolated in `YoutubeLauncherService` so that shortcut creation
  can expand without a full architecture rewrite.

---

## 22. Related Documents

- `README.md`
- `docs/flutter_project_engineering_standard.md`
- `docs/flutter_build_flavors_guide.md`
- `docs/release_process.md`
- `docs/security.md`





