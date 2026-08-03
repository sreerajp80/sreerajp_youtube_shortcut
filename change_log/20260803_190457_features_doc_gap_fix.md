# Change log — fix gaps in docs/features.md

Implements plan: `plans/20260803_190457_features_doc_gap_fix.md`

## What changed

Edited `docs/features.md` only. No app code was touched.

1. Added a bullet under "Release Binary Hardening" (§2) describing the Gradle build gate that
   blocks `assembleProdRelease` / `bundleProdRelease` when `android/keystore.properties` is
   missing, and notes that debug/profile builds are never blocked.
2. Added a note under "Supported YouTube Link Formats" (§4) that handle-based shortcuts
   (`@handle`) are always saved with `targetType: Channel`, even though the canonical URL ends
   in `/live`.
3. Updated "Backup & Restore Screen" (§5.5):
   - Export description now states that launch count and last-launched timestamp are included
     in the exported file when a shortcut has been launched before (matches the real export
     code in `shortcut_models.dart`).
   - Import "Merge Mode" description now says new shortcuts are added to the top of the list,
     not the bottom.
4. Tightened two accessibility/layout bullets with exact values instead of vague wording:
   - Font-scale clamp is 1.3x, applied to shortcut card content (§1).
   - Grid switches from 2 to 3 columns at an available width of 680 logical pixels (§5.1).

## Found but not fixed here (flagged separately to the user)

The in-app Backup & Restore screen's help text says the exported file has "no analytics" and
only lists name/URLs/type/timestamps, but the export code does include launch count and
last-launched timestamp when set. This is a mismatch inside the app itself (screen copy vs.
export code), not a documentation error, so it was not changed as part of this doc-only plan.
