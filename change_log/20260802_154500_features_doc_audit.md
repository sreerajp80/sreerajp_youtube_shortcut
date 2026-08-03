# Change log — Update docs/features.md after code audit

Implements: `plans/20260802_153919_features_doc_audit.md`

## What changed

Edited `docs/features.md` only. No app code was touched.

- Fixed two claims that didn't match the code:
  - "Process text" is not actually wired up as a receiver in this app (only a
    package-visibility `<queries>` entry exists) — the doc no longer claims it delivers
    shared text to the app.
  - Manual reorder is not started by a plain long-press. Long-press always opens
    multi-select mode; drag-to-reorder only works after choosing "Reorder shortcuts"
    from the menu.
- Added a new "App identity and Android hardening" section (icon, launcher label,
  splash theme, `allowBackup="false"`, `usesCleartextTraffic="false"`).
- Added a new "Errors shown to the user" section (inline vs. snackbar errors, and the
  best-effort launch-count recording that silently does not error).
- Documented the backup file's real contents (type tag, schema version, app id, export
  timestamp, shortcut count), its filename pattern, and the specific reasons an import
  can be rejected.
- Documented the responsive grid column count (2 / 3 / 1) and the accessibility
  text-scale cap on shortcut cards.
- Documented the URL-extraction behaviour for shared text and clipboard suggestions
  (first URL is pulled out of surrounding text).
- Documented the handle validation edge case (dots only allowed with a leading `@`).
- Clarified how the About screen's version and build metadata are sourced and
  displayed.
- Clarified exactly what "fails to start up" covers on the Fatal Error screen, and
  noted the debug-only red error screen.
