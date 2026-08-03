# Update docs/features.md — fix stale info and add missing details

**Status:** completed

## What is the issue

I checked `docs/features.md` against the actual app code (a background code audit read every
screen, service, model, manifest, and build file). The document is very accurate overall. It
found four small things worth fixing:

1. **Stale version example.** Section 5.6 (About Screen) shows the example version string
   `1.3.15+37`. The real version in `pubspec.yaml` is `1.3.15+1`. The example no longer matches
   the app.
2. **Missing value pillar.** Section 1 (App Overview) lists many value pillars (privacy, no
   tracking, accessibility, etc.) but never says the app has no ads, no in-app purchases, and no
   monetization. This is true in the code (no ad SDK, no billing plugin anywhere), and it fits
   naturally with the other privacy-focused pillars already listed.
3. **FAB behavior not mentioned.** Section 5.1 (Home Screen) does not mention that the Floating
   Action Button (the "Add Shortcut" button) is hidden while the user is in Reorder mode or
   Multi-Select mode. This is true in the code (`home_screen.dart`).
4. **Test-only repository not mentioned.** Section 3 (Shortcut Domain & Data Model) only
   describes the `SharedPreferences`-backed repository. There is also an in-memory repository
   implementation (`MemoryShortcutRepository`) used for tests, which is not mentioned anywhere.

## Files to be changed

- `l:\Android\sreerajp_youtube_shortcut\docs\features.md` (only this file)

## The plan for the fix

1. In **Section 5.6 (About Screen)**, change the version example from `1.3.15+37` to
   `1.3.15+1` so it matches the current `pubspec.yaml`.
2. In **Section 1 (App Overview)**, add one new bullet to the value-pillar list:
   - "No Ads, No In-App Purchases, No Monetization" — state plainly that the app has no
     advertising SDKs, no in-app purchases, and no monetization of any kind; it is free to use
     with no hidden business model.
3. In **Section 5.1 (Home Screen)**, add a short note near the Floating Action Button bullet
   stating that the FAB is hidden while Reorder mode or Multi-Select mode is active.
4. In **Section 3 (Shortcut Domain & Data Model)**, add a short note after the existing
   repository description mentioning that a separate in-memory repository implementation
   (`MemoryShortcutRepository`) exists for testing purposes and is not used in the shipped app.

No code files change. This is a documentation-only update, so no build/test verification beyond
proofreading the markdown is needed.
