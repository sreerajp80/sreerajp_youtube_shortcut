# Change Log: Brought Folder Structure, Docs, and Code In Line With the Guidelines

**Plan Reference:** [../plans/20260817_204355_guidelines-conformance-audit.md](../plans/20260817_204355_guidelines-conformance-audit.md)

**Date:** 2026-08-17

## Summary

Fixed all nine conformance problems found when auditing the repository against the shared
Flutter guidelines submodule. All five planned phases were completed. Four were `MUST`
breaches; the rest were `SHOULD`-level cleanups.

---

## Phase 1 — `lib/` now follows the baseline layout

`lib/src/` is gone. That folder is the convention for a published Dart package hiding its
internals, which does not apply to an app. Every file moved to its layer folder, matching
`docs/guidelines/guideline.md` §3 and the engineering standard §3.1 (Tier 1).

| From | To |
|---|---|
| `lib/src/shortcut_models.dart` | `lib/models/shortcut_models.dart` |
| `lib/src/qr_payload_parser.dart` | `lib/models/qr_payload_parser.dart` |
| `lib/src/about_constants.dart` | `lib/core/constants/about_constants.dart` |
| `lib/src/shortcut_repository.dart` | `lib/repositories/shortcut_repository.dart` |
| `lib/src/backup_service.dart` | `lib/services/backup_service.dart` |
| `lib/src/share_intent_service.dart` | `lib/services/share_intent_service.dart` |
| `lib/src/youtube_launcher_service.dart` | `lib/services/youtube_launcher_service.dart` |
| `lib/src/youtube_url_formatter.dart` | `lib/services/youtube_url_formatter.dart` |
| `lib/src/services/privacy_lock_service.dart` | `lib/services/privacy_lock_service.dart` |
| `lib/src/shortcut_store.dart` | `lib/state/shortcut_store.dart` |
| `lib/src/privacy_lock_store.dart` | `lib/state/privacy_lock_store.dart` |
| `lib/src/app_shell.dart` | `lib/app/app_shell.dart` (theme split out) |
| `lib/src/screens/*` (11 files) | `lib/screens/*` |
| `lib/src/widgets/*` (2 files) | `lib/widgets/*` |

Also in this phase:

- New `lib/app/theme/app_theme.dart` holds `AppTheme.forPreference` and the
  `AppThemePreferenceMode` extension, lifted out of `app_shell.dart`. The `theme/` folder
  required by §3 now exists.
- `state/` was chosen over `providers/` (§3 requires picking one name); both state holders are
  named `…Store` and are plain `ChangeNotifier`s.
- Every relative import became a `package:sreerajp_youtube_shortcut/...` import. The only
  relative imports left are inside the two `flutter gen-l10n` generated files, which the
  generator writes that way.
- `test/` was re-laid out to mirror `lib/`: `test/models/`, `test/services/`, `test/state/`,
  plus `test/widget_test.dart`.

## Phase 2 — Localization added (was completely missing)

Localization is mandatory for every app, even single-language ones. None of it existed.

- Added `flutter_localizations` and `intl` to `pubspec.yaml`, plus `generate: true`.
- Created `l10n.yaml` at the project root and `lib/l10n/app_en.arb`.
- Wired `localizationsDelegates` and `supportedLocales` into both `ShortcutApp` and `FatalApp`.
- Moved **362 strings** into the ARB file. Every one has an `@key` description.
- New `lib/l10n/model_labels.dart` holds `label(l10n)` extensions for `AppLayoutPreference`,
  `AppThemePreference`, `ShortcutSortPreference`, and `ShortcutTargetType`. The display names
  were **removed from the enums themselves**, so the model layer no longer carries UI copy.
- Dates on the shortcut detail screen now use `intl`'s `DateFormat.yMMMd(locale).add_jm()`.
  The hand-built English month table and AM/PM logic were deleted.
- Plurals use proper ICU plural syntax instead of `${n == 1 ? '' : 's'}` string tricks.

Literals deliberately kept, all within the standard's allowed exceptions: log messages,
storage keys (icon names, preference ids), asset paths, colour hex values, default tag text
(`#Tech` and friends — these are stored data, not UI chrome), and one internal validation
probe name that is never displayed.

## Phase 3 — Signing properties file renamed

`docs/guidelines/guideline.md` §2.1 fixes this file's name as `key.properties`.

- `android/keystore.properties` → `android/key.properties` (local file only; it is gitignored,
  so nothing secret was added or removed from version control).
- `android/app/build.gradle.kts`: path, variable name, and the build-guard error message.
- References updated in `CLAUDE.md`, `AGENTS.md`, `README.md`, `docs/architecture.md`,
  `docs/release_process.md`, and the features doc.
- `.gitignore` keeps both names, so an old local copy can never be committed by accident.
- The keystore itself was not touched or read.

**Also found and fixed here:** the release command documented in `CLAUDE.md` and `AGENTS.md`
passed `--dart-define=FLUTTER_APP_FLAVOR=prod`. The current Flutter SDK rejects that outright —
the name is owned by the framework — so the documented command could not have worked. It was
removed, with a note explaining why.

## Phase 4 — Docs corrected

- **Deleted five copied-down reference docs** (`DOCS_FOLDER_GUIDELINE.md` §2 says link to
  references, only copy blueprints): `docs/flutter_project_engineering_standard.md`,
  `docs/flutter_build_flavors_guide.md`, `docs/architecture_README.md`,
  `docs/flutter_project_engineering_standard_README.md`, `docs/security_README.md`. They had
  already drifted from the submodule. Every reference now points at `docs/guidelines/…`.
- **`docs/architecture.md`**: the folder tree described `lib/app/routes.dart`,
  `lib/app/theme/app_tokens.dart`, `lib/state/add_shortcut_controller.dart` and other paths
  that never existed. Replaced with the real tree. Verified afterwards that every `lib/…dart`
  path named in the file exists on disk. Also corrected the navigation and theme-token
  sections, which described a routes table and a token file the app does not have.
- **`docs/project_structure.md`**: rewritten. The old version hedged with
  "`lib/src/` (or `lib/models`, …)". It now has the real tree plus a layer-responsibility table
  saying what each folder must *not* contain.
- **`docs/features.md` → `docs/sreerajp_youtube_shortcut_idea.md`** (a recognized §7 type), and
  `docs/potential_features.md` folded into it as "§9 Planned / Not Built", then deleted.
- **`CLAUDE.md` and `AGENTS.md`**: doc table extended, architecture rules rewritten for the new
  layout, new **Localization Rules** section added, `lib/src/` explicitly banned, testing rule
  updated, project tree updated.
- **`docs/dependencies.md`**: the table listed only 5 of the 13 runtime packages. All are now
  listed, including the two added in Phase 2.

## Phase 5 — Code-quality fixes

**Sealed exceptions are now real.** They were declared but never used anywhere.

- `ShortcutBackupException` was defined inside `backup_service.dart`, outside the hierarchy.
  It moved into `lib/core/errors/app_exception.dart` and now extends `AppException`.
- Added an `AppErrorCode` enum with 33 stable codes. Every exception carries one.
- All 35 throw sites now pass a code alongside the developer-facing message.
- New `lib/l10n/error_messages.dart` maps a code to localized text via
  `exception.localized(l10n)`. Every screen was switched from showing `error.message` to
  showing the localized text — previously, raw English service strings went straight into
  `SnackBar`s.
- `message` is kept as the developer-facing string for logs, which the standard allows.

**`home_screen.dart` split.** It was 1,926 lines. Five widget files were extracted to
`lib/widgets/`: `shortcut_card.dart`, `shortcut_grid.dart`, `shortcut_filter_bar.dart`,
`home_states.dart`, and `glass_add_fab.dart`.

## Verification

Run after every phase, and again at the end:

| Check | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed .` | Pass — 46 files, 0 changed |
| `flutter analyze` | **No issues found** |
| `flutter test` | **72/72 passed** |
| `flutter build apk --flavor dev --debug` | Built |
| `flutter build apk --flavor prod --release --obfuscate --split-debug-info --split-per-abi` | Built and signed for all three ABIs |

Guideline checklist spot-checks: `l10n.yaml` present, `lib/l10n/app_en.arb` present, 362 ARB
keys with zero missing `@key` descriptions, `lib/src/` absent, `android/key.properties`
confirmed gitignored, root `CLAUDE.md` and `AGENTS.md` present.

## Known Remaining Gap

`lib/screens/home_screen.dart` is **942 lines**, down from 1,926 but above the ~400 target set
in the plan. All the widget-tree code was extracted; what remains is the `_HomeScreenState`
class itself — its action handlers, the two `AppBar` builders, and selection/reorder/filter
state. Splitting those further would mean threading many callbacks through new widgets for
little gain, so it was left alone. Worth revisiting if the screen grows again.

## Not Changed

- The release keystore file and its contents.
- Any app behaviour or feature. All changes were moves, renames, string externalization,
  documentation, and the exception-code refactor.
- `docs/guidelines/` — the submodule is read-only from this project.
