# Change Log: Guidelines Alignment & About JSON Architecture

**Date:** 2026-08-09
**Plan:** `plans/20260809_203000_guidelines_alignment.md`

## Summary of Changes

1. **About-Screen Single Source of Truth**:
   - Added `assets/config/app_config.json` with app metadata.
   - Added `lib/core/config/app_config.dart` (`AppConfig` model with `fromJson` and `fallback`).
   - Added `lib/core/config/config_service.dart` (`ConfigService` asset loader).
   - Registered `assets/config/` in `pubspec.yaml`.
   - Updated `lib/src/screens/about_screen.dart` to dynamically render `details` map entries per `guideline.md` §1.6.
   - Updated `lib/main.dart` and `lib/src/app_shell.dart` to load `AppConfig` and expose it via `Provider`.

2. **Root Instruction Standards (`CLAUDE.md` & `AGENTS.md`)**:
   - Updated `CLAUDE.md` and `AGENTS.md` to match `CLAUDE_MD_GUIDELINE.md` and `AGENTS_MD_GUIDELINE.md`.
   - Added Project Identity table and `docs/GUIDELINES_MANIFEST.md` link.
   - Inlined mandatory Workflow Rules (plan-approve-log) and Communication Rules (simple English).

3. **Mandatory Baseline Docs**:
   - Created `docs/workflow_rules.md`, `docs/dependencies.md`, `docs/project_structure.md`, `docs/implementation_plan.md`, and `docs/implementation_progress.md` in accordance with `DOCS_FOLDER_GUIDELINE.md` §6.

## Verification
- `dart format` — 0 unformatted files.
- `flutter analyze` — 0 errors / 0 warnings.
- `flutter test` — All 50 tests passed cleanly.
