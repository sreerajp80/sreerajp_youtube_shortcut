# Change Log — Update `docs/guidelines` Submodule

**Plan:** `plans/20260817_203222_update-guidelines-submodule.md`

## What changed

The `docs/guidelines` submodule (Flutter Guidelines) was moved forward to the
latest commit on `master`.

- Old commit: `aed1261`
- New commit: `2b381be` ("Update")

The update was a clean fast-forward. The submodule work tree is clean.

## What the new guidelines commit brings

Files updated inside the submodule:

- `AGENTS_MD_GUIDELINE.md`
- `CLAUDE_MD_GUIDELINE.md`
- `DOCS_FOLDER_GUIDELINE.md`
- `flutter_project_engineering_standard.md`
- `flutter_project_engineering_standard_README.md`
- `guideline.md`
- new plan and change log files about making localisation (l10n) mandatory and
  keeping local system details out of shared files

## Repo state

- Only the submodule pointer changed in this repo (`M docs/guidelines`).
- The change is left **uncommitted**, as agreed in the plan.
- No app code changed, so `flutter analyze` and `flutter test` were not run.

## Follow-up to consider

The new guidelines make localisation mandatory. This project may need a separate
plan to check whether it meets that rule.
