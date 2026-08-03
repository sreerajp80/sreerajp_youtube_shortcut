# Fix gaps in docs/features.md found during codebase audit

**Status:** completed

## What is the issue

The user asked to critically check `docs/features.md` against the real app and make sure
every feature is listed and the app description is complete.

I compared the doc against the actual Dart/Android code. The doc is mostly accurate and
detailed, but I found a few small mismatches and a few missing details. None of these are
big feature gaps — they are small wording fixes and a few missing facts.

## Files to change

- `docs/features.md` only. No app code changes.

## Findings and planned fixes

1. **"All" chip does not exist.**
   The doc (line 135) says the filter chips are "All, Video, Shorts, Playlist, Channel".
   In the code, there are only 4 chips: Video, Shorts, Playlist, Channel. "All" is just the
   state when no chip is picked, not a chip you can tap.
   **Fix:** Reword to say there are 4 category chips (Video, Shorts, Playlist, Channel), and
   showing all shortcuts is simply the default state when none are selected.

2. **Missing manifest detail: `PROCESS_TEXT` package-visibility query.**
   The Android manifest declares a `<queries>` block for `android.intent.action.PROCESS_TEXT`
   (needed so other apps can see this app for "select text -> process text" actions). This is
   already shown to users on the in-app Permissions screen ("Package visibility query"), but
   the doc's manifest/intent list (Section 2) and the Permissions Screen section (5.7) never
   mention it.
   **Fix:** Add one line under Section 2 "Android System Intent Receivers" and one line under
   Section 5.7 naming this query and its purpose.

3. **Detail screen has an extra Copy/Edit button row not mentioned.**
   The Shortcut Detail screen has a row with "Copy URL" and "Edit" outlined buttons, separate
   from the app-bar Edit/Delete icons and the per-card copy icons. The doc only mentions the
   app-bar Edit/Delete and per-card copy buttons.
   **Fix:** Add one bullet under Section 5.3 noting this quick-action button row.

4. **Debug/profile builds add INTERNET permission (dev tooling only).**
   Doc Sections 2 and 8 say "No INTERNET permission" without qualifying that this is true for
   the release/prod build only. Debug and profile builds add `INTERNET` because Flutter's own
   dev tooling (hot reload, DevTools) needs it. This is normal Flutter behavior, not a privacy
   issue, but the doc should say this applies to the shipped **release** build.
   **Fix:** Add a short qualifying note in Section 2 and Section 8 that the no-INTERNET
   guarantee applies to the release/prod build; debug/profile builds add it only for Flutter's
   own development tooling and are never distributed to users.

5. **Backup file has two more fields than documented.**
   Doc Section 5.5 says the backup file has `schemaVersion` and `payloadType`. The real file
   also always includes `appId` (the app's package id) and `shortcutCount` (the number of
   shortcuts in the file).
   **Fix:** Add these two fields to the bullet list in Section 5.5.

6. **Default AI-used label value is not stated.**
   Section 5.6 describes the About screen showing an "AI model/assistance label" but never
   gives the actual default value baked into the app when no build-time value is supplied.
   **Fix:** Add the default value as a parenthetical, e.g. "(defaults to `OpenAI GPT-5` if not
   overridden at build time via `APP_AI_USED`)".

7. **Minor wording precision: scheme auto-prefixing order.**
   Doc Section 4 implies the app checks the host is valid before adding `https://`. In code, it
   always adds `https://` first (if missing), then checks whether the resulting host is a
   supported YouTube domain.
   **Fix:** Reword the "Scheme Auto-Prefixing" bullet to reflect this order: prefix first,
   validate host after; invalid hosts are rejected at validation, not at the prefixing step.

## What I will NOT change

- No app code changes — this is a documentation-only fix.
- Not adding a full inventory of every internal class (e.g. the in-memory test repository) —
  that is implementation detail, not a user-facing feature, and is out of scope for this doc.
- Not treating item 4 (debug INTERNET permission) as a security problem — it is normal Flutter
  behavior for non-release builds; the doc will just be made precise about it.

## Plan for verification

After editing, re-read the full `docs/features.md` to confirm the edits read cleanly and
don't contradict any other section. No code/tests to run since this is a docs-only change.
