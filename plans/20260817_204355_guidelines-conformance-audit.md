# Plan: Bring Folder Structure, Docs, and Code In Line With the Guidelines

**Status:** completed

**Change log:** [../change_log/20260817_211833_guidelines-conformance-audit.md](../change_log/20260817_211833_guidelines-conformance-audit.md)

**Approved:** 2026-08-17 — all five phases, `state/` chosen as the state folder, keystore
rename included.

**Date:** 2026-08-17

**Guidelines checked against:** `docs/guidelines/guideline.md`,
`docs/guidelines/flutter_project_engineering_standard.md`,
`docs/guidelines/DOCS_FOLDER_GUIDELINE.md`,
`docs/guidelines/CLAUDE_MD_GUIDELINE.md`,
`docs/guidelines/AGENTS_MD_GUIDELINE.md`,
`docs/GUIDELINES_MANIFEST.md`

---

## 1. What the audit found

I read the guidelines submodule and compared it to the whole repository. Nine problems were
found. Four are **MUST** breaches. Three things were already correct and need no work.

### Already correct (no action needed)

- `assets/config/app_config.json` exists with all required fields, and `version` / `build`
  (`1.5.0` / `21`) match `pubspec.yaml` (`1.5.0+21`).
- `assets/config/` is registered under `flutter: assets:` in `pubspec.yaml`.
- `lib/core/config/app_config.dart` (`AppConfig` with `fromJson` + `fallback`) and
  `lib/core/config/config_service.dart` (`ConfigService` with `load()` + `loadAndVerify()`)
  are at the fixed paths with the fixed class names.
- The About screen loads from `ConfigService` and loops `config.details` dynamically.
- All 8 mandatory baseline docs from `DOCS_FOLDER_GUIDELINE.md` §6 exist.
- `plans/` and `change_log/` contain no absolute paths, no local system details, and no
  secrets. I scanned for drive letters, `file:///`, host paths, LAN IP ranges, and personal
  email addresses — zero hits.
- The keystore itself is at `android/keystore.jks`, which the guideline allows (the file name
  is free per app).

### Problem 1 — `lib/` does not follow the baseline layout (**MUST**)

`guideline.md` §3 and the engineering standard §3.1 (Tier 1) require layer folders directly
under `lib/`: `core/`, `models/`, `services/`, `repositories/`, `screens/`, `widgets/`,
`providers/` (or `state/`), `theme/`, `l10n/`.

The project instead puts almost everything inside a `lib/src/` package-style folder, flat:

```
lib/src/app_shell.dart, backup_service.dart, privacy_lock_store.dart,
        qr_payload_parser.dart, share_intent_service.dart, shortcut_models.dart,
        shortcut_repository.dart, shortcut_store.dart, about_constants.dart,
        youtube_launcher_service.dart, youtube_url_formatter.dart,
        screens/, widgets/, services/
```

`lib/src/` is the convention for a **published Dart package** that hides its internals. This is
an app, not a package, so it does not apply. Models, repositories, services, and state holders
are all mixed together in one flat folder.

The project's own `CLAUDE.md` already claims the layer-first layout ("`core/`, `models/`,
`repositories/`, `services/`, `screens/`, `widgets/`, `main.dart`"), so the code does not match
the file that describes it.

### Problem 2 — Localization is completely missing (**MUST**)

`guideline.md` §3/§4 and engineering standard §8.1–8.2 now require this of **every** app, even a
single-language one:

- `l10n.yaml` at the project root — **missing**.
- `lib/l10n/app_en.arb` — **missing** (there is no `lib/l10n/` folder at all).
- `flutter_localizations` in `pubspec.yaml` and `localizationsDelegates` /
  `supportedLocales` on the app widget — **missing**.
- Every user-visible string read through `AppLocalizations` — **not done**; every screen uses
  raw string literals.

This is the largest single gap. There are roughly 9,100 lines of UI code across 11 screens and
2 dialogs, all with hard-coded English text.

### Problem 3 — `docs/architecture.md` describes a folder tree that does not exist

`docs/architecture.md` documents `lib/app/`, `lib/models/`, `lib/repositories/`,
`lib/services/`, `lib/state/`, `lib/screens/`, `lib/widgets/`, plus specific files
`lib/app/routes.dart`, `lib/app/theme/app_theme.dart`, `lib/app/theme/app_tokens.dart`, and
`lib/screens/fatal_error_screen.dart`.

**None of these paths exist.** The real code is in `lib/src/`, and there is no `theme/` folder
and no routes file at all. `docs/project_structure.md` is closer to the truth but hedges
("`lib/src/` (or `lib/models`, `lib/services`, `lib/repositories`)"), which is not a
description — it is a guess.

### Problem 4 — Signing-properties file has the wrong name (**MUST**)

`guideline.md` §2.1 says the properties file **MUST** be named `key.properties`, not
`keystore.properties`. That section is marked the source of truth for keystore rules.

The project uses `android/keystore.properties`, referenced in
`android/app/build.gradle.kts` (lines 47, 84–89, 127–141), `CLAUDE.md`, `AGENTS.md`,
`docs/architecture.md`, `docs/release_process.md`, and `docs/features.md`.

`.gitignore` already covers both names, so no secret is at risk either way.

### Problem 5 — Reference docs were copied into `docs/` instead of linked

`DOCS_FOLDER_GUIDELINE.md` §2 says: fill in blueprints locally, **link** to references. These
five files are copied-down reference docs that should not be duplicated:

- `docs/flutter_project_engineering_standard.md`
- `docs/flutter_build_flavors_guide.md`
- `docs/architecture_README.md`
- `docs/flutter_project_engineering_standard_README.md`
- `docs/security_README.md`

They are already drifting: the local `flutter_build_flavors_guide.md` says `key.properties`
while the project uses `keystore.properties`. Keeping stale copies is worse than having none.

(`docs/architecture.md` and `docs/security.md` are blueprints and **should** stay local.)

### Problem 6 — Two docs are not recognized types

`docs/features.md` and `docs/potential_features.md` are not in the §7 catalog. §8 says prefer a
new section in an existing doc over a new file. `features.md` reads like the product concept,
which the catalog calls `<app>_idea.md`; `potential_features.md` is a backlog, which belongs in
the same file as a "Planned / not built" section.

### Problem 7 — All imports are relative

`CLAUDE.md` and the engineering standard both require `package:` imports across modules. There
are **150 relative imports** in `lib/` and **zero** `package:sreerajp_youtube_shortcut/`
imports.

### Problem 8 — The sealed error hierarchy is declared but never used

`lib/core/errors/app_exception.dart` defines `AppException` with `ShortcutValidationException`,
`ShortcutStorageException`, and `YoutubeLaunchException`. Nothing anywhere else in `lib/`
references any of them. `CLAUDE.md` states "use sealed exceptions in `lib/core/errors/`. Do not
throw raw strings or generic `Exception`" — the rule is written down but not followed.

### Problem 9 — `home_screen.dart` is 1,926 lines

Engineering standard §6.2 requires widgets to stay small and single-purpose. One screen file at
nearly 2,000 lines (with `add_shortcut_screen.dart` at 740, `qr_scanner_screen.dart` at 700,
and `shortcut_detail_screen.dart` at 650 behind it) is well past that.

---

## 2. The plan

The work splits into five phases. Each phase is self-contained and leaves the app building,
analyzing clean, and passing tests. **Phases 1 and 2 are the MUST-fix items.**

### Phase 1 — Restructure `lib/` to the baseline layout

Delete `lib/src/` and move every file to its layer folder. No logic changes — moves, import
rewrites, and splitting the two mixed-content files.

| Current path | New path |
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
| `lib/src/app_shell.dart` | split → `lib/app/app_shell.dart` + `lib/app/theme/app_theme.dart` |
| `lib/src/screens/*.dart` (11 files) | `lib/screens/*.dart` |
| `lib/src/widgets/*.dart` (2 files) | `lib/widgets/*.dart` |

Notes on this phase:

- `state/` is chosen over `providers/` because the two classes are named `…Store` and are plain
  `ChangeNotifier`s. §3 requires picking one name and using it consistently — this plan picks
  `state/`.
- `app_shell.dart` currently holds both the app widget and the theme. The theme moves to
  `lib/app/theme/app_theme.dart` so the `theme/` folder from §3 exists.
- All 150 relative imports become `package:sreerajp_youtube_shortcut/...` imports (fixes
  Problem 7).
- `test/` is re-laid out to mirror the new `lib/`: `test/models/`, `test/services/`,
  `test/state/`, plus `test/widget_test.dart` at the root.

### Phase 2 — Add localization

1. Add `flutter_localizations` (SDK dependency) and `generate: true` to `pubspec.yaml`.
2. Create `l10n.yaml` at the project root (`arb-dir: lib/l10n`, `template-arb-file: app_en.arb`,
   `output-localization-file: app_localizations.dart`, `nullable-getter: false`).
3. Create `lib/l10n/app_en.arb` and move every user-visible string into it, each with its
   `@key` description entry.
4. Wire `localizationsDelegates` and `supportedLocales` into the app widget.
5. Replace every literal in the 11 screens and 2 dialogs with an `AppLocalizations` lookup.
   Literals stay only where the standard allows: log messages, non-UI exception messages, asset
   paths, and map/JSON keys.
6. Run `flutter gen-l10n`.

This phase is large — roughly 300–400 strings. I suggest doing it screen by screen, running
`flutter analyze` after each screen, so a mistake never spreads.

### Phase 3 — Rename the signing properties file

- Rename `android/keystore.properties` → `android/key.properties` (local file only; it is
  gitignored, so nothing about this rename is committed except the references to it).
- Update `android/app/build.gradle.kts`: the `rootProject.file(...)` path, the variable name,
  and the guard's error message text.
- Update every reference: `CLAUDE.md`, `AGENTS.md`, `docs/architecture.md`,
  `docs/release_process.md`, `docs/features.md`.
- Keep both names in `.gitignore` so an old local copy can never be committed by accident.

> The keystore file itself is **not** renamed and **not** touched. Nothing about the existing
> signing key changes — only the name of the small text file that points at it. I will not
> touch or read the current file's contents.

### Phase 4 — Fix the docs

1. Delete the five copied-down reference docs (Problem 5). Replace them with links to the
   submodule in `docs/GUIDELINES_MANIFEST.md`'s table, which already lists them.
2. Update the doc table in `CLAUDE.md` and `AGENTS.md` so the two now-deleted entries point at
   `docs/guidelines/…` instead of `docs/…`.
3. Rewrite the folder tree and every path in `docs/architecture.md` to match the real code
   after Phase 1 (Problem 3).
4. Rewrite `docs/project_structure.md`'s tree the same way, with no hedging.
5. Rename `docs/features.md` → `docs/sreerajp_youtube_shortcut_idea.md` (the §7 catalog type)
   and fold `docs/potential_features.md` into it as a "Planned / not built" section, then
   delete `potential_features.md` (Problem 6).
6. Add the localization rules section to `CLAUDE.md` and `AGENTS.md`, using the wording from
   `CLAUDE_MD_GUIDELINE.md` §4.
7. Update `docs/architecture.md` and `README.md` for the new `lib/` layout.

### Phase 5 — Code-quality fixes

1. Make the sealed exceptions real (Problem 8): have `ShortcutValidationException` thrown by the
   URL formatter / payload parser, `ShortcutStorageException` by the repository and backup
   service, and `YoutubeLaunchException` by the launcher service. Catch them at the state layer
   and turn them into UI messages. Remove any raw `throw Exception(...)`.
2. Split `home_screen.dart` (Problem 9). The list rows, the empty state, the search/filter bar,
   and the bulk-select toolbar each move to `lib/widgets/`, leaving the screen as layout plus
   state wiring. Target: under 400 lines.

---

## 3. Files to be changed

**Moved / created (Phase 1):** every file under `lib/src/` (28 files) moves as per the table
above; new `lib/app/theme/app_theme.dart`; `lib/core/constants/`; `lib/models/`;
`lib/repositories/`; `lib/services/`; `lib/state/`; `lib/screens/`; `lib/widgets/`. All 7 test
files move to mirror it.

**Created (Phase 2):** `l10n.yaml`, `lib/l10n/app_en.arb`.
**Changed (Phase 2):** `pubspec.yaml`, `lib/app/app_shell.dart`, all 11 screens, both dialogs.

**Changed (Phase 3):** `android/app/build.gradle.kts`, `.gitignore`, `CLAUDE.md`, `AGENTS.md`,
`docs/architecture.md`, `docs/release_process.md`, `docs/features.md`.

**Deleted (Phase 4):** `docs/flutter_project_engineering_standard.md`,
`docs/flutter_build_flavors_guide.md`, `docs/architecture_README.md`,
`docs/flutter_project_engineering_standard_README.md`, `docs/security_README.md`,
`docs/potential_features.md`.
**Renamed (Phase 4):** `docs/features.md` → `docs/sreerajp_youtube_shortcut_idea.md`.
**Changed (Phase 4):** `CLAUDE.md`, `AGENTS.md`, `docs/architecture.md`,
`docs/project_structure.md`, `README.md`.

**Changed (Phase 5):** `lib/core/errors/app_exception.dart`, the formatter, parser, repository,
backup service, launcher service, both state holders, `lib/screens/home_screen.dart`, plus new
widget files under `lib/widgets/`.

---

## 4. Verification after every phase

```bash
flutter pub get
flutter analyze                                    # must be zero warnings
flutter test                                       # must be zero failures
dart format --output=none --set-exit-if-changed .  # must pass
flutter build apk --flavor dev --debug             # must build
```

Phase 2 additionally runs `flutter gen-l10n`. Phase 3 additionally confirms that
`flutter build apk --flavor prod --release` still finds the signing config, and that
`git status` shows `android/key.properties` as ignored.

---

## 5. Things I want your decision on

1. **Scope.** Phases 1 and 2 are the two `MUST` breaches and are both large. Do you want all
   five phases, only the MUST ones, or one phase at a time with approval between each?
2. **`state/` vs `providers/`.** §3 says pick one. I recommend `state/` because the classes are
   named `…Store`. Say the word if you prefer `providers/`.
3. **The keystore rename (Phase 3).** This touches your signing setup. It is a low-risk rename
   of a pointer file, but it is your release key, so I want an explicit yes before I go near
   `android/`.
4. **Phase 5 is `SHOULD`-level, not `MUST`.** It is genuine cleanup, but it changes behaviour
   paths (exception types) more than the other phases do. It is reasonable to defer it.

---

**Do you approve this plan?** If yes, tell me which phases to run and how you want the four
decisions above resolved. I will not change any project file until you say so.
