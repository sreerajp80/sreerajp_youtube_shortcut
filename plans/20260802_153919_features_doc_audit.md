# Update docs/features.md — fix gaps found in code audit

**Status:** completed

## Files to be changed

- `docs/features.md`

## What the issue is

I compared `docs/features.md` against the real code (screens, services, manifest,
error types) and found two kinds of problems:

1. **Missing details** — real behavior that exists in code but isn't written down.
2. **Wrong claims** — two places where the doc says something that the code does not
   actually do.

The two wrong claims:

- **"Process text" claim.** The doc says selecting text elsewhere and using Android's
  "Process text" action sends it to this app. Checked `AndroidManifest.xml`: there is
  no `PROCESS_TEXT` intent-filter on the app's activity. The `<queries>` block only
  lets the app *see* other apps that offer "Process text" — it does not make this app
  *receive* that action itself. So this doc line is incorrect and should be corrected.
- **Reorder claim.** The doc says long-pressing a card starts drag-to-reorder. In
  `home_screen.dart`, long-press always enters multi-select mode. Drag-to-reorder only
  works after the user picks "Reorder shortcuts" from the menu; long-press-and-drag
  then works only inside that mode.

## The plan for the fix

Edit `docs/features.md` only, section by section:

1. **App identity / manifest section (new short section)** — add a small section
   noting the app icon, launcher label, splash theme, `allowBackup="false"`, and
   `usesCleartextTraffic="false"` manifest hardening, so this is documented somewhere.

2. **Home screen — Share into the app** — remove the "Process text" claim (or say
   explicitly that Process-text handling is not wired up; the `<queries>` entry is only
   for app visibility, not for receiving that action). Add a short note that when
   shared text contains a URL plus other text, the app extracts just the first URL and
   strips trailing punctuation, falling back to the raw text if no URL is found.

3. **Home screen — Manual reorder** — correct the entry mechanism: long-press always
   opens multi-select; drag-to-reorder is only available after choosing "Reorder
   shortcuts" from the menu, and works by long-press-and-drag while in that mode.

4. **Home screen — Search box** — correct the wording: it's a count badge (e.g. "3/12")
   next to the section heading, not literal "X of Y matches" text.

5. **Home screen — grid layout** — note it's responsive: 2 columns normally, 3 on wider
   screens, 1 column in list mode.

6. **Add/Edit screen — clipboard suggestion** — note it also extracts the first URL out
   of clipboard text (not just an exact link), and the suggestion goes away once the
   user starts typing in the link field.

7. **Add/Edit screen — handle validation** — note the edge case: a handle without `@`
   cannot contain dots (only letters/digits/dash/underscore, 3–30 chars) to be
   recognized as a handle; with `@` dots are allowed.

8. **Backup & Restore screen** — document the actual file contents (a type tag, a
   schema version, app id, export timestamp, shortcut count, plus the shortcuts) and
   the filename pattern used when saving. Note that files with an unrecognized or
   missing schema version, or that aren't valid JSON of the right shape, are rejected
   with a clear error.

9. **New short section: Errors shown to the user** — list the distinct error
   situations (bad input on Add/Edit shown inline; storage, backup, and YouTube-launch
   problems shown as a snackbar message), and note that if recording "last launched" /
   "launch count" fails after successfully opening YouTube, the app does not show an
   error for that (it doesn't want to bother the user over something that already
   worked).

10. **About screen** — clarify version is shown as `version+buildNumber` (e.g.
    `1.3.15+1`), and that build number/date come from a value baked in at build time via
    a small platform channel, falling back to the app package's own version info, and
    then to today's date, in that order.

11. **Fatal Error screen** — clarify what "fails to start up" covers: reading local
    storage or the app's package info. Also note the app has a global handler for
    errors that happen after startup, but in a debug build Flutter's own red error
    screen can still appear.

12. **Accessibility note** — mention shortcut cards cap how large the system font-size
    setting can make their text (so very large accessibility font settings don't break
    the card layout).

Small, low-value implementation details (exact animation durations, drag-delay
milliseconds) will be left out to keep the doc readable — the doc is meant to describe
features, not implementation internals.

No app behavior changes — this is a documentation-only fix.
