# Fix accuracy issues in docs/features.md

**Status:** completed

## Files to be changed

- `docs/features.md`

## What the issue is

I compared `docs/features.md` against the actual app code (screens, models, manifest, gradle
config). Most of the document is correct, but a few parts describe the Home screen's app bar
and a couple of other details in a way that does not match the real UI. If someone used this
doc to understand the app without opening the code, they would get the wrong picture in these
spots.

Concrete problems found in the code:

1. **Home screen app bar / overflow menu (§5.1) is described wrong.**
   The doc says there is one "Overflow Menu" holding Sort, Reorder, Import/Export, Settings,
   and About, plus a separate "Search toggle button". In the real code
   (`lib/src/screens/home_screen.dart`) there are four separate controls, not one menu:
   - a Grid/List layout switch button
   - a separate Sort popup menu (its own icon)
   - a separate "Options" popup menu that contains only **Reorder shortcuts** and
     **Clear all shortcuts**
   - a Settings button that is always visible in the app bar (not inside any menu)

   Also, **Import/Export, About, Permissions, and Channel Handles are not reachable from the
   Home app bar at all** — they only appear as tiles inside the Settings screen.

   And there is **no search "toggle" button**. The search box is simply shown inline on the
   Home screen body whenever there are saved shortcuts (and the user isn't reordering or
   selecting). The "X/Y match counter" badge sits on the "Shortcut Sections" heading, not on
   a search toggle.

2. **Backup & Restore screen (§5.5) is missing a confirmation dialog.**
   "Import & Replace" shows its own "Replace all shortcuts?" confirmation dialog before wiping
   existing data. The doc doesn't mention this.

3. **App name is inconsistent across three places, and the doc doesn't note this.**
   - Android launcher label (from Gradle, per flavor): "YT Shortcuts" / "YT Shortcuts Dev"
   - In-app `MaterialApp` title and About screen header: "SreerajP YouTube Shortcuts"
   - Home screen's visible app bar title: "YT Shortcuts"

   The doc's own title already uses both names together, but doesn't explain that the app
   itself is inconsistent about which name it shows where. Worth a short factual note so this
   doesn't look like a doc mistake later.

Everything else in the document — data model, supported link formats and host domains, sort
modes, target types, build flavors, manifest protections, backup file format, security/privacy
claims, and the "what this app does NOT do" section — was checked against the code and is
accurate. No new features were found in the code that are completely missing from the doc.

## The plan for the fix

Edit `docs/features.md`:

1. Rewrite §5.1 "Home Screen" app bar bullets to describe the four separate controls
   (Layout switcher, Sort menu, Options menu with only Reorder + Clear all, always-visible
   Settings button) instead of one combined "Overflow Menu". Add a line clarifying that
   About, Permissions, Channel Handles, and Import/Export are reached via the Settings screen,
   not the Home app bar. Replace the "search toggle button" wording with a description of the
   always-inline search box, and note the match counter lives on the "Shortcut Sections"
   heading.
2. Add a bullet to §5.5 "Backup & Restore Screen" for the "Replace all shortcuts?" confirmation
   dialog shown before an Import & Replace operation.
3. Add a short note (likely in §1 or as a small callout near the About screen section in §5.6)
   explaining the three different app name strings and where each one shows up.

No code changes, no other files touched.
