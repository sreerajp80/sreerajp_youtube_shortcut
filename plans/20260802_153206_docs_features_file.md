# Plan: Create docs/features.md

**Status:** completed

## What is the issue

There is no single document that lists what this app is and what it can do. The user
wants a `docs/features.md` file that describes the app and lists all its features, so
they can share it with an LLM later. That LLM will use it to check what features already
exist before adding a new feature to this or another app. The file must be accurate and
complete on the first try, so it should be based on a careful read of the current code,
not guesses.

## Files to be changed

- `docs/features.md` — new file (created only, nothing else touched)

## Plan for the fix

Write `docs/features.md` with these sections, based on the codebase analysis already done:

1. **What this app is** — 2-3 sentence summary: an offline Android/Flutter app for saving
   named quick-launch shortcuts to YouTube videos, Shorts, playlists, and channels, and
   opening them directly in the YouTube app.

2. **Shortcut data model** — the fields a shortcut has (name, source URL, canonical URL,
   type, created/updated/last-launched times, launch count) and the four shortcut types
   (video, short video, playlist, channel).

3. **Supported YouTube link formats** — the list of URL/handle patterns the app accepts
   (bare handle, `@handle`, `youtu.be`, `watch?v=`, `live/`, `shorts/`, `playlist?list=`,
   `/channel/`, `/c/`, `/user/`) and accepted hosts.

4. **Screens and user-facing features**, one subsection per screen:
   - Home screen (grid/list view, sort options, manual reorder, search, filter chips,
     swipe-to-delete, multi-select with bulk delete/export, clear all, empty state,
     share-sheet receiving)
   - Add/Edit Shortcut screen (fields, live URL preview, clipboard-paste suggestion,
     format hint chips, validation)
   - Shortcut Detail screen (open, copy URL, edit, delete, activity stats)
   - Settings screen (theme choice)
   - About screen
   - Permissions screen (informational, no runtime permissions)
   - Channel handles / Shortcut Behavior screen (explains `/@handle/live` routing)
   - Backup & Restore screen (export to file, import with Merge/Replace modes)

5. **App-wide settings** — theme (system/light/dark), layout (grid/list), sort order
   (manual/alphabetical/newest/recent/most used).

6. **Platform behavior** — explicit Android intent launch to the YouTube app, no browser
   fallback, share-target intent filter, no runtime permission prompts, no INTERNET
   permission, `allowBackup=false`.

7. **What this app explicitly does NOT do** — no network access, no sign-in, no cloud
   sync, no in-app playback, no live-status checking, no Android home-screen widgets or
   pinned shortcuts, no analytics.

The content will be written once, in full, using the plain-English style required by the
global rules, and will not reference file paths or line numbers (that belongs in
architecture docs, not this feature summary).

## After approval

Once approved, create `docs/features.md`, then write a change log entry in
`change_log/` describing the new file, per the global workflow rules.
