# Fixed remaining accuracy gaps in docs/features.md (second pass)

Implements plan: `plans/20260803_191025_features_doc_accuracy_pass2.md`

## What changed

Edited `docs/features.md` only (no app code changed):

1. **§1 accessibility bullet** — removed the unqualified claims of "48x48dp minimum touch
   targets" and "Built with Flutter semantics for screen reader support (TalkBack)". Replaced
   with accurate wording: TalkBack support comes from Flutter/Material's default accessibility
   tree (no custom `Semantics` widgets exist in the code), and most controls use default Material
   tap target sizing while the category filter chips are deliberately set smaller
   (`VisualDensity.compact` / shrink-wrapped), so there is no enforced app-wide minimum.

2. **§4 (Supported YouTube Link Formats)** — added a note that bare (non-`@`) handles do not
   accept dots, while `@`-prefixed handles do. A bare handle like `some.channel` is rejected;
   `@some.channel` is accepted.

3. **§5.2 (Add / Edit Shortcut Screen)** — corrected "Interactive Format Hint Chips... Tappable...
   pre-fill input fields" to "Static Format Hint Chips" — these are plain, non-interactive
   example chips with no tap handler in the real code.

4. **§2 (Native Platform Channels)** — added a line naming `android_intent_plus` as the plugin
   that builds and dispatches the explicit YouTube launch Intent described in §7.

## Why

A code audit of the screens, URL formatter, manifest, and gradle files found these specific
claims did not match the actual implementation (no `Semantics` widgets, filter chips smaller than
48dp, format chips not tappable) or were missing (bare-vs-`@` handle character set difference,
the intent-launch plugin name). Earlier plans in this project already fixed a separate, larger
round of gaps (build gate, handle classification, app bar description, etc.) — those are still
correct and were not touched again.
