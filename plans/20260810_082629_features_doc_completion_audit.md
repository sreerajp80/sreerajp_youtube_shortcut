# Plan — Complete and Audit docs/features.md

**Status:** Pending Approval

## Problem
The features documentation in `docs/features.md` was audited against the codebase (`lib/src/`). The following minor omissions and details were identified to ensure 100% accuracy and completeness:
1. **Section 5.1 (Home Screen)**: Omits the **Scan QR code** icon button on the Home screen app bar (which is always visible and opens `QrScannerScreen`). The text incorrectly states there are four controls when shortcuts exist.
2. **Section 5.4 (Settings Screen)**: Omits the **Privacy & Security Card** section present on the Settings screen (which allows configuring the Security PIN, toggling App Lock, and toggling Private Shortcut Lock).
3. **Section 5.1 (Home Screen Selection Bar)**: Capitalization of tooltip string (`Show QR code` in code vs `Show QR Code`).

## Proposed Changes

### Documentation

#### [MODIFY] [features.md](file:///l:/Android/sreerajp_youtube_shortcut/docs/features.md)

1. **Update Section 5.1 (Home Screen)**:
   - Accurately document the Home screen app bar controls:
     - **Scan QR code button**: Always visible in the app bar (tooltipped "Scan QR code"), opens the in-app Offline QR Scanner (`QrScannerScreen`).
     - **Grid / List layout switch button**: Shown when shortcuts exist, toggles view mode.
     - **Sort menu**: Shown when shortcuts exist, popup menu icon (tooltipped "Sort shortcuts") with "Favorites first" toggle and 5 sort modes.
     - **Options menu**: Shown when shortcuts exist, popup menu icon (tooltipped "Options") containing "Reorder shortcuts" and "Clear all shortcuts".
     - **Settings button**: Always visible in the app bar, opens the Settings screen.
   - Update single-item selection bar action tooltips for exact string match (`Show QR code`).

2. **Update Section 5.4 (Settings Screen)**:
   - Document the **Privacy & Security Card**: Set or change 4–6 digit local Security PIN, toggle App Lock, and toggle Lock Private Shortcuts.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero static analysis warnings.
- Run `flutter test` to ensure all existing test suites pass.

### Manual Verification
- Review `docs/features.md` line by line against `lib/src/` screens and stores to ensure 100% completeness and accuracy in plain, simple English.
