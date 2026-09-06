# Product Concept & Features — SreerajP YouTube Shortcuts

Read this before adding a feature, to check whether the app already does it and whether the
idea is already on (or deliberately off) the roadmap.

**Read first:** [../CLAUDE.md](../CLAUDE.md) · [architecture.md](architecture.md) ·
[project_structure.md](project_structure.md)

This document provides a comprehensive, authoritative breakdown of all features, system integrations, data models, link processing capabilities, UI workflows, and accessibility assurances available in **SreerajP YouTube Shortcuts**.

It serves as the reference document for developers, AI assistants, and auditors to verify existing application capabilities before introducing new features or maintaining the codebase.

---

## 1. App Overview & Inclusive Value Proposition

**YT Shortcuts** is a fully offline, privacy-first Android application (minimum Android 7.0 / API Level 24) built with Flutter. It enables users to save custom, named "shortcuts" pointing to YouTube channels, live streams, videos, Shorts, or playlists, and launch them directly in the official YouTube app with a single tap.

### Inclusive App Description & Core Value Pillars

- **Digital Wellbeing & Feed-Free Access**: Bypasses YouTube's recommendation algorithms, home feed distractions, comment sections, and UI clutter by jumping directly into specific, user-selected content.
- **Privacy-First & Complete Data Sovereignty**: Operates 100% offline with zero network calls, zero tracking/telemetry SDKs, no user accounts or authentication, and versioned local JSON storage under full user control.
- **Cognitive Accessibility & Simplified UX**: Offers direct, distraction-free visual launcher cards with color-coded avatar initials, making navigation intuitive for users with cognitive fatigue, ADHD, or low digital literacy. The initials are not simply "first 2 letters": a single-word name uses the first 2 characters of that word; a multi-word name uses the first letter of the first two words only (any further words are ignored); a blank/whitespace-only name shows `"?"`.
- **Inclusive Accessibility Engineering**: TalkBack support comes from Flutter/Material's built-in accessibility tree on standard widgets (buttons, tooltips) rather than custom `Semantics` annotations. Most primary controls (buttons, cards) use default Material tap target sizing; the category filter chips are a deliberate exception and are set smaller (`VisualDensity.compact` / shrink-wrapped tap target), so there is no app-wide enforced minimum. The app also offers high contrast ratios (WCAG AA compliance), responsive multi-column layouts, and a protective upper bound on system font scaling (clamped to a maximum 1.3x scale factor on shortcut card content) to prevent UI clipping or breakage.
- **Senior & Tech-Averse Friendly**: Large visual targets, readable text, clear initial badges, and zero complex setup menus allow seniors to easily launch daily news feeds or favorite creator streams.
- **Power User Productivity & Organization**: Features real-time substring search (matching names, URLs, and custom tags), multi-chip filtering across 4 target categories and custom user tags, 5 sorting modes (including manual drag-and-drop), optional favorites pinning (`favoritesFirst`), multi-select bulk operations (bulk export/delete), single-item quick actions (details/edit/copy/QR code dialog without leaving selection mode — shown when exactly one item is selected), and smart clipboard auto-detection.
- **Personalized Look & Feel**: A Settings-screen visual Theme Picker supporting 7 curated theme preferences (System default, Light, Classic Dark, AMOLED Pure Black, Warm Sepia, Forest Dark, Cyberpunk Neon) and per-shortcut custom card accent colors & custom icons allows each user to personalize the app UI.
- **Usage Insights, Not Surveillance**: Every shortcut quietly tracks its own launch count and last-launched time, entirely on-device. This powers two extra sort modes ("Recently launched", "Most launched") and an "Activity" card on the Shortcut Detail screen — a personal-use insight, not analytics sent anywhere.
- **Full Two-Way Backup & Restore**: Not just "export for safekeeping" — a complete round-trip: export all or selected shortcuts to a JSON file, then bring them back on the same or another device via Merge (duplicate-safe) or Replace mode, all through the permissionless system file picker.
- **System-Level OS Integration**: Acts as a native Android share receiver (`android.intent.action.SEND`), permitting direct handoff from YouTube, web browsers, or chat applications without manual copy-pasting.
- **Permissionless Data Portability**: Leverages the Android Storage Access Framework (SAF) system file picker for JSON backup export and import (Merge and Replace modes) without requesting invasive runtime storage permissions.
- **Guarded, Reversible-by-Confirmation Data Operations**: Every destructive action — Clear All shortcuts, single or bulk Delete, and Replace-mode import — is gated behind an explicit confirmation dialog, and the app blocks a second export/import from starting while one is already running. This deliberate anti-data-loss design is a distinct value pillar from the permission model itself: it protects users from accidental, irreversible data loss rather than just protecting their privacy.
- **No Ads, No In-App Purchases, No Monetization**: The app contains no advertising SDKs, no in-app purchases, and no monetization of any kind. It is free to use with no hidden business model, consistent with its offline, privacy-first design.

The app never connects to the internet itself — it only builds a cleaned, canonical URL and delegates playback to the official installed YouTube app via an explicit Android Intent.

---

## 2. Platform Architecture, Build Flavors & Android Security Hardening

- **Visual Identity & Native Handoff**: Custom launcher icon, launcher display label, and a native Android splash theme for seamless startup transitions.
- **Build Flavors**:
  - `dev`: Application ID `in.sreerajp.sreerajp_youtube_shortcut.dev`, display name **SreerajP YouTube Shortcuts Dev** (uses automatic debug keystore). The version name shown on the About screen also gets a `-dev` suffix (e.g. `1.4.15-dev`) so a dev build is never mistaken for a prod build.
  - `prod`: Application ID `in.sreerajp.sreerajp_youtube_shortcut`, display name **SreerajP YouTube Shortcuts** (requires release signing key).
- **System Requirements**: Android API Level 24 (Android 7.0) minimum.
- **Manifest Protections**:
  - `android:allowBackup="false"` — Disables automated Android OS cloud backup to enforce strict local data privacy.
  - `android:usesCleartextTraffic="false"` — Blocks plain unencrypted HTTP traffic at the OS manifest level.
  - No `INTERNET` permission — the shipped **release/prod** build's manifest strictly omits all network access permissions. Debug and profile builds add `INTERNET` only because Flutter's own development tooling (hot reload, DevTools) needs it; these build types are never distributed to users.
- **Android System Intent Receivers**:
  - `android.intent.action.MAIN` / `android.intent.category.LAUNCHER`: Standard app launcher entry point.
  - `android.intent.action.SEND` (`text/plain`): Native share receiver capturing shared text and URLs from external apps.
  - `android.intent.action.PROCESS_TEXT` (`text/plain`, declared in a manifest `<queries>` block): a package-visibility declaration, not a share target. On Android 11+, apps can only see other installed apps if they declare what they need to see. This `<queries>` entry lets **this app** query which other installed apps can handle `PROCESS_TEXT` intents. It does **not** make this app itself selectable as a "process text" option in other apps' text-selection menus — that would require this app to declare its own `PROCESS_TEXT` intent-filter, which it does not have. Disclosed to users on the in-app Permissions screen (§5.7) as "Package visibility query".
- **Native Platform Channels**:
  - `build_metadata` (`MethodChannel`): Reads Gradle-injected build metadata (`PUBSPEC_BUILD_NUMBER`, `APP_BUILD_DATE`) with fallback to package info.
  - `share_intent` / `share_intent_events` (`MethodChannel` & `EventChannel`): Manages cold-start and warm-start share intent consumption.
  - `backup_io` (`MethodChannel`): Invokes the Android Storage Access Framework (SAF) system file picker for permissionless JSON import/export.
- **YouTube Launch Plugin**: The explicit Android Intent described in §7 is built and dispatched via the `android_intent_plus` Flutter plugin.
- **`MainActivity` Launch Behavior**: Declared with `android:launchMode="singleTop"`, an empty `android:taskAffinity`, and `android:exported="true"` (required for the launcher/share intent-filters to work under Android 12+ visibility rules). `singleTop` means repeated share intents are delivered to the same running activity instance via `onNewIntent` rather than spawning a new instance each time. A broad `android:configChanges` list plus `android:windowSoftInputMode="adjustResize"` prevent the activity from being recreated across rotation, keyboard, or locale changes, keeping in-progress share-intent handling and form state stable.
- **Release Binary Hardening**: Gradle itself only enforces R8 code shrinking/optimization (`isMinifyEnabled = true` on the release build type). Obfuscation (`--obfuscate`) and symbol table splitting (`--split-debug-info`) are **not** checked or enforced by Gradle — they are manual flags a developer must remember to pass to `flutter build` (see the Common Commands section below and `docs/release_process.md §6`). Only the release-signing keystore check (next bullet) is a build-breaking, mechanically enforced gate; obfuscation and split-debug-info are procedural requirements, not code-enforced ones.
- **Release-Signing Build Gate**: The Gradle build refuses to run `assembleProdRelease` or `bundleProdRelease` if `android/key.properties` is missing. It fails the build immediately with a clear on-screen message instead of producing an unsigned or debug-signed release artifact. Debug and profile builds are never blocked — they always use the automatic Android debug keystore.

---

## 3. Shortcut Domain & Data Model

Each saved shortcut entry (`ShortcutEntry`) is an immutable domain object containing:

- **`id`** — Unique string identifier (`<microsecond-timestamp>-<random-32bit-int>`).
- **`name`** — Custom label assigned by the user (must be unique, case-insensitive comparison, trimmed of leading/trailing whitespace).
- **`sourceUrl`** — The exact input URL or handle provided by the user, clipboard, or share receiver.
- **`canonicalUrl`** — The normalized, cleaned YouTube URL passed to the YouTube app.
- **`targetType`** — Categorized target type (`Video`, `Shorts`, `Playlist`, `Channel`).
- **`createdAtIso`** — UTC ISO 8601 creation timestamp.
- **`updatedAtIso`** — UTC ISO 8601 last modified timestamp.
- **`lastLaunchedAtIso`** — UTC ISO 8601 last launched timestamp (`null` if never opened).
- **`launchCount`** — Non-negative integer counter tracking total launches.
- **`isFavorite`** — Boolean flag indicating whether the shortcut is starred/pinned as a favorite (`false` by default).
- **`isPrivate`** — Boolean flag indicating whether the shortcut is protected by the private vault lock (`false` by default).
- **`tags`** — List of custom string tags assigned to the shortcut for organization (`const []` by default).
- **`customColorHex`** — Optional string hex color code (e.g. `"#EA580C"`) for custom card avatar background (`null` if unset).
- **`customIconName`** — Optional string icon identifier (e.g. `"music"`, `"game"`, `"star"`, `"code"`, etc.) for custom card avatar icon (`null` if using default initials).

The shipped app persists shortcuts through a `SharedPreferences`-backed `ShortcutRepository`
implementation. A separate in-memory `MemoryShortcutRepository` implementation also exists in the
codebase; it is used only for automated tests and is not part of the shipped app's data path.

### Error Types

App domain errors are sealed exceptions under `lib/core/errors/app_exception.dart`
(`ShortcutValidationException`, `ShortcutStorageException`, `ShortcutBackupException`, and
`YoutubeLaunchException`). All four extend the shared sealed `AppException` hierarchy and carry
stable `AppErrorCode` values mapped to localized UI strings in `lib/l10n/error_messages.dart`.

---

## 4. Supported YouTube Link Formats & Smart Handoff Processing

When adding or updating a shortcut, the app accepts and normalizes various link types:

- **Channel Handles**:
  - `@handle` (e.g. `@JanamTVMedia`) or bare handle (e.g. `JanamTVMedia`) -> expanded to `https://www.youtube.com/@handle/live` (or `https://www.youtube.com/handle/live`).
  - **Important classification note**: even though the expanded URL ends in `/live`, a shortcut
    created from a handle is always saved with `targetType: Channel`, not `Video`. The `/live`
    suffix only affects which page opens in the YouTube app — it does not change the category
    badge shown on the shortcut card or detail screen.
- **Short Links**:
  - `youtu.be/<video-id>` -> canonicalized to `https://www.youtube.com/watch?v=<video-id>`.
- **Watch Links**:
  - `youtube.com/watch?v=<video-id>` -> canonicalized to `https://www.youtube.com/watch?v=<video-id>` (strips invasive tracking query params like `?si=...`, `&feature=...`, `&gclid=...`).
- **Live Stream Links**:
  - `youtube.com/live/<video-id>` -> canonicalized to `https://www.youtube.com/watch?v=<video-id>`.
- **YouTube Shorts Links**:
  - `youtube.com/shorts/<video-id>` -> canonicalized to `https://www.youtube.com/shorts/<video-id>`.
- **Playlist Links**:
  - `youtube.com/playlist?list=<playlist-id>` -> canonicalized to `https://www.youtube.com/playlist?list=<playlist-id>` (strips tracking parameters).
- **Channel Links**:
  - `youtube.com/@handle`, `youtube.com/channel/<id>`, `youtube.com/c/<name>`, `youtube.com/user/<name>` -> canonicalized to `https://www.youtube.com/<path>`.

### Supported Host Domains
`youtube.com`, `www.youtube.com`, `m.youtube.com`, `music.youtube.com`, `youtube-nocookie.com`, `www.youtube-nocookie.com`, `youtu.be`.

### Bare Handle vs. `@`-Prefixed Handle: Character Set Difference
A bare handle (no leading `@`) only accepts letters, digits, dashes, and underscores — dots are
**not** allowed. An `@`-prefixed handle also allows dots. This means a bare handle containing a
dot, e.g. `some.channel`, is rejected, while the same handle typed as `@some.channel` is accepted.
A dotted bare handle does not even reach the handle-specific error message — it fails the
"looks like a handle" check silently, falls through to be treated as a raw URL, and ends up
rejected with the generic link error ("Only YouTube links are supported in this app." or "Enter a
valid channel handle or YouTube URL.") rather than a message calling out the dot specifically.

### Input Processing & Extraction Logic
- **Regex Extraction from Shared Text**: When receiving text via external share intent that contains surrounding commentary (e.g. "Check out this channel https://youtu.be/xyz"), the extractor parses out the first `http://` or `https://` URL string, then trims trailing punctuation characters (`.`, `,`, `;`, `:`, `!`, `?`, `)`, `]`, `}`, `>`) off the end of the match, so a sentence like "Check this out: https://youtu.be/xyz." keeps the trailing period out of the extracted link. **Limitation**: the extractor only recognizes `http(s)://` links. If the shared text has no such link in it — for example a bare handle or a scheme-less `youtube.com/...` string mixed with commentary — the entire raw trimmed text is passed through unchanged into the Add Shortcut screen, not cleaned or extracted.
- **Scheme Auto-Prefixing**: This nuanced "well-formed scheme token" check only governs the **live URL preview text** shown while typing (§5.2) — it decides whether to show the "Full URL: …" preview line. The actual save-time normalization path is simpler: it just checks whether the input contains `://` anywhere, and if not, prefixes `https://` before validating the host. Host validation happens as a separate step after prefixing, not before — an unsupported host is rejected at that later validation step.
- **Validation & Duplicate Protection**: Rejects empty inputs, unsupported domains, or malformed URLs. These errors are **not** shown as real-time inline field errors — see §5.2, "Validation Feedback". Duplicate shortcut names (case-insensitive & trimmed) are strictly blocked.

---

## 5. Screen Breakdown & Interactive Capabilities

### 5.1 Home Screen

- **Adaptive Layout**: Toggle between **Grid** (responsive 2 columns on phones, 3 columns once the available width reaches 680 logical pixels — typically tablets or wide screens) and **List** (1 column) layouts. User preference is persisted in `SharedPreferences`.
- **Deterministic Initial Avatars**: Cards display 2-letter uppercase initial badges styled over a 12-color harmonious palette determined deterministically via string hashing.
- **One-Tap Launcher Cards**: Tap any shortcut card to launch an explicit Android Intent to YouTube. Card renders an inline loading spinner while intent launch executes.
- **Floating Action Button (FAB)**: Primary CTA button to navigate to the Add Shortcut screen. Hidden while Reorder mode or Multi-Select mode is active.
- **App Bar Controls** — the app bar title itself is always the static text "SreerajP YouTube Shortcuts"; the shortcut-count badge is not an app-bar element (it lives in the screen body — see "Always-Inline Search" below):
  - **Scan QR code button** — always visible in the app bar (tooltipped "Scan QR code"), opens the in-app Offline QR Scanner (`QrScannerScreen`).
  - **Grid / List layout switch button** — shown when shortcuts exist, toggles the layout directly (not inside a menu).
  - **Sort menu** — shown when shortcuts exist, its own popup menu icon (tooltipped "Sort shortcuts"), opens the sort mode picker (includes "Favorites first" checkbox toggle and 5 sort modes).
  - **Options menu** — shown when shortcuts exist, a separate popup menu (tooltipped "Options") containing two actions: **Reorder shortcuts** (activates manual drag-and-drop mode; enabled only when Manual sort is the active sort mode — otherwise the item is shown disabled/greyed out with the label "Reorder shortcuts (manual sort only)") and **Clear all shortcuts** (wipes all saved entries after explicit confirmation modal).
  - **Settings button** — always visible in the app bar (not nested inside any menu), navigates to the Settings screen.
  - **Import/Export, About, Permissions, and Channel Handles are not on the Home app bar at all.** They are reached only via tiles inside the Settings screen (see §5.4).
- **Always-Inline Search**: there is no search "toggle" button. Whenever shortcuts exist (and
  the user is not reordering or in multi-select mode), a search box is shown inline in the
  screen body for real-time substring search. Matches evaluate shortcut names, canonical URLs,
  and custom tags. The match counter badge (e.g. "3/12") appears on the "Shortcut Sections"
  heading above the list, not attached to a toggle button.
- **Sorting Preferences & Favorites Pinning**:
  - 5 sort order modes: Manual order (drag-and-drop reordering enabled), Alphabetical (A–Z), Newest first, Recently launched, Most launched.
  - Favorites-first toggle (`favoritesFirst` preference): when enabled, starred/favorite shortcuts (`isFavorite: true`) are pinned to the top of the list regardless of active sort mode.
- **Multi-Chip Category & Tag Filter**: Filter by 4 category chips (Video, Shorts, Playlist, Channel) and dynamic custom tag chips which operate simultaneously with active search text. There is no separate "All" chip — seeing all shortcuts is simply the default state when no chip is selected.
- **Manual Drag-and-Drop Reordering**: In Manual order mode, the whole shortcut card becomes
  long-press-draggable (there is no separate grip/handle icon on the card). While dragging, the
  card being hovered over shows a highlighted border to indicate the drop target. Dropping a card
  back in its original position, or an invalid drag, is a safe no-op — nothing is re-saved.
- **Swipe-to-Delete**: Horizontal swipe gesture on cards guarded by an explicit modal confirmation dialog.
- **Multi-Select / Selection Mode** (activated by long-pressing any card):
  - Selection bar counter: a plain numeric count (e.g. "2") next to a checkmark icon — there is
    no "selected" word rendered alongside it.
  - Pressing the system back button while in selection mode clears the current selection
    instead of leaving the Home screen.
  - **Select all**: a popup menu item, shown only when at least one visible item is not yet
    selected. There is no separate "Select None" toggle — clearing the current selection is done
    via the leading "Clear selection" (X) icon button in the selection app bar, which clears
    everything rather than being a labeled "Select None" action.
  - **Bulk Export**: Exports selected shortcuts to a versioned JSON file via SAF.
  - **Bulk Delete**: Deletes selected shortcuts after modal confirmation. If none
    of the selected ids match an existing shortcut (e.g. the list changed
    underneath the selection), the delete is a safe no-op — nothing is saved
    and nothing changes on screen.
  - **Single-Item Quick Actions**: When exactly 1 item is selected, four extra icon buttons —
    tooltipped "Show QR code", "Shortcut details", "Edit shortcut", and "Copy URL" — appear directly in the
    selection app bar. These are plain app bar icon buttons, not a popup/context menu.
- **Empty States**:
  - General empty state: Illustrative graphic + "Create first shortcut" CTA button.
  - Search/Filter empty state: "No matching shortcuts" with quick clear action.
- **Share Intent Receiver Handoff**: Listens for incoming `android.intent.action.SEND` text intents during cold start and warm start, pre-filling the Add Shortcut screen automatically.

### 5.2 Add / Edit Shortcut Screen

- **Form Inputs**: Name field, Channel handle / YouTube URL field, optional comma-separated custom Tags field, Favorites toggle star, Private Shortcut toggle lock, and visual Card Customization options (avatar color palette and custom icon picker).
- **Live Formatted Preview**: Real-time "Full URL: …" preview text showing the canonical URL built as the user types. This preview only appears while the input has no explicit `https://` scheme (bare handles, scheme-less paths); it is suppressed once the user has typed or pasted a full `https://` URL.
- **Smart Clipboard Suggestion Banner**: Automatically checks system clipboard for a YouTube link upon screen open. Displays a one-tap "Paste" banner; auto-dismisses on edit or dismissal. The banner only appears if the clipboard text contains one of `youtube.com/`, `youtu.be/`, `youtube-nocookie.com/`, or `music.youtube.com/` — a bare handle (e.g. `@SomeChannel`) copied to the clipboard will **not** trigger the suggestion, even though typing it manually into the field is fully supported. **Note**: this host-substring list omits `m.youtube.com/`, even though `m.youtube.com` is a supported host for saving a shortcut (§4) — a clipboard link on the mobile-site host will not trigger the Paste banner.
- **Static Format Hint Chips**: Non-interactive example chips (`@handle`, `watch`, `youtu.be`, `live`, `shorts`, `playlist`, `channel`) that visually illustrate the accepted syntax patterns. They are not tappable and do not pre-fill any input field.
- **Multi-Source Support**: Pre-filled when editing existing shortcuts, receiving shared text, or pasting from clipboard.
- **Validation Feedback**: There is no real-time inline field validation on this screen — the text fields do not show per-field error text as you type. Validation (empty fields, duplicate shortcut names, unsupported link formats) runs only when the user taps Save; any failure is reported afterward via a Snackbar message, not inline text under the field.
- **Footer Disclosure**: A short line of text at the bottom of the form reads "The app stores the shortcut locally and does not request internet access."

### 5.3 Shortcut Detail Screen

- **Header Card**: Visual avatar badge, shortcut name, and target category pill badge (`Video`, `Shorts`, `Playlist`, `Channel`).
- **Primary CTA**: Prominent "Open in YouTube" button with loading indicator during intent execution.
- **Quick Action Row**: A secondary "Copy URL" and "Edit" outlined button row, separate from the app bar's own Edit/Delete icon buttons and the per-card copy icons below.
- **Link Management Cards**:
  - Full Canonical URL card with 1-tap copy button and selectable text.
  - Original Input URL card (if different from canonical) with copy button and selectable text.
  - Snackbar notification feedback upon copying ("URL copied to clipboard").
- **Activity Insights Card**:
  - Last launched date/time (or "Never launched").
  - Total launch count ("X launches"). A shortcut with exactly 0 launches shows the same literal
    "Never launched" text as one that has never been opened, rather than showing "0 launches".
  - Created date/time.
  - Last updated date/time — shows the literal text "Same as created" instead of a second
    timestamp if the shortcut has never been edited since creation.
- **Management Actions**: Edit button and Delete button (Delete guarded by confirmation dialog; pops screen upon completion).

### 5.4 Settings Screen

- **Intro Card**: A short explanatory card at the top of the screen ("Manage app appearance, information, and Android manifest permissions.").
- **Theme Selection**: A visual Theme Picker with preview swatches and live descriptions allowing users to select among 7 curated theme preferences: System default, Light theme, Classic Dark, AMOLED Pure Black (`#000000`), Warm Sepia (`#FBF0D9`), Forest Dark (`#0B1A15`), and Cyberpunk Neon (`#0A0915`). Persisted across sessions in `SharedPreferences`.
- **Navigation Links**: Direct links to About, Permissions, Channel Handles guide, and Backup & Restore screens.
- **Privacy & Security Card**: Allows setting or changing a 4–6 digit Security PIN, toggling **App Lock** (requiring PIN or biometrics upon opening the app), and toggling **Lock Private Shortcuts** (gating shortcuts marked as private).

### 5.5 Backup & Restore Screen

- **Permissionless SAF Integration**: Uses Android Storage Access Framework (`ACTION_CREATE_DOCUMENT` / `ACTION_OPEN_DOCUMENT`) without asking for invasive storage permissions. The import file picker accepts a broad MIME allow-list (`application/json`, `text/json`, `text/plain`, `application/octet-stream`) rather than being strictly limited to `.json` files — a user can pick a `.txt` file and the app will still try to parse it as backup JSON.
- **Concurrency Guard**: The native side blocks a second export or import from starting while one is already in progress, returning a "busy" error instead of running two file-picker operations at once.
- **Export Shortcuts**:
  - Saves all or selected shortcuts into a versioned JSON backup file. The file's top-level fields are `type` (`payloadType: "sreerajp_youtube_shortcuts_backup"`), `schemaVersion: 1`, `appId` (the app's package id), `exportedAtIso`, `shortcutCount`, and the `shortcuts` array. **Note**: the `appId` field always contains the **prod** flavor's package id (`in.sreerajp.sreerajp_youtube_shortcut`), even when the export is produced from a `dev`-flavor build.
  - Automated timestamped filename pattern: `yt_shortcuts_backup_YYYY-MM-DD_HHmm.json` (or `yt_shortcuts_backup_YYYY-MM-DD_HHmm.aes.json` when password encryption is enabled).
  - Each exported shortcut includes name, source URL, canonical URL, target type, and
    created/updated timestamps. If a shortcut has been launched at least once, its **launch
    count and last-launched timestamp are also included** in the export — these on-device usage
    stats are not stripped out before writing the file. Fields that don't apply (e.g. launch
    count/timestamp for a shortcut never opened) are **omitted from the JSON entirely**, not
    written as `null` or `0`.
- **Import Shortcuts**:
  - **Merge Mode**: Adds new shortcuts to the **top** of the existing list, skipping
    case-insensitive duplicate names. Shows summary stats (e.g. "Imported 3 new, skipped 1 duplicate").
    Duplicate detection also applies **within the imported file itself** — if the file being
    imported contains two shortcuts with the same name, only the first one is kept.
  - **Replace Mode**: Shows a "Replace all shortcuts?" confirmation dialog before clearing existing shortcuts, then imports file contents.
- **Security & Validation Guard**: Rejects malformed JSON, invalid payload types, or backups from future schema versions. If an imported shortcut's launch count is a negative number (e.g. from a hand-edited or corrupted file), the app clamps it to `0` on import rather than keeping the bad value.

### 5.6 About Screen

- Displays author details, app display version and build number combined in one row (e.g. `1.4.15+20`), build date, and AI model/assistance label. App title, description, version, build, and key-value details are dynamically loaded at startup from `assets/config/app_config.json` via `ConfigService` (`AppConfig`), with fallbacks defined in `AppConfig.fallback`. Static UI strings (such as the screen title, notes card title, and notes card body) are defined in `lib/src/about_constants.dart`. A short Notes card below these summarizes the app's offline, local-storage, explicit-intent design. There is no separate "project credits" section.
- Fetches build metadata natively via `build_metadata` MethodChannel with fallback to `package_info_plus` and current date.
- **Note on app name**: the app uses the single name "SreerajP YouTube Shortcuts" everywhere —
  the Android launcher label (or "SreerajP YouTube Shortcuts Dev" for the dev flavor), the
  in-app `MaterialApp` title, the Home screen app bar title, and this About screen's header.
  Because the name is long, the Android launcher and narrow app bars will visually truncate
  it with an ellipsis. That is a display limit of the host surface, not a bug.

### 5.7 Permissions Screen

- Informational screen detailing Android permissions, split into two sections:
  - **Explicit Permissions**: `android.permission.CAMERA` — requested only when opening the optional in-app QR scanner to process camera frames on-device for YouTube QR code scanning.
  - **Implicit Permissions / Declarations**: 5 entries — Share receiver target, clipboard reading, SAF system file picker, the `PROCESS_TEXT` package-visibility query, and **Launcher visibility**.
- An intro card explains: "Camera permission is used exclusively for the optional in-app QR scanner. The app never requests internet access or background tracking permissions."

### 5.8 Channel Handles (Shortcut Behavior) Screen

- Informational guide explaining YouTube handle syntax rules (3 to 30 characters, alphanumeric, dots, dashes, underscores) and how the `/live` endpoint behaves for live streams, scheduled streams, or offline channels.
- A concrete 5-row table spells out what happens when the `/live` URL is opened for each channel
  state: currently streaming, upcoming/scheduled, past live streams only (no current stream),
  never gone live, and an invalid or misspelled handle — each row states the specific outcome the
  user will see in the YouTube app.
- A "Good to know" section adds two notes: the app performs **no connectivity check** before
  opening a link (it always hands off to YouTube and lets YouTube's own app show any error), and
  explains that to open a channel's **regular page** instead of its `/live` page, the user should
  save the full `https://www.youtube.com/@handle` URL directly rather than a bare handle or
  `@handle`.
- **Note**: this in-app help text is a simplification and does not state the bare-handle vs.
  `@`-prefixed distinction. The authoritative rule, documented in §4, is that only `@`-prefixed
  handles accept dots — a bare handle (no leading `@`) containing a dot is rejected.

### 5.9 Fatal Error Screen & Global Error Boundaries

- Dedicated fallback error screen rendered if local storage or metadata initialization fails at boot.
- Uncaught Flutter framework (`FlutterError.onError`) and async platform error (`PlatformDispatcher.instance.onError`) boundaries prevent app crash loops.

### 5.10 In-App Offline QR Scanner & Air-Gapped QR Generator

- **Offline QR Code Generator (`ShortcutQrDialog`)**: Displays an on-screen high-contrast QR code for any saved YouTube shortcut (accessible from the `ShortcutDetailScreen` and `HomeScreen` single-item selection bar). The QR payload encodes a structured JSON string (`{"type": "yt_shortcut", "name": "...", "url": "...", "tags": [...]}`) or standard YouTube canonical URL so another device can scan and receive it without internet or messaging apps.
- **In-App Offline QR Scanner (`QrScannerScreen`)**: An in-app camera vision scanner powered by `mobile_scanner` with a viewport frame overlay, torch toggle button, front/back camera switcher, and gallery image picker (`image_picker` + `analyzeImage`).
- **Receiver Handoff Sheet ("Shortcut Received!")**: Scanning a YouTube QR code pauses camera vision and opens a handoff bottom sheet pre-filled with shortcut title, category badge, canonical link, and tags, offering direct actions:
  - **Save to YT Shortcuts**: Opens the `AddShortcutScreen` with Name, URL, and Tags pre-filled.
  - **Open in YouTube**: Launches the shortcut directly in the YouTube app via explicit Android Intent.
  - **Scan Another Code**: Resumes live camera scanning.

### 5.11 Privacy Lock & Password-Encrypted Backup Vault

- **Biometric & Local PIN App/Category Lock (`PrivacyLockStore` / `PrivacyLockService`)**:
  - **Security Options**: Optional local security lock to gate access to the overall app ("App Lock") or private shortcut entries ("Lock Private Shortcuts").
  - **Authentication Modes**: Biometric unlock via `local_auth` (fingerprint, face unlock) backed by native `FlutterFragmentActivity`, with 4–6 digit local PIN fallback.
  - **PIN Security**: PIN is hashed with PBKDF2-HMAC-SHA256 (10,000 iterations, 16-byte random salt, 32-byte key) and persisted locally.
  - **Auto-Lock on Background**: Integrated lifecycle observer (`_PrivacyLockGate`) automatically locks the app when paused or sent to the background.
  - **Private Shortcut Marking**: Shortcuts can be marked as private (`isPrivate: true`) during creation or editing. When the private vault is locked, private shortcuts are hidden from the home list.
- **Password-Encrypted JSON Backup Export**:
  - **AES-256-GCM Encryption**: Passphrase-based encryption option on export using AES-256-GCM mode with PBKDF2-HMAC-SHA256 key derivation.
  - **Envelope Format**: Self-contained string format `v1:<salt_b64>:<iv_b64>:<ciphertext_b64>`.
  - **Encrypted Import Detection**: Automatically detects encrypted backups (`v1:` prefix) upon selection and prompts for the decryption passphrase. Invalid passphrases or corrupted files surface clear error feedback without crashing.

---

## 6. App-Wide State & Persistence Model

The app uses `provider` with three root state objects: `ShortcutStore` (`ChangeNotifier`), `PrivacyLockStore` (`ChangeNotifier`), and `AppConfig` (`Provider<AppConfig>`). Persistent settings saved in `SharedPreferences` include:

- **Theme Preference**: `system`, `light`, `dark`, `amoled`, `warmSepia`, `forestDark`, `cyberpunkNeon` (`app_theme_preference_v1`).
- **Layout Preference**: `grid`, `list` (`app_layout_preference_v1`).
- **Sort Preference**: `manual`, `alphabetical`, `newest`, `recent`, `mostUsed` (`app_sort_preference_v1`).
- **Favorites-First Preference**: `true`, `false` (`app_favorites_first_v1`).
- **Privacy Lock Settings**: `app_lock_enabled_v1`, `private_lock_enabled_v1`, `privacy_pin_hash_v1`, `privacy_pin_salt_v1`.
- **Shortcuts List**: Stored as a versioned JSON string (`shortcut_entries_v1`).

---

## 7. How Opening a Shortcut Works

When a user taps a shortcut:

1. An explicit Android Intent (`ACTION_VIEW`) is constructed targeting `com.google.android.youtube` with flags `FLAG_ACTIVITY_NEW_TASK | FLAG_ACTIVITY_CLEAR_TASK`.
2. The canonical URL is passed directly to the YouTube app.
3. If successful, `launchCount` is incremented and `lastLaunchedAtIso` is updated locally.
4. If the YouTube app is uninstalled or disabled, an error Snackbar is presented with the message "The YouTube app could not be opened. Check that it is installed and enabled on this device." Failure to record launch metrics in local storage is swallowed silently to prevent disrupting the handoff experience.

---

## 8. What This App Does NOT Do (Non-Scope & Hard Boundaries)

- Does not request `INTERNET` permission or make any network calls in the shipped release build. (Debug/profile builds add `INTERNET` solely for Flutter's own dev tooling — see §2 — and are never distributed to users.)
- Does not fallback to web browsers or embedded web views.
- Does not require accounts, sign-in, or authentication.
- Does not interact with YouTube APIs or check live stream status online.
- Does not play, stream, or download video/audio content internally.
- Does not sync online or enable cloud backups (`android:allowBackup="false"`).
- Does not pin home-screen widgets or launcher shortcuts.
- Does not collect analytics, crash reporting, telemetry, or user tracking data.
- Does not request runtime Android permissions.
- Exclusively targets Android (API Level 24 / Android 7.0 minimum).

---

## 9. Planned / Not Built

Everything above describes what the app does today. This section records ideas that are
**not implemented**. Items marked `Implemented` are already covered in the sections above and
are kept here only to show where the idea came from.

This document outlines potential features that can be implemented in **YT Shortcuts** (`sreerajp_youtube_shortcut`). These feature ideas are derived from an in-depth analysis of the current project alongside the 18 local Flutter Android applications in your development suite (`myapps.md`).

---

### Recommended Feature Roadmap by Category

#### Category A: Advanced Organization, Tagging & Favorites
*Inspired by `SreerajPContactSphere` and `sreerajp_todo`* — **[Status: Implemented ✅]**

1. **Custom User Tags & Category Management**:
   - *Status*: **Implemented ✅**
   - *Concept*: In addition to automatic target types (`Video`, `Shorts`, `Playlist`, `Channel`), allow users to create custom tags (e.g., `#Tech`, `#Music`, `#News`, `#Education`, `#Personal`).
   - *UI Handoff*: Multi-select tag filter chips on the Home Screen alongside existing target chips.

2. **Pinned Favorites**:
   - *Status*: **Implemented ✅**
   - *Concept*: A quick one-tap star/pin action on any shortcut card to keep high-priority shortcuts pinned to the top of the grid or list view.
   - *Sorting*: Add a "Favorites first" toggle in the sort options menu.

---

#### Category B: Android OS Integration & Launcher Productivity
*Inspired by `chronotune-smart-clock` and `daily_rule_cards`*

3. **Android Home Screen Widgets (`home_widget`)**:
   - *Concept*: Provide 2x2 and 4x2 interactive Android Home Screen Widgets.
   - *Value*: Users can launch their top 4 favorite YouTube channels or playlists directly from their phone's home screen with 1 tap, without opening the main app UI.

4. **Dynamic App Icon Quick Actions (`ShortcutManager`)**:
   - *Concept*: Utilize Android OS native dynamic shortcuts. Long-pressing the **YT Shortcuts** app icon on the phone home screen displays quick launch shortcuts for the top 4 most recently or frequently launched channels.

---

#### Category C: Offline QR Code Utilities & Air-Gapped Handoff
*Inspired by `sreeraj_qr_reader` and `SreerajP_CodeApp`* — **[Status: Implemented ✅]**

5. **In-App Offline QR Scanner**:
   - *Status*: **Implemented ✅**
   - *Concept*: Add an offline camera scanner (or gallery image picker) to scan YouTube QR codes directly into **YT Shortcuts** without typing or pasting URLs. Includes receiver handoff sheet ("Shortcut Received!") with options to Save or Open in YouTube.

6. **Offline QR Code Generator for Shortcuts**:
   - *Status*: **Implemented ✅**
   - *Concept*: Generate an on-screen QR code for any saved YouTube shortcut. Another device running a QR reader can scan it to instantly open or save the shortcut without needing internet or messaging apps.

---

#### Category D: Offline Launch Reminders & Habit Scheduling
*Inspired by `chronotune-smart-clock` and `Sanathana_Dharma_Clock`*

7. **Local Scheduled Launch Notifications (`flutter_local_notifications`)**:
   - *Concept*: Allow users to set local offline reminders for recurring live streams, daily news broadcasts, or scheduled study sessions (e.g., "Daily News at 8:00 AM").
   - *Privacy*: Uses Android local alarm manager — no remote push servers or external network connections.

---

#### Category E: Playback Controls, Timestamps & Private Notes
*Inspired by `SreerajP_Journal_Vault` and `SreerajP_LalithaSahasranamam`*

8. **Start-Time Timestamp Support (`?t=1m30s`)**:
   - *Concept*: Allow users to append start timestamps to video shortcuts so clicking the shortcut jumps straight to a specific timestamp in the YouTube app.

9. **Shortcut Notes & Annotations**:
   - *Concept*: Add an optional local text note field to shortcut cards (e.g., "Key chapter starts at 12:45", "Live stream on Tuesdays").

---

#### Category F: Privacy Lock & Encrypted Backup Vault
*Inspired by `vault-files` and `SreerajP_Authenticator`* — **[Status: Implemented ✅]**

10. **Biometric / Local PIN Protection (`local_auth`)**:
    - *Status*: **Implemented ✅**
    - *Concept*: An optional local security lock (fingerprint/face unlock or local PIN) to gate access to the app or specific hidden shortcut categories.

11. **Password-Encrypted JSON Backup Export**:
    - *Status*: **Implemented ✅**
    - *Concept*: Option to encrypt exported backup files using AES-256 with a user-provided passphrase, ensuring backup files stored on external SD cards or local folders remain encrypted.

---

#### Category G: Batch Utilities, Markdown Import & PDF Export
*Inspired by `SreerajP_TextApp` and `SreerajP_PDFApp`*

12. **Batch Multi-Link Text/Markdown Parser**:
    - *Concept*: A bulk import tool where users paste raw text, Markdown files, or link lists containing multiple YouTube URLs/handles. The parser automatically extracts and creates individual shortcuts in one batch.

13. **Printable PDF Cheat Sheet Export (`pdf` / `printing`)**:
    - *Concept*: Export the user's saved shortcuts collection into a clean, printable PDF cheat sheet containing initial badges, names, canonical links, and optional QR codes for physical offline reference.

---

#### Category H: Smart Pattern Auto-Categorization
*Inspired by `sms-sentry`*

14. **Pattern-Based Auto-Tagging**:
    - *Concept*: Apply local regex rule matching to automatically assign tags during shortcut creation (e.g., links containing `/shorts/` tagged as Short, handles ending in `News` tagged as News).

---

#### Category I: Enhanced Visual Customization & Themes
*Inspired by `SreerajP_Devi` and `chronotune-smart-clock`* — **[Status: Implemented ✅]**

15. **Expanded Theme System**:
    - *Status*: **Implemented ✅**
    - *Concept*: Introduce curated dark themes such as **AMOLED Pure Black**, **Warm Sepia**, **Forest Dark**, and **Cyberpunk Neon** to complement existing Light/Dark modes.

16. **Custom Card Accent Colors**:
    - *Status*: **Implemented ✅**
    - *Concept*: Allow users to manually pick custom avatar background colors or icons for specific shortcuts to make launcher cards immediately distinct.

---

### Ecosystem Feature Matrix

| Feature | Status | Ecosystem Inspiration | Privacy Level | Implementation Complexity |
| :--- | :--- | :--- | :--- | :--- |
| **Custom Tags & Favorites** | **Implemented ✅** | `SreerajPContactSphere`, `sreerajp_todo` | 100% Local | Low |
| **Android Home Widgets** | Planned | `chronotune-smart-clock`, `daily_rule_cards` | 100% Local | Medium |
| **Launcher Dynamic Shortcuts** | Planned | `sreerajp_todo` | 100% Local | Low |
| **Offline QR Scanner & Generator**| **Implemented ✅** | `sreeraj_qr_reader`, `SreerajP_CodeApp` | 100% Local | Medium |
| **Scheduled Launch Alarms** | Planned | `chronotune-smart-clock`, `Sanathana_Dharma_Clock` | 100% Local | Medium |
| **Timestamps (`?t=...`) & Notes** | Planned | `SreerajP_Journal_Vault`, `SreerajP_LalithaSahasranamam` | 100% Local | Low |
| **Biometric Lock & Encrypted Backup**| **Implemented ✅** | `vault-files`, `SreerajP_Authenticator` | 100% Local | Medium |
| **Batch Link Parser & PDF Export** | Planned | `SreerajP_TextApp`, `SreerajP_PDFApp` | 100% Local | Medium |
| **Smart Rule Auto-Tagging** | Planned | `sms-sentry` | 100% Local | Low |
| **AMOLED & Custom Themes** | **Implemented ✅** | `SreerajP_Devi`, `chronotune-smart-clock` | 100% Local | Low |

---

### Next Steps for Development

When selecting features from this roadmap for implementation:
1. Create a dedicated plan file in `plans/` before making code changes.
2. Ensure new dependencies added to `pubspec.yaml` contain zero transitive networking packages.
3. Update `docs/architecture.md` and `docs/sreerajp_youtube_shortcut_idea.md` once features are built and tested.
