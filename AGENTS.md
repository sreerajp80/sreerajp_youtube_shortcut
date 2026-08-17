# AGENTS.md — Project Instructions For AI Coding Agents

This file is read by AI agents and LLM coding assistants (Gemini, Antigravity, Cursor, Windsurf, Codex, etc.) at the start of every session in this repository. Read it before making any change. See the docs table below for full detail.

---

## Project Identity

| Field | Value |
|-------|-------|
| App name | SreerajP YouTube Shortcuts (used everywhere — no short form) |
| Type | Local Android utility for turning YouTube links into quick-launch shortcuts |
| Platform(s) | Android only (minSdk 24, targetSdk 35) |
| Package / org id | `in.sreerajp.sreerajp_youtube_shortcut` |
| Flutter SDK | 3.44.8 |
| Dart SDK | 3.12.2 |
| State management | `provider` + `ChangeNotifier` |
| Navigation | Material page routing |
| Database | `shared_preferences` (versioned JSON) |
| Orientation | Portrait only |
| Connectivity | Fully offline — no `INTERNET` permission |

---

## Read These Docs Before Working

Always consult the relevant document before making changes. The `docs/` folder is the source of truth for this project's design and standards.

| Document | Read when |
|----------|-----------|
| `docs/architecture.md` | Changing app structure, adding screens, state, services, models, or repositories |
| `docs/security.md` | Touching permissions, logging, storage, manifest, or binary protections |
| `docs/release_process.md` | Building a release, versioning, or running the release checklist |
| `docs/guidelines/flutter_build_flavors_guide.md` | Any change to build config, signing, flavors, Gradle, or ProGuard |
| `docs/guidelines/flutter_project_engineering_standard.md` | Any code change — governs layer boundaries, naming, testing, and code quality rules |
| `docs/project_structure.md` | Orienting in the repo — the real file tree and layer table |
| `docs/sreerajp_youtube_shortcut_idea.md` | Checking whether a feature already exists or is on the roadmap |
| `docs/guidelines/guideline.md` | Folder layout, About-config pattern, keystore rules |
| `docs/GUIDELINES_MANIFEST.md` | The shared Flutter guidelines index |

---

## Hard Rules

1. Offline-first: The app is fully offline. `INTERNET` permission must never be added to the manifest.
2. No telemetry or analytics: No network, tracking, or cloud SDKs permitted.
3. No privacy logging: Never log user-entered shortcut names or YouTube URLs.
4. Scoped storage: Use system file picker / share intents; no broad storage permissions.
5. Localized strings only: every user-visible string comes from `AppLocalizations`.

---

## Architecture Rules

- Layout: Tier 1 layer-first layout under `lib/`: `app/` (shell + theme), `core/` (`config/`, `constants/`, `errors/`), `l10n/`, `models/`, `repositories/`, `services/`, `state/`, `screens/`, `widgets/`, `main.dart`. Do not restructure without explicit instruction. `lib/src/` must not come back — that is package convention, not app convention.
- State folder: `state/` holds every `ChangeNotifier`. Do not add a parallel `providers/`.
- `lib/core/config/` is a fixed path required by `docs/guidelines/guideline.md` §1. Never move or rename it.
- Layer boundaries: widgets must not know about `SharedPreferences`, intent details, or URL parsing. Services must not know about `BuildContext` or widget state.
- Error hierarchy: use sealed exceptions in `lib/core/errors/`. Do not throw raw strings or generic `Exception`.

---

## Build & Run Commands

```bash
flutter pub get                        # install dependencies
flutter run --flavor dev               # daily development
flutter run --flavor prod              # production build with debug tooling
flutter analyze                        # static analysis (must be clean)
flutter test                           # run all tests
dart format --output=none --set-exit-if-changed .  # check formatting

flutter gen-l10n                       # regenerate AppLocalizations after editing an .arb file

# Production release APK (split per ABI, requires android/key.properties)
flutter build apk --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-<version>/ --split-per-abi \
  --dart-define=APP_BUILD_DATE=<YYYY-MM-DD> --dart-define=APP_AI_USED=<AI_LABEL>
```

> Never pass `--dart-define=FLUTTER_APP_FLAVOR`. That name is owned by the framework and the
> current Flutter SDK rejects the build outright. `--flavor prod` sets it for you.

---

## Build Flavors

| Flavor | App ID | Display Name | Signing |
|--------|--------|--------------|---------|
| `dev` | `in.sreerajp.sreerajp_youtube_shortcut.dev` | SreerajP YouTube Shortcuts Dev | Debug keystore (automatic) |
| `prod` | `in.sreerajp.sreerajp_youtube_shortcut` | SreerajP YouTube Shortcuts | Release keystore (`android/key.properties`) |

Debug builds never need a signing key. `prod --release` is blocked by a Gradle guard if `android/key.properties` is absent.

---

## Signing / Keystore

- Keystore configuration: defined in `android/key.properties` (gitignored).
- `.gitignore` must include: `key.properties`, `*.jks`, `*.keystore`, `build/symbols/`.

---

## Security Rules

- Never log secrets, keys, shortcut names, or YouTube URLs — even in debug builds.
- Request only necessary permissions; never add `INTERNET` or broad storage permissions.
- `android:allowBackup="false"` must remain in `AndroidManifest.xml`.
- All release builds must include `--obfuscate` and `--split-debug-info`.

---

## Localization Rules

- All user-visible text comes from `lib/l10n/app_en.arb` via `AppLocalizations` — never a raw
  string literal in a widget. This applies even though the app ships only English.
- `l10n.yaml` (project root) and `lib/l10n/app_en.arb` must exist. Run `flutter gen-l10n` after
  editing any `.arb` file. The generated files land in `lib/l10n/` and are committed.
- Every ARB key needs an `@key` description entry.
- Literals are allowed only for: log messages, non-UI exception messages, asset paths, route
  names, map/JSON keys, and stored data values (tag text, icon keys, colour hex).
- Enum display names live in `lib/l10n/model_labels.dart` as `label(l10n)` extensions. Models
  must not carry UI copy.
- Dates and times are formatted with `intl`'s `DateFormat` using the active locale, never by
  hand-assembling month names.

---

## Code Style / Naming

- Files `snake_case.dart`; classes `PascalCase`; variables/methods `camelCase`.
- Use `package:` imports, not relative imports across modules.
- Run `dart format .` and maintain zero `flutter analyze` warnings.

---

## Testing Rules

- Mirror `lib/` structure in `test/` (`test/models/`, `test/services/`, `test/state/`).
- Add unit or widget tests whenever changing services, models, parsers, or store logic.
- Verify zero failing tests with `flutter test`.

---

## Dependency Constraints

- Blocked: HTTP clients, BaaS, cloud SDKs, analytics, crash reporting, ads.
- Audit `pubspec.lock` before adding any new package to ensure no transitive networking dependencies.

---

## Where Things Live

```
AGENTS.md            # project instructions for AI agents / LLMs
CLAUDE.md            # project instructions for Claude Code
l10n.yaml            # ARB → AppLocalizations generator settings
docs/                # design docs & Flutter guidelines submodule
plans/               # change plans
change_log/          # change logs
assets/config/       # app_config.json (About screen metadata)
lib/                 # app source code (see docs/project_structure.md)
test/                # test suite, mirroring lib/
```

Full tree and layer responsibilities: `docs/project_structure.md`.

---

## Workflow Rules (Mandatory)

Every change follows plan-before-changing and log-after-changing:

1. **Plan before changing.** Write a full plan to `plans/` named `yyyymmdd_hhMMss_<short-slug>.md` with a `**Status:**` line, the files to change, the issue, and the fix. Then **STOP and get explicit approval** before editing/creating/deleting any project file (other than the plan). A question or ambiguous reply is not approval.
2. **Log after changing.** After implementing, write a change log to `change_log/` named `yyyymmdd_hhMMss_<short-slug>.md` describing what changed and referencing its plan.
3. **Relative paths & privacy only.** All `plans/` and `change_log/` files MUST use relative repository paths only (never absolute system paths like `C:\...`, `l:\...`, or `file:///...`). They MUST NOT contain any sensitive or private information that cannot be shared publicly on the internet (secrets, API keys, tokens, passwords, keystore passphrases, local absolute paths, internal IPs, credentials, or PII).

Create `plans/` and `change_log/` if they do not exist.

---

## Communication Rules

- **Always use simple English.** Write all responses, plans, change logs, and explanations in plain, simple English. Short sentences, common words. Explain any jargon you must use.

---

## What AI Agents Must Always / Never Do

**Always:** Read this file first; check layer boundaries; verify format, analyze, and test after edits.
**Never:** Put business or parsing logic in a widget; add network permissions; log user shortcuts or URLs; hard-code a user-visible string; recreate `lib/src/`.
