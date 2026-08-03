# Fix remaining accuracy gaps in docs/features.md (second pass)

**Status:** completed

## Files to be changed

- `docs/features.md`

## What the issue is

I re-checked `docs/features.md` against the real app code (all screens, the URL formatter,
manifest, and gradle files). Earlier plans already fixed several problems (build gate, handle
classification note, merge-import order, export launch-stats wording, font-scale/breakpoint
numbers, app bar description, replace-confirmation dialog, app-name note). Those are all correctly
in the doc now.

This pass found a few things still wrong or missing:

1. **"Interactive Format Hint Chips" claim is false (§5.2, line 148).** The doc says the
   `@handle` / `watch` / `youtu.be` / etc. chips on the Add/Edit screen are "tappable" and
   "pre-fill input fields." In the real code (`lib/src/screens/add_shortcut_screen.dart`) these
   are plain `Chip` widgets with no tap handler — they are static visual examples only, not
   interactive. Anyone relying on the doc would expect a tap-to-fill feature that doesn't exist.

2. **"48x48dp minimum touch targets" claim is overstated (§1, line 18).** There is no app-wide
   48dp minimum. The category filter chips on the Home screen deliberately use
   `VisualDensity.compact` and `MaterialTapTargetSize.shrinkWrap`, which makes their tap target
   *smaller* than 48dp. Only default Material buttons/cards happen to be around that size; it is
   not an enforced rule. The doc should not claim a guarantee that isn't in the code.

3. **"Built with Flutter semantics for screen reader support (TalkBack)" is overstated (§1, line
   18).** There are no explicit `Semantics(...)` widgets anywhere in `lib/`. TalkBack gets
   whatever Flutter's stock Material widgets provide automatically (buttons, tooltips); there is
   no custom labeling for things like the selection counter or the search match-count badge. The
   doc currently implies deliberate semantic engineering that hasn't been built.

4. **Missing detail — bare (non-`@`) handles accept a narrower character set than `@`-prefixed
   handles.** In `youtube_url_formatter.dart`, the bare-handle pattern disallows dots (only
   letters, digits, dash, underscore), while the `@handle` pattern allows dots too. A bare handle
   like `some.channel` is rejected as a handle where `@some.channel` would work. §4 and §5.8
   describe the length/character rules as one uniform rule; this asymmetry is worth one line so
   users typing bare handles with dots aren't confused by a validation error.

5. **Missing dependency mention.** The doc never names the actual Android intent package used to
   launch YouTube (`android_intent_plus`). §2's "Native Platform Channels" bullets list the
   custom method channels but not this plugin, which is the mechanism behind §7's "explicit
   Android Intent." One line naming it removes ambiguity about how the intent is actually built.

Everything else re-checked (sort modes, filter categories, dependencies list overall, backup JSON
schema, manifest protections, build flavors/signing gate) is already accurate — no changes needed
there.

## Plan for the fix

Edit `docs/features.md` only, no code changes:

- **§1 (Inclusive App Description)**: soften the accessibility bullet — replace the unqualified
  "48x48dp minimum touch targets" and "Built with Flutter semantics for screen reader support"
  claims with accurate wording: standard Material default tap targets (noting filter chips are
  intentionally more compact), and TalkBack support coming from Flutter/Material's built-in
  accessibility tree rather than custom `Semantics` annotations.
- **§4 (Supported YouTube Link Formats)**: add one line noting that bare (non-`@`) handles do not
  accept dots, while `@`-prefixed handles do.
- **§5.2 (Add / Edit Shortcut Screen)**: change "Interactive Format Hint Chips... Tappable
  template chips... pre-fill input fields" to describe them as static, non-interactive visual
  examples of each supported format.
- **§2 (Native Platform Channels)**: add a short bullet naming `android_intent_plus` as the plugin
  used to build the explicit `ACTION_VIEW` intent described in §7.

I will not touch any app code — this is a documentation-only correction.

## After approval

Once you approve, I will make the edits above and then write a change log entry in
`change_log/` describing what was changed, per the project workflow rules.
