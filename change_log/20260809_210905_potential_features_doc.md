# Change Log: Add Potential Features & App Ecosystem Roadmap Document

**Plan Reference:** `plans/20260809_205236_potential_features_doc.md`

## What Changed
- Created `docs/potential_features.md`, which provides an in-depth breakdown of feature possibilities for **YT Shortcuts** based on an analysis of the app's current functionality and the user's Flutter Android app ecosystem (`myapps.md`).
- Organised potential features across 9 distinct categories:
  1. Advanced Organization, Tagging & Favorites
  2. Android OS Integration & Launcher Productivity (Home Widgets, Dynamic Launcher Quick Actions)
  3. Offline QR Code Utilities & Air-Gapped Handoff (QR Scanning & QR Generation)
  4. Offline Launch Reminders & Habit Scheduling
  5. Playback Controls, Timestamps & Private Notes
  6. Privacy Lock & Encrypted Backup Vault (Biometric Auth & AES-256 Backup Encryption)
  7. Batch Utilities, Markdown Import & PDF Cheat Sheet Export
  8. Smart Pattern Auto-Categorization
  9. Enhanced Visual Customization & Themes (AMOLED Black, Accent Colors)
- Verified strict adherence to project guidelines: 100% offline-first, no `INTERNET` permission, zero network calls, zero telemetry, local storage sovereignty.

## Verification
- Verified file creation at `docs/potential_features.md`.
- Ran `flutter analyze` — passed cleanly with zero warnings/issues.
