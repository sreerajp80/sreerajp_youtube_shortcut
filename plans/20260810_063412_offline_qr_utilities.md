# Implementation Plan - Category C: Offline QR Code Utilities & Air-Gapped Handoff

**Status:** Proposed

## Overview
Implement Category C features inspired by `sreeraj_qr_reader` and `SreerajP_CodeApp`:
1. **In-App Offline QR Scanner & Receiver**: Camera scanner and gallery image scanner using `mobile_scanner` to scan YouTube QR codes directly into YT Shortcuts without typing or pasting URLs. Includes receiver handoff sheet ("Shortcut Received!") with "Save to YT Shortcuts" and "Open in YouTube" CTAs.
2. **Offline QR Code Generator for Shortcuts**: On-screen QR code generator using `qr_flutter` for any saved YouTube shortcut so another device running YT Shortcuts or any QR reader can scan it to instantly open or save the shortcut without internet or messaging apps.

---

## Analysis of `sreeraj_qr_reader`
From analyzing `sreeraj_qr_reader`:
- Uses `mobile_scanner` for live camera scanning (`MobileScannerController`, `BarcodeFormat.qrCode`).
- Camera permission handling with fallback state when permission is denied.
- Torch/flash toggle, front/back camera switch, and scanner viewport overlay widget.
- Scanning local image files from gallery using `image_picker` and `MobileScannerController.analyzeImage(path)`.
- Air-gapped handoff payload format supporting standard YouTube URLs, handles, and JSON payloads (`{"name": "...", "url": "...", "tags": [...]}`).

---

## Files to Modify / Create

1. **`pubspec.yaml`**
   - Add `qr_flutter: ^4.1.0` (for rendering offline QR code widgets).
   - Add `mobile_scanner: ^7.4.0` (for offline camera & gallery QR code scanning).
   - Add `image_picker: ^1.1.2` (for picking QR code images from gallery).

2. **`android/app/src/main/AndroidManifest.xml`**
   - Add `<uses-permission android:name="android.permission.CAMERA"/>` for camera QR scanner. (Maintain zero `INTERNET` permission!).

3. **`lib/src/qr_payload_parser.dart`** [NEW]
   - Parse scanned QR payloads (supports plain YouTube URLs, channel handles, and JSON payloads with name, url, tags).
   - Build QR JSON payload string for generating QR codes with embedded name/url/tags.

4. **`lib/src/widgets/shortcut_qr_dialog.dart`** [NEW]
   - Modal dialog / view displaying generated QR code using `QrImageView` with shortcut title, category badge, canonical URL, and copy URL action.

5. **`lib/src/screens/qr_scanner_screen.dart`** [NEW]
   - Camera scanner UI inspired by `sreeraj_qr_reader` with overlay frame, torch toggle, camera switcher, and gallery image picker (`image_picker` + `analyzeImage`).
   - Scans QR payload, parses YouTube shortcut data, and presents "Shortcut Received!" handoff dialog with "Save to YT Shortcuts" and "Open in YouTube" CTAs.

6. **`lib/src/screens/home_screen.dart`**
   - Add QR Scan button in app bar / header.
   - Add "Show QR Code" action when single shortcut is selected in selection mode.

7. **`lib/src/screens/add_shortcut_screen.dart`**
   - Add "Scan QR Code" action button next to URL field / header to scan link directly into the form.

8. **`lib/src/screens/shortcut_detail_screen.dart`**
   - Add "Show QR Code" action button in header / app bar.

9. **`lib/src/screens/permissions_screen.dart`**
   - Document `android.permission.CAMERA` under runtime permissions for offline QR scanning.

10. **`docs/potential_features.md`**
    - Mark Category C (Offline QR Code Utilities) as implemented.

11. **`test/qr_payload_parser_test.dart`** [NEW]
    - Unit tests for QR payload serialization and parsing.

---

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero errors/warnings.
- Run `flutter test` to ensure all existing and new unit tests pass.

### Manual Verification
- Generate QR code for a saved YouTube shortcut and verify QR rendering.
- Test QR payload parsing for standard YouTube URLs, handles, and JSON payloads.
- Test launching QR scanner screen, camera permission handling, torch toggle, camera switch, and gallery image picking.
