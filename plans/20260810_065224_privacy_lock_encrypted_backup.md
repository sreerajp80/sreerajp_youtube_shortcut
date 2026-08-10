# Plan: Privacy Lock & Password-Encrypted Backup Vault

**Status:** Proposed

## Overview
This plan implements Category F: Privacy Lock & Encrypted Backup Vault in YT Shortcuts, inspired by `vault-files` and `SreerajP_Authenticator`.

The feature consists of two main parts:
1. **Biometric / Local PIN Protection (`local_auth`)**:
   - Optional security lock (fingerprint, face unlock, or local PIN) to gate app access or private/hidden shortcut categories.
   - Auto-lock when the app is paused or sent to the background.
2. **Password-Encrypted JSON Backup Export**:
   - Option to encrypt exported backup files using AES-256-GCM with PBKDF2 key derivation and a user-provided passphrase.
   - Decryption prompt during import when an encrypted backup file is selected.

---

## Files to Change

### Project Dependencies & Android Configuration
- `pubspec.yaml`: Add `local_auth`, `encrypt`, `crypto`, and `pointycastle` dependencies.
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_youtube_shortcut/MainActivity.kt`: Change base class from `FlutterActivity` to `FlutterFragmentActivity` for `local_auth` BiometricPrompt compatibility.

### Models & Repositories
- `lib/src/shortcut_models.dart`: Add `isPrivate` property to `ShortcutEntry` to allow marking shortcuts as hidden/private.
- `lib/src/services/privacy_lock_service.dart` [NEW]: Service for biometric check, local PIN hashing (PBKDF2-HMAC-SHA256), and security preference management.
- `lib/src/shortcut_repository.dart`: Add persistent storage getters/setters for privacy lock settings (app lock enabled, private category lock enabled, PIN hash, PIN salt).

### State & Business Logic
- `lib/src/privacy_lock_store.dart` [NEW]: `ChangeNotifier` for managing app lock state, vault unlock state, PIN setup, and app lifecycle auto-lock listener.
- `lib/src/backup_service.dart`: Update `ShortcutBackupService` to support AES-256-GCM encrypted payload encoding and decoding with PBKDF2 key derivation.
- `lib/src/shortcut_store.dart`: Integrate privacy lock state and add encrypted export/import methods.

### UI Screens & Widgets
- `lib/src/screens/privacy_lock_screen.dart` [NEW]: Lock screen overlay / PIN entry view for authenticating when app lock or private category lock is active.
- `lib/src/screens/settings_screen.dart`: Add Privacy & Security section for toggling App Lock, Private Shortcut Lock, and setting up / changing PIN.
- `lib/src/screens/backup_restore_screen.dart`: Add passphrase option to Export, and passphrase prompt to Import when an encrypted file is detected.
- `lib/src/screens/add_shortcut_screen.dart` & `lib/src/screens/shortcut_detail_screen.dart`: Add toggle for marking shortcuts as private.
- `lib/src/screens/home_screen.dart`: Filter or mask private shortcuts when vault is locked and private shortcut lock is enabled.
- `lib/main.dart`: Wrap `AppShell` with `PrivacyLockStore` provider and lifecycle observer for app lock.

### Tests
- `test/privacy_lock_service_test.dart` [NEW]: Unit tests for PIN hashing, verification, and biometric checks.
- `test/backup_service_test.dart`: Unit tests for encrypted export & import round-tripping, bad passphrase handling, and backward-compatible plain JSON import.
- `test/privacy_lock_store_test.dart` [NEW]: Unit tests for lock state transitions.

---

## Detailed Implementation Plan

### Step 1: Add Dependencies & Update Android Activity
1. In `pubspec.yaml`, add:
   - `local_auth: ^2.3.0`
   - `encrypt: ^5.0.3`
   - `crypto: ^3.0.6`
   - `pointycastle: ^3.9.1`
2. Update `MainActivity.kt` to extend `FlutterFragmentActivity` instead of `FlutterActivity`.

### Step 2: Privacy Lock Service & Repository Storage
1. Implement `PrivacyLockService` to handle:
   - Check if biometric authentication is available (`isBiometricAvailable`).
   - Authenticate with biometrics using `local_auth`.
   - Hash PIN using PBKDF2-HMAC-SHA256 with random salt.
   - Verify PIN input against stored salt + hash.
2. In `ShortcutRepository`:
   - Add methods to store/read `appLockEnabled`, `privateLockEnabled`, `pinHash`, and `pinSalt` in `SharedPreferences`.

### Step 3: Privacy Lock Store & Lock Screen UI
1. Implement `PrivacyLockStore` (`ChangeNotifier`):
   - Track `isAppLocked`, `isPrivateVaultUnlocked`, `appLockEnabled`, `privateLockEnabled`, `hasPinConfigured`.
   - Listen to `AppLifecycleState.paused` / `AppLifecycleState.resumed` to trigger auto-lock when backgrounded.
   - Methods: `authenticateApp()`, `unlockPrivateVault()`, `setPin()`, `changePin()`, `toggleAppLock()`, `togglePrivateLock()`.
2. Create `PrivacyLockScreen` widget:
   - Clean security UI offering biometric unlock button and PIN numpad fallback.

### Step 4: Password-Encrypted JSON Backup Vault
1. Update `ShortcutBackupService`:
   - Add `encodeEncrypted({required List<ShortcutEntry> entries, required String passphrase, required DateTime exportedAtUtc})`:
     - Generates 16-byte random salt and 12-byte random IV.
     - Derives 256-bit key using PBKDF2-HMAC-SHA256 (10,000 iterations).
     - Encrypts JSON string with AES-256-GCM.
     - Formats payload as `"v1:<salt_b64>:<iv_b64>:<ciphertext_b64>"`.
   - Add `isEncrypted(String raw)` check.
   - Update `decode`:
     - If string starts with `"v1:"`, attempt decryption with `passphrase`. If passphrase missing or wrong, throw `ShortcutBackupException('Invalid password or corrupted backup file.')`.
     - Otherwise, parse plain JSON as before (backward compatible with existing backups).

### Step 5: UI Integration in Settings, Backup, Detail & Home Screens
1. **Settings**: Add Security section to configure PIN and toggle App Lock / Private Shortcuts Lock.
2. **Backup & Restore**:
   - Export: Switch or checkbox for "Encrypt Backup with Password". Dialog asks for passphrase.
   - Import: If picked file is encrypted, prompt user for passphrase before importing.
3. **Shortcut Entry & Detail**: Toggle `isPrivate` to mark shortcuts as private.
4. **Home Screen**: If Private Lock is enabled and vault is locked, hide/lock private shortcuts with an option to unlock via biometric/PIN.

### Step 6: Automated Verification & Manual Testing
1. Run `flutter pub get`.
2. Run `flutter analyze` to ensure zero warnings.
3. Run `flutter test` to verify all new and existing tests pass.

---

## Security & Architectural Guarantees
- **Offline Only**: No network calls, completely offline.
- **Privacy Respecting**: Passphrases and PINs are hashed with PBKDF2 + salt; plaintext secrets are never logged.
- **Backward Compatible**: Existing plain JSON backup files continue to import seamlessly.
