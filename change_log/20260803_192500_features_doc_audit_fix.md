# Change Log: Fix and Complete `docs/features.md`

Implements plan: `plans/20260803_191940_features_doc_audit_fix.md`

## What changed

Only `docs/features.md` was edited. No app code changed.

### Corrected wrong or misleading claims

- **§2 and §5.7**: Fixed the explanation of the `PROCESS_TEXT` `<queries>` manifest
  entry. It was described as making the app discoverable as a "process text" target in
  other apps — that is backwards. The `<queries>` block only lets *this app* see other
  apps that can handle `PROCESS_TEXT`; it does not make this app itself selectable in
  another app's text-selection menu (no such intent-filter exists in the manifest).
- **§5.1**: Renamed "Single-Item Context Menu" to "Single-Item Quick Actions" and
  described it accurately — three separate app bar icon buttons, not a popup menu.
- **§5.1**: Corrected "Visual reorder handles appear on cards" — there is no separate
  handle icon; the whole card becomes draggable after a long-press in Manual sort mode,
  with a highlighted border on the current drop target.
- **§7**: Fixed the quoted error Snackbar text to match the real message: "The YouTube
  app could not be opened. Check that it is installed and enabled on this device."
- **§5.8**: Added a note that the in-app Channel Handles screen's own help text is a
  simplification, and pointed to §4 for the real bare-handle-vs-`@`-handle dot rule.

### Filled in missing behaviors

- **§2**: Documented `MainActivity`'s `launchMode="singleTop"`, empty `taskAffinity`,
  `exported="true"`, and the `configChanges`/`adjustResize` settings that keep share
  intent handling stable across rotation/keyboard changes.
- **§4**: Documented that shared-text extraction only recognizes `http(s)://` URLs
  (anything else passes through unmodified), and that a malformed pseudo-scheme still
  gets auto-prefixed with `https://`.
- **§5.1**: Documented that back-button during multi-select clears the selection instead
  of leaving the screen, and that the "Reorder shortcuts" menu item is disabled/relabeled
  outside Manual sort mode.
- **§5.2**: Documented that the live URL preview disappears once a full `https://` URL is
  typed, and that the clipboard "Paste" suggestion is gated on a substring check that
  excludes bare handles.
- **§5.4**: Expanded the Settings screen section to mention the intro card, the live
  one-line description under the theme picker, and the dark-mode accent color.
- **§5.5**: Documented the concurrent export/import guard, the broad MIME allow-list for
  import file picking, that exported `appId` is always the prod package id (even from a
  dev build), that unused JSON fields are omitted rather than nulled, and that merge-mode
  duplicate detection also applies within the imported file itself.

### App Description (§1)

- Added a new value pillar, "Guarded, Reversible-by-Confirmation Data Operations,"
  covering the confirmation dialogs on all destructive actions and the concurrent
  operation guard — a distinct design decision from the permission/privacy model.
- Added a mention of single-item quick actions under "Power User Productivity &
  Organization."

## Why

The user asked for a critical review of `docs/features.md` to confirm all features are
listed and the App Description is inclusive. A research pass comparing the doc against
the real Flutter/Android code found one clearly incorrect technical claim, several
smaller wording inaccuracies, and a number of real behaviors missing from the doc. This
change brings the doc in line with the actual app behavior.
