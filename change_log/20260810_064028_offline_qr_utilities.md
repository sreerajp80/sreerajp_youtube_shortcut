# Change Log - Category C: Offline QR Code Utilities & Air-Gapped Handoff

**Date:** 2026-08-10  
**Plan Reference:** [plans/20260810_063412_offline_qr_utilities.md](file:///l:/Android/sreerajp_youtube_shortcut/plans/20260810_063412_offline_qr_utilities.md)

---

## Summary of Changes

Implemented **Category C** features (In-App Offline QR Scanner and Offline QR Code Generator for Shortcuts) inspired by `sreeraj_qr_reader` and `SreerajP_CodeApp`:

1. **Dependency & Manifest Updates**:
   - `pubspec.yaml`: Added `qr_flutter: ^4.1.0` (pure Dart offline QR code rendering), `mobile_scanner: ^7.4.0` (on-device vision camera scanner), and `image_picker: ^1.1.2` (gallery image scanner).
   - `android/app/src/main/AndroidManifest.xml`: Added `<uses-permission android:name="android.permission.CAMERA"/>` with optional camera hardware feature declarations (maintaining 100% offline-first design with zero `INTERNET` permission).

2. **Core QR Payload Serialization & Parsing**:
   - `lib/src/qr_payload_parser.dart`: Created `QrPayloadParser` and `ParsedQrPayload` to serialize shortcuts to structured JSON payloads (`{"type": "yt_shortcut", "name": "...", "url": "...", "tags": [...]}`) and parse incoming QR codes (supporting structured JSON, plain YouTube URLs, and channel handles).

3. **Offline QR Code Generator Dialog**:
   - `lib/src/widgets/shortcut_qr_dialog.dart`: Created `ShortcutQrDialog` modal displaying high-contrast QR codes rendered via `QrImageView` with shortcut title, initial avatar badge, category pill, canonical link, and 1-tap copy URL action.

4. **In-App Offline QR Scanner & Receiver Handoff Screen**:
   - `lib/src/screens/qr_scanner_screen.dart`: Created `QrScannerScreen` featuring live camera vision preview, scanner viewport frame, flash toggle button, front/back camera switch button, and gallery image picker (`image_picker` + `analyzeImage`). Includes receiver handoff sheet ("Shortcut Received!") offering **Save to YT Shortcuts** and **Open in YouTube** CTAs.

5. **UI Screen Integration**:
   - `lib/src/screens/home_screen.dart`: Added QR Scanner action button in main AppBar and "Show QR code" action button in single-item selection bar.
   - `lib/src/screens/add_shortcut_screen.dart`: Added `initialNameInput` and `initialTags` constructor support and added a QR code scanner suffix action button on the URL text field.
   - `lib/src/screens/shortcut_detail_screen.dart`: Added "Show QR Code" action button in AppBar actions and Quick Action button row.
   - `lib/src/screens/permissions_screen.dart`: Documented `android.permission.CAMERA` under explicit runtime permissions used exclusively for offline QR scanning.

6. **Documentation & Unit Tests**:
   - `docs/potential_features.md`: Marked Category C features as implemented ✅.
   - `test/qr_payload_parser_test.dart`: Added unit tests for QR payload serialization, JSON parsing, URL extraction, handle parsing, and empty state validation.

---

## Verification

- `flutter analyze`: Clean (0 errors, 0 warnings).
- `flutter test`: Passed all 57 unit and widget tests.
