# Fix gaps in docs/features.md

**Status:** completed

## Files to be changed

- `docs/features.md`

## The issue

I checked `docs/features.md` against the real app code (all screens, the URL formatter,
the Android manifests, and the build scripts). The document is already very detailed and
most features are covered correctly. But I found a few real gaps and a couple of small
mismatches worth fixing:

1. **Missing feature — release-signing build gate.** The Gradle build blocks a `prod --release`
   build if `android/keystore.properties` is missing, with a clear on-screen error. This is a
   real security/build feature and is not mentioned anywhere in the doc's "Platform
   Architecture, Build Flavors & Android Security Hardening" section.

2. **Missing detail — handle links are typed as "Channel", not "Video".** When a user enters
   `@handle` or a bare handle, the app expands it to `.../@handle/live` but classifies the saved
   shortcut's `targetType` as **Channel** (not Video), even though the URL contains `/live`. This
   is easy to get wrong when reading the doc, so it deserves an explicit one-line note.

3. **Missing detail — importing merged shortcuts adds new ones to the top of the list**, not the
   bottom. The "Import Shortcuts / Merge Mode" section does not say this.

4. **Small mismatch — the app's own Backup screen text does not match its own export code.**
   The Backup & Restore screen tells the user the export contains only name/URLs/type/timestamps
   and says "no analytics." But the export code actually includes each shortcut's local launch
   count and last-launched time (only skipped when they are still the default/never-launched
   values). This is not a doc mistake — it is a mismatch between two parts of the app itself
   (the in-app help text and the real export code). I will flag this to you separately since it
   is not really a "features.md" fix; it may need a small code or copy change in the app instead.
   For the doc itself, I will make §5.5 (Import/Export) state precisely what is exported,
   including launch stats, to match what the code actually does.

5. **Minor precision gaps** — the doc says the font-scale clamp exists but not to what value
   (it's 1.3x, applied to shortcut card content); and it says grid becomes 3 columns on "tablets
   / wide screens" without giving the actual breakpoint (680 logical pixels wide). I will add
   these exact numbers since they are simple, stable facts that make the doc more useful as a
   reference.

Everything else the audit checked (multi-select, search/filter, drag-and-drop reorder,
swipe-to-delete, the five sort modes, on-device launch stats, clipboard-paste banner, copy-URL
actions, live URL preview, duplicate-name checks, supported hosts, handle length rules, and the
debug-only `INTERNET` permission already correctly scoped by the in-app Permissions screen) is
already present and accurate in the current doc. No changes needed there.

## Plan for the fix

Edit `docs/features.md` only, no code changes:

- **§2 (Platform Architecture...)**: add one bullet under "Release Binary Hardening" describing
  the keystore-properties build gate that blocks `prod --release`/`bundleProdRelease` without a
  release keystore.
- **§3 or §4 (Data Model / Link Formats)**: add a one-line clarifying note that `@handle` shortcuts
  are always saved with `targetType: Channel`, even though the canonical URL points at
  `/@handle/live`.
- **§5.5 (Backup & Restore Screen, Import Shortcuts)**: add a note that merged imports are added
  to the top of the list, and correct the "Export Shortcuts" description to state that launch
  count and last-launched timestamp are included in the exported file when a shortcut has been
  launched before (matching the real export code), rather than implying no usage data is ever
  exported.
- **§1 and §5.1**: tighten the accessibility bullet to state the font-scale clamp value (1.3x)
  and the grid breakpoint (680 logical pixels) precisely.

I will not touch any app code or in-app screen text as part of this doc fix — item 4's in-app
text mismatch is a separate question I'll ask you about after this plan is approved.

## After approval

Once you approve, I will make the edits above and then write a change log entry in
`change_log/` describing what was changed, per the project workflow rules.
