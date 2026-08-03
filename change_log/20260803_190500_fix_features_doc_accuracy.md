# Fix accuracy issues in docs/features.md

Implements: `plans/20260803_185650_fix_features_doc_accuracy.md`

## What changed

Updated `docs/features.md` to match the real app UI, after checking the doc against the actual
source code:

1. **§5.1 Home Screen app bar** — replaced the wrong description of a single combined
   "Overflow Menu" (Sort/Reorder/Import-Export/Settings/About) plus a "search toggle button"
   with the real layout: a Grid/List switch button, a separate Sort menu, a separate "Options"
   menu (only Reorder + Clear all), and an always-visible Settings button. Added a note that
   Import/Export, About, Permissions, and Channel Handles are only reachable from the Settings
   screen, not the Home app bar. Replaced the search-toggle wording with a description of the
   always-inline search box, and noted the match counter is on the "Shortcut Sections" heading.
2. **§5.5 Backup & Restore Screen** — added the "Replace all shortcuts?" confirmation dialog
   that appears before an Import & Replace operation.
3. **§5.6 About Screen** — added a short note explaining that the app shows three different
   name strings in different places (Android launcher label, in-app title, Home app bar title),
   so this isn't mistaken for a documentation error later.

## What was checked and found accurate (no change needed)

Data model, supported link formats and host domains, sort modes, target types, build flavors,
manifest protections, backup file format, security/privacy claims, and the "what this app does
NOT do" section were all verified against the code and left unchanged.
