# Change log — update docs/features.md

Implements: `plans/20260802_000000_update_features_doc.md`

## What changed

Updated `docs/features.md` to add features and details that exist in the app code but
were missing from the doc. No app code was changed — this was a documentation-only
update.

Additions:

- Noted that shortcut names must be unique (case-insensitive, trimmed), for both add
  and edit.
- Named the dedicated "Reorder shortcuts" action on the Home screen, alongside
  drag-to-reorder.
- Clarified that "share into the app" also covers Android's "Process text" action on
  selected text, not just explicit share-menu links.
- Explained that About screen's build number/date can come from values set at build
  time, with a fallback to the app package's own metadata and today's date.
- Added the concrete channel-handle shape rule (3-30 letters/digits/dot/dash/
  underscore) to the Channel Handles screen section.
- Clarified that Backup & Restore's Merge mode reports how many shortcuts were added
  versus skipped as duplicates.
- Explained that the Fatal Error screen also covers startup failures (e.g. local
  storage or package info not readable), and that a global error handler is installed
  for errors after startup.
- Added a note that Android's own automatic app backup is disabled, next to the
  existing "no online sync" claim.

No features were found to be missing entirely from the app, and no documented claim
was found to be false.
