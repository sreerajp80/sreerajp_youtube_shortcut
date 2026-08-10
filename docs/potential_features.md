# Potential Features & App Ecosystem Roadmap — YT Shortcuts

This document outlines potential features that can be implemented in **YT Shortcuts** (`sreerajp_youtube_shortcut`). These feature ideas are derived from an in-depth analysis of the current project alongside the 18 local Flutter Android applications in your development suite (`myapps.md`).

---

## 1. Core Design & Architectural Compliance

Every proposed feature in this document strictly adheres to the core engineering and security principles of **YT Shortcuts**:

- **100% Offline-First**: No network calls, no cloud services, and **zero `INTERNET` permission** added to `AndroidManifest.xml`.
- **Zero Telemetry or Analytics**: No user tracking, analytics SDKs, or cloud crash reporting.
- **Privacy-First & Data Sovereignty**: All shortcut data, custom tags, notes, and preferences remain strictly on-device in `SharedPreferences` or permissionless Storage Access Framework (SAF) JSON backups.
- **Android Hardening**: Built for Android (minSdk 24, targetSdk 35) using `provider` + `ChangeNotifier` state management.

---

## 2. Recommended Feature Roadmap by Category

### Category A: Advanced Organization, Tagging & Favorites
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

### Category B: Android OS Integration & Launcher Productivity
*Inspired by `chronotune-smart-clock` and `daily_rule_cards`*

3. **Android Home Screen Widgets (`home_widget`)**:
   - *Concept*: Provide 2x2 and 4x2 interactive Android Home Screen Widgets.
   - *Value*: Users can launch their top 4 favorite YouTube channels or playlists directly from their phone's home screen with 1 tap, without opening the main app UI.

4. **Dynamic App Icon Quick Actions (`ShortcutManager`)**:
   - *Concept*: Utilize Android OS native dynamic shortcuts. Long-pressing the **YT Shortcuts** app icon on the phone home screen displays quick launch shortcuts for the top 4 most recently or frequently launched channels.

---

### Category C: Offline QR Code Utilities & Air-Gapped Handoff
*Inspired by `sreeraj_qr_reader` and `SreerajP_CodeApp`* — **[Status: Implemented ✅]**

5. **In-App Offline QR Scanner**:
   - *Status*: **Implemented ✅**
   - *Concept*: Add an offline camera scanner (or gallery image picker) to scan YouTube QR codes directly into **YT Shortcuts** without typing or pasting URLs. Includes receiver handoff sheet ("Shortcut Received!") with options to Save or Open in YouTube.

6. **Offline QR Code Generator for Shortcuts**:
   - *Status*: **Implemented ✅**
   - *Concept*: Generate an on-screen QR code for any saved YouTube shortcut. Another device running a QR reader can scan it to instantly open or save the shortcut without needing internet or messaging apps.

---

### Category D: Offline Launch Reminders & Habit Scheduling
*Inspired by `chronotune-smart-clock` and `Sanathana_Dharma_Clock`*

7. **Local Scheduled Launch Notifications (`flutter_local_notifications`)**:
   - *Concept*: Allow users to set local offline reminders for recurring live streams, daily news broadcasts, or scheduled study sessions (e.g., "Daily News at 8:00 AM").
   - *Privacy*: Uses Android local alarm manager — no remote push servers or external network connections.

---

### Category E: Playback Controls, Timestamps & Private Notes
*Inspired by `SreerajP_Journal_Vault` and `SreerajP_LalithaSahasranamam`*

8. **Start-Time Timestamp Support (`?t=1m30s`)**:
   - *Concept*: Allow users to append start timestamps to video shortcuts so clicking the shortcut jumps straight to a specific timestamp in the YouTube app.

9. **Shortcut Notes & Annotations**:
   - *Concept*: Add an optional local text note field to shortcut cards (e.g., "Key chapter starts at 12:45", "Live stream on Tuesdays").

---

### Category F: Privacy Lock & Encrypted Backup Vault
*Inspired by `vault-files` and `SreerajP_Authenticator`* — **[Status: Implemented ✅]**

10. **Biometric / Local PIN Protection (`local_auth`)**:
    - *Status*: **Implemented ✅**
    - *Concept*: An optional local security lock (fingerprint/face unlock or local PIN) to gate access to the app or specific hidden shortcut categories.

11. **Password-Encrypted JSON Backup Export**:
    - *Status*: **Implemented ✅**
    - *Concept*: Option to encrypt exported backup files using AES-256 with a user-provided passphrase, ensuring backup files stored on external SD cards or local folders remain encrypted.

---

### Category G: Batch Utilities, Markdown Import & PDF Export
*Inspired by `SreerajP_TextApp` and `SreerajP_PDFApp`*

12. **Batch Multi-Link Text/Markdown Parser**:
    - *Concept*: A bulk import tool where users paste raw text, Markdown files, or link lists containing multiple YouTube URLs/handles. The parser automatically extracts and creates individual shortcuts in one batch.

13. **Printable PDF Cheat Sheet Export (`pdf` / `printing`)**:
    - *Concept*: Export the user's saved shortcuts collection into a clean, printable PDF cheat sheet containing initial badges, names, canonical links, and optional QR codes for physical offline reference.

---

### Category H: Smart Pattern Auto-Categorization
*Inspired by `sms-sentry`*

14. **Pattern-Based Auto-Tagging**:
    - *Concept*: Apply local regex rule matching to automatically assign tags during shortcut creation (e.g., links containing `/shorts/` tagged as Short, handles ending in `News` tagged as News).

---

### Category I: Enhanced Visual Customization & Themes
*Inspired by `SreerajP_Devi` and `chronotune-smart-clock`* — **[Status: Implemented ✅]**

15. **Expanded Theme System**:
    - *Status*: **Implemented ✅**
    - *Concept*: Introduce curated dark themes such as **AMOLED Pure Black**, **Warm Sepia**, **Forest Dark**, and **Cyberpunk Neon** to complement existing Light/Dark modes.

16. **Custom Card Accent Colors**:
    - *Status*: **Implemented ✅**
    - *Concept*: Allow users to manually pick custom avatar background colors or icons for specific shortcuts to make launcher cards immediately distinct.

---

## 3. Ecosystem Feature Matrix

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

## 4. Next Steps for Development

When selecting features from this roadmap for implementation:
1. Create a dedicated plan file in `plans/` before making code changes.
2. Ensure new dependencies added to `pubspec.yaml` contain zero transitive networking packages.
3. Update `docs/architecture.md` and `docs/features.md` once features are built and tested.
