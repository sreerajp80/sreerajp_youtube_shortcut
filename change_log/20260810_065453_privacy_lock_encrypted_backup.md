# Change Log: Privacy Lock & Password-Encrypted Backup Vault

**Date:** 2026-08-10
**Plan Reference:** [plans/20260810_065224_privacy_lock_encrypted_backup.md](file:///l:/Android/sreerajp_youtube_shortcut/plans/20260810_065224_privacy_lock_encrypted_backup.md)

## Summary
Implemented Category F: Privacy Lock & Password-Encrypted Backup Vault in YT Shortcuts, inspired by patterns from `vault-files` and `SreerajP_Authenticator`.

## Changes Made

### Native & Project Configuration
- `pubspec.yaml`: Added `local_auth`, `encrypt`, `crypto`, and `pointycastle` dependencies.
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_youtube_shortcut/MainActivity.kt`: Updated inheritance to `FlutterFragmentActivity` for Android `BiometricPrompt` support.

### Data Models & Repositories
- `lib/src/shortcut_models.dart`: Added `isPrivate` boolean flag to `ShortcutEntry`.
- `lib/src/services/privacy_lock_service.dart`: Implemented biometric availability check/authentication and PBKDF2-HMAC-SHA256 PIN hashing with salt generation.
- `lib/src/shortcut_repository.dart`: Added persistent storage methods for `appLockEnabled`, `privateLockEnabled`, `pinHash`, and `pinSalt`.

### State Management & Encryption Logic
- `lib/src/privacy_lock_store.dart`: Created `PrivacyLockStore` (`ChangeNotifier`) to manage lock states, PIN configuration, biometric unlock, and app lifecycle auto-lock on pause.
- `lib/src/backup_service.dart`: Added AES-256-GCM encrypted backup encoding (`encodeEncrypted`), decryption (`decodeEncrypted`), and payload detection (`isEncrypted`).
- `lib/src/shortcut_store.dart`: Added passphrase support to `exportShortcutsToFile` and `importShortcutsFromFile`.

### UI Components
- `lib/src/screens/privacy_lock_screen.dart`: Implemented PIN numpad keypad & biometric unlock prompt UI.
- `lib/src/screens/settings_screen.dart`: Added "Privacy & Security" section with App Lock toggle, Private Shortcuts Lock toggle, and PIN setup dialog.
- `lib/src/screens/backup_restore_screen.dart`: Added passphrase encryption toggle on Export and password decryption prompt on Import.
- `lib/src/screens/add_shortcut_screen.dart`: Added "Private Shortcut" switch tile.
- `lib/src/screens/home_screen.dart`: Filtered private shortcuts when private lock is enabled and vault is locked.
- `lib/src/app_shell.dart`: Added `_PrivacyLockGate` with `WidgetsBindingObserver` to lock app on backgrounding.
- `lib/main.dart`: Initialized `PrivacyLockStore` and passed to `ShortcutApp`.

### Unit & Integration Tests
- `test/privacy_lock_service_test.dart`: Added tests for salt generation, PIN hashing, and verification.
- `test/privacy_lock_store_test.dart`: Added tests for PIN setup, app lock toggle, and lifecycle locking.
- `test/backup_service_test.dart`: Added tests for password-encrypted backup export/import round-tripping and wrong passphrase rejection.

## Verification
- `flutter pub get`: Resolved all dependencies cleanly.
- `flutter analyze`: Zero static analysis issues found.
- `flutter test`: All 68 unit and widget tests passed.
