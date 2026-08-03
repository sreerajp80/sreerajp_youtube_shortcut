# Plan: Fill small gaps in docs/features.md

**Status:** completed

## Files to change

- `docs/features.md`

## What is the issue

I checked `docs/features.md` against the real app code (screens, store, models,
backup service, manifest, build config). The document is already very accurate —
no wrong or outdated claims were found, and the "Inclusive App Description" section
already covers every real capability of the app. There are only 5 small details
that exist in the code but are not written down in the doc:

1. `deleteShortcuts` (bulk delete) quietly does nothing if none of the selected
   ids match an existing shortcut — no save, no UI change. (`lib/src/shortcut_store.dart`)
2. `reorderShortcuts` (manual drag-and-drop) quietly does nothing if the drag
   indices are invalid or if the item is dropped back in the same place — no save
   happens. (`lib/src/shortcut_store.dart`)
3. When importing a backup file, if a shortcut's `launchCount` is a negative
   number, the app clamps it to `0` instead of keeping the bad value.
   (`lib/src/shortcut_models.dart`)
4. On the Shortcut Detail screen, a shortcut with exactly 0 launches shows the
   literal text "Never launched" — not "0 launches" as the current doc wording
   implies. (`lib/src/screens/shortcut_detail_screen.dart`)
5. The About screen has a couple of extra fixed description/notes text blocks
   (`AboutConstants.appDescription`, `notesBody`) that are only described in the
   doc in general terms. (`lib/src/about_constants.dart`)

None of these are bugs. They are just small, true facts about the app that are
missing from the "authoritative" feature document.

## Plan for the fix

Add short, precise notes to `docs/features.md`, in the sections that already
cover the related feature, so the doc stays organized the same way:

1. In §5.1 "Multi-Select / Selection Mode" bullet for Bulk Delete: add one
   sentence noting that deleting with no matching ids is a safe no-op.
2. In §5.1 "Manual Drag-and-Drop Reordering" bullet: add one sentence noting
   that an invalid or same-position drag is a safe no-op (nothing is saved).
3. In §5.5 "Security & Validation Guard" (Backup & Restore): add one sentence
   noting that a negative launch count found in an imported file is clamped to
   zero on import.
4. In §5.3 "Activity Insights Card": clarify that a shortcut with 0 launches
   displays the same "Never launched" text as one that was never opened,
   rather than showing "0 launches".
5. In §5.6 "About Screen": add one short line naming the two additional static
   text blocks (app description text and notes body) shown on that screen.

This is a documentation-only change. No app code, tests, or build files will be
touched.

## Change log

Will be written to `change_log/` after this plan is approved and applied.
