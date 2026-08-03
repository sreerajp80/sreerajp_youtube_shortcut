# Update docs/features.md to cover missing features and fix small gaps

**Status:** completed

## Files to be changed

- `docs/features.md`

## The issue

I checked `docs/features.md` against the actual app code (screens, store, main.dart,
Android manifest). The app description and feature list are mostly correct, but a few
real features and behaviors are missing, and a couple of details are stated less
precisely than the code supports:

1. **Duplicate shortcut names are rejected.** `shortcut_store.dart` blocks saving a
   shortcut if its name (trimmed, case-insensitive) already matches an existing one,
   both when adding and when editing. The doc mentions "rejects a duplicate name" once
   in passing but doesn't explain the rule (case-insensitive, trimmed) or that it
   applies to edits too.
2. **Channel handle format check.** The Channel Handles screen explains that a handle
   is validated only for shape: 3–30 letters, digits, dot, dash, or underscore. This
   concrete rule isn't in the doc.
3. **Import duplicate handling detail.** The Backup & Restore screen's Merge mode
   message is more specific than the doc says: it reports how many shortcuts were
   added vs. skipped because of a name already in use.
4. **Reorder mode entry point.** The Home screen has a dedicated "Reorder shortcuts"
   action (app bar / menu), not just drag-in-place — worth naming explicitly.
5. **Version/build info source.** The About screen's build number and build date can
   come from a native Android channel (set at build time) with a fallback to the
   package's own metadata / today's date. The doc just says "shows ... build number,
   build date" without explaining this.
6. **Startup error handling.** `main.dart` installs global Flutter/async error
   handlers and falls back to the Fatal Error screen if startup itself fails (e.g.
   local storage or package metadata can't be read). The doc lists the Fatal Error
   screen but not why/when it appears.
7. **`allowBackup="false"`.** Already required by CLAUDE.md and present in the
   manifest — worth a one-line mention next to "Does not sync or back up data online"
   since it reinforces that claim at the OS level.
8. **`PROCESS_TEXT` intent filter.** The manifest declares a `PROCESS_TEXT` query/
   intent, meaning the app can also appear when the user selects plain text elsewhere
   and chooses "Share" / "Process text" — not just the standard share-into-app case
   already documented. Worth folding into the existing share-into-app bullet as the
   same underlying mechanism.

None of these are behavior changes — this is a documentation-only update to make
`features.md` a complete and accurate reference.

## Plan for the fix

Edit `docs/features.md` only, no code changes:

- In the **Shortcut data model** / **Add / Edit Shortcut screen** section, add a line
  about duplicate-name rejection being case-insensitive and applying to both add and
  edit.
- In the **Channel Handles (Shortcut Behavior) screen** section, add the concrete
  handle shape rule (3–30 letters/digits/dot/dash/underscore).
- In the **Backup & Restore screen** section, tighten the Merge description to mention
  the added/skipped count message.
- In the **Home screen** section, name the dedicated reorder-mode entry point
  alongside "Manual reorder."
- In the **About screen** section, add a short note that build number/date can come
  from the build system, with a sensible fallback.
- In the **Fatal Error screen** section, add a line that global error handlers are
  installed and this screen also appears if app startup itself fails.
- In **What this app does NOT do**, add a short clause noting Android's own
  auto-backup is disabled (`allowBackup=false`), next to the existing "no online sync"
  bullet.
- In the **Home screen** share-into-app bullet, mention that this also covers text
  selected and shared/processed from other apps, not only explicit share-menu links.

No other files change. This keeps the doc's structure and tone the same, just filling
gaps found by comparing it to the current code.
