# Change Log: Fill small gaps in docs/features.md

Implements: `plans/20260803_194655_features_doc_fixes.md`

## What changed

Only `docs/features.md` was edited. No app code, tests, or build files changed.

A background audit compared the document against the real app code and found the
document was already accurate, with no wrong or outdated claims. Five small true
facts about the app's behavior were missing, so they were added in the matching
sections:

1. §5.1 Bulk Delete — noted that deleting with no matching shortcut ids is a
   safe no-op.
2. §5.1 Manual Drag-and-Drop Reordering — noted that dropping a card in the
   same place, or an invalid drag, is a safe no-op.
3. §5.5 Security & Validation Guard (Backup & Restore) — noted that a negative
   launch count in an imported file is clamped to `0` on import.
4. §5.3 Activity Insights Card — clarified that a shortcut with exactly 0
   launches shows "Never launched", the same text as one never opened, instead
   of "0 launches".
5. §5.6 About Screen — noted that the app description and notes text on this
   screen are fixed static constants (`lib/src/about_constants.dart`), not
   computed at runtime.
