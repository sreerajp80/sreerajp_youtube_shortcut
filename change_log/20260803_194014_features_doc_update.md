# Change log — Update docs/features.md

Implements plan: `plans/20260803_194014_features_doc_update.md`

## What changed

A background code audit checked `docs/features.md` against the real app code (every screen,
service, model, and manifest file). The document was already very accurate. Four small fixes
were made:

1. **Section 1 (App Overview)** — added a new value-pillar bullet: "No Ads, No In-App
   Purchases, No Monetization." Confirmed true in the code: no ad SDK and no billing/IAP plugin
   exist anywhere in the project.
2. **Section 5.1 (Home Screen)** — added a note that the Floating Action Button (Add Shortcut
   button) is hidden while Reorder mode or Multi-Select mode is active.
3. **Section 3 (Shortcut Domain & Data Model)** — added a note that a test-only in-memory
   repository implementation (`MemoryShortcutRepository`) exists alongside the shipped
   `SharedPreferences`-backed repository, and is not used in the real app.
4. **Section 5.6 (About Screen)** — fixed the stale example version string from `1.3.15+37` to
   `1.3.15+1`, matching the current `pubspec.yaml`.

## Files changed

- `docs/features.md`

No app code was changed; this was a documentation-only update.
