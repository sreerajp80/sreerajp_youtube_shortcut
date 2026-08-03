# Plan: Fix and Complete `docs/features.md`

**Status:** completed

## The issue

The user asked for a critical review of `docs/features.md` to check that all features
are listed and that the App Description is inclusive. I compared the doc against the
real code (models, screens, manifest, native Android code) using a background research
agent. The doc is mostly accurate and detailed, but has:

- One clearly **wrong** technical claim (about what the `PROCESS_TEXT` manifest
  `<queries>` block does).
- Several smaller **inaccurate** wording issues (doc says something that doesn't match
  what the code actually does).
- Several real **missing** behaviors that a feature doc should mention, so a reader
  (developer, AI assistant, or auditor) isn't surprised by the actual app behavior.
- One gap in the App Description value pillars (§1): a "safe, guarded backup/restore"
  angle that exists in the code but isn't called out as a pillar.

## Files to change

- `l:\Android\sreerajp_youtube_shortcut\docs\features.md` (only this file)

## Planned fixes

### A. Correct wrong/inaccurate claims

1. **§2 and §5.7 — `PROCESS_TEXT` `<queries>` explanation is backwards.**
   Fix: A `<queries>` element lets *this app* see other apps that can handle
   `PROCESS_TEXT` (Android 11+ package-visibility rule). It does **not** make this app
   itself selectable as a "process text" target in other apps' text-selection menus —
   that would require this app to declare its own `PROCESS_TEXT` intent-filter, which it
   does not have. Rewrite both mentions to state this correctly.

2. **§5.1 — "Single-Item Context Menu" wording.**
   The single-selection quick actions (View/Edit/Copy) are three separate icon buttons
   in the app bar, not a popup/context menu. Only "Select all" is a real popup menu, and
   only shown when not all visible items are already selected. Reword to "Single-Item
   Quick Actions" and describe accurately.

3. **§5.1 — "Visual reorder handles appear on cards."**
   There is no separate handle icon. In Manual sort mode the whole card becomes
   long-press-draggable, with a highlighted border on the active drag target. Reword.

4. **§7 point 4 — Snackbar message quoted incorrectly.**
   Doc says `"YouTube app is not installed or disabled"`. The real message is
   `"The YouTube app could not be opened. Check that it is installed and enabled on this
   device."` Fix the quote.

5. **§5.8 — Channel Handles screen copy vs. real validation rule.**
   The in-app screen's own text says handles accept "alphanumeric, dots, dashes,
   underscores" for all handles, but the real rule (documented correctly elsewhere in
   §4) is that bare handles reject dots — only `@`-prefixed handles accept dots. Add a
   one-line note flagging that the in-app help text is a simplification and the
   authoritative rule is in §4.

6. **§5.4 Settings Screen — too thin.**
   Add the intro card copy, the fact that the theme picker shows a live one-line
   description under the selected option, and that dark mode uses a custom accent color
   for the segmented button.

### B. Add missing behaviors

7. **§4 — clarify scheme auto-prefixing edge case**: malformed pseudo-schemes (e.g.
   `http:/x`) are still auto-prefixed with `https://` rather than rejected outright,
   because the scheme-detection check only recognizes a strictly valid scheme token.

8. **§4 / §5.1 — shared-text extraction only matches `https?://` URLs.** If shared text
   has no `http(s)://` URL in it (e.g. a bare handle or a scheme-less
   `youtube.com/...` string plus commentary), the whole raw text is passed through
   unchanged, not cleaned.

9. **§5.2 — clipboard "Paste" suggestion is gated on a substring check**
   (`youtube.com/`, `youtu.be/`, `youtube-nocookie.com/`, `music.youtube.com/`) in
   addition to being a valid URL — so a bare `@handle` copied to the clipboard never
   triggers the suggestion banner, even though typing it manually is fully supported.

10. **§5.2 — live URL preview is suppressed once the input has an explicit `https://`
    scheme.** It only shows for bare handles / scheme-less paths as the user types.

11. **§5.1 — back button during multi-select mode.** Pressing system back while in
    selection mode clears the selection instead of leaving the screen.

12. **§5.1 — "Reorder shortcuts" menu item is disabled and relabeled** ("Reorder
    shortcuts (manual sort only)") whenever the active sort mode isn't Manual.

13. **§5.5 — Backup & Restore additions:**
    - A second export/import cannot be started while one is already in progress (native
      side returns a "busy" error and blocks it).
    - The system file picker for import accepts a broad MIME allow-list (JSON, plain
      text, octet-stream) — it isn't strictly limited to `.json` files.
    - The exported `appId` field is always the **prod** application ID string, even
      when the export is produced from a `dev`-flavor build.
    - Fields that don't apply (`lastLaunchedAtIso` when never launched, etc.) are
      omitted from the JSON entirely rather than written as `null`/`0`.
    - When merging an import, duplicate names are also checked *within the imported
      file itself* — if the file has two shortcuts with the same name, only the first
      is kept.

14. **§2 — manifest/native details worth a line each:**
    - `MainActivity` is `launchMode="singleTop"` with an empty `taskAffinity`, and
      `android:exported="true"` (needed for the launcher/share intent-filters on
      Android 12+). This is why repeated share intents reuse the same activity instance
      via `onNewIntent` instead of opening a new one.
    - A wide `android:configChanges` list plus `windowSoftInputMode="adjustResize"`
      avoid activity recreation across rotation/keyboard/locale changes, keeping
      in-progress share-intent handling stable.

### C. App Description (§1) addition

15. Add a new value pillar for the guarded/reversible nature of destructive data
    operations: explicit confirmation dialogs before Replace-mode import, before Clear
    All, before Delete, and the native busy-guard preventing concurrent backup
    operations. This is a real, distinct design decision (not just "no invasive
    permissions") and rounds out the "inclusive" description the user asked about.

16. Add one line under "Power User Productivity" noting the single-item quick actions
    (view/edit/copy without leaving selection mode) as a distinct productivity feature
    from bulk export/delete.

## What I will NOT change

- Minor/defensive-code nitpicks with no user-facing effect (e.g. the `'?'` avatar
  fallback for an unreachable empty-name case, ProGuard keep-list detail, AI-used
  default label — already correct) — not worth adding, per the doc's own stated
  purpose as a feature/behavior reference, not an exhaustive code-comment mirror.

## Approach

Direct edits to `docs/features.md` in place, section by section, keeping the existing
structure and tone. No other files touched.
