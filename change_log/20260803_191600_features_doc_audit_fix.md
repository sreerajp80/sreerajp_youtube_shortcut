# Fixed gaps in docs/features.md found during codebase audit

Implements: `plans/20260803_191439_features_doc_audit_fix.md`

## What changed

Checked `docs/features.md` against the real Flutter/Android code and fixed 7 small gaps.
No app code was changed — this was a documentation-only fix.

1. **Filter chips**: Fixed the doc to say there are 4 category chips (Video, Shorts,
   Playlist, Channel), not 5. There is no separate "All" chip; showing everything is just
   the state when no chip is picked.
2. **Manifest**: Added the `PROCESS_TEXT` package-visibility query (already shown to users
   on the Permissions screen) to the manifest list in Section 2 and to the Permissions
   Screen section (5.7).
3. **Detail screen**: Added a line about the extra "Copy URL" / "Edit" button row that
   exists on the Shortcut Detail screen, separate from the app bar icons and per-card copy
   buttons.
4. **INTERNET permission**: Made clear that "no INTERNET permission" applies to the shipped
   release build. Debug and profile builds add it only for Flutter's own dev tools
   (hot reload, DevTools) and are never given to users. Updated in Section 2 and Section 8.
5. **Backup file fields**: Added the `appId` and `shortcutCount` fields, which are always
   written to the backup JSON file but were missing from the doc's field list.
6. **AI-used label default**: Added the actual default value (`OpenAI GPT-5`) that shows on
   the About screen when no build-time override is given.
7. **Scheme auto-prefixing wording**: Reworded to match the real order of operations — the
   app adds `https://` first, then checks if the host is supported, rather than checking the
   host first.

## Files changed

- `docs/features.md`

## Verification

Re-read the full updated file. All edits fit their sections and do not conflict with any
other part of the doc. No app code or tests were touched, so no build/test run was needed.
