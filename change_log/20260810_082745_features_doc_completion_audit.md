# Change Log — Complete and Audit docs/features.md

**Plan Reference:** `plans/20260810_082629_features_doc_completion_audit.md`

## Summary of Changes
- Updated `docs/features.md` to ensure complete and accurate documentation of all implemented application capabilities:
  - **Section 5.1 (Home Screen)**: Documented the always-visible **Scan QR code button** on the Home app bar (tooltipped "Scan QR code"), corrected the App Bar controls summary to reflect all 5 action controls, and fixed selection bar action tooltip casing ("Show QR code").
  - **Section 5.4 (Settings Screen)**: Added documentation for the **Privacy & Security Card** section (PIN setup/change dialog, App Lock toggle, and Lock Private Shortcuts toggle).

## Verification Conducted
- `flutter analyze`: Passed with 0 static analysis issues.
- `flutter test`: Passed all 70 unit and widget tests cleanly.
