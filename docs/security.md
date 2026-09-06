# Security — SreerajP YouTube Shortcuts

Use this document when the repository handles secrets, protected personal data,
private files, or any local encrypted store.

**Read first:** [../CLAUDE.md](../CLAUDE.md) · [architecture.md](architecture.md) · [release_process.md](release_process.md) · [`docs/guidelines/security.md`](guidelines/security.md)

---

## 1. Security Scope

- App: `SreerajP YouTube Shortcuts`
- Framework: `Flutter 3.44.8`
- Data sensitivity level: `medium` (user browsing preferences, private vault shortcuts, optional PIN)
- Engineering standard profiles in force:
  - `Core Baseline`
- Platforms in scope:
  - `Android`

The app operates 100% offline with no `INTERNET` permission and no network SDKs.
The primary security goals are avoiding data leakage, securing user shortcut collections through optional
encryption and access controls, and keeping platform privileges minimal.

---

## 2. Security Objectives

- Keep the Flutter app fully offline with no `INTERNET` permission and no app-managed HTTP calls.
- Prevent user-entered shortcut names and YouTube URLs from appearing in logs or error traces.
- Keep local data in app-private storage and disable Android automated OS cloud backup (`allowBackup="false"`).
- Protect sensitive/vault shortcuts behind an optional PIN and biometric lock.
- Support password-protected, encrypted local backup export/import (AES-256 + PBKDF2).
- Restrict camera usage strictly to on-device QR scanning with zero network transmission.
- Avoid unintended exported Android components or unnecessary permissions.
- Fail safely when malformed URLs, bad backups, or missing YouTube launches occur.

---

## 3. Threat Model Summary

### In Scope Threats

- Malformed user input or malicious QR payloads causing crashes or unexpected intent dispatch.
- User-provided URLs leaking through system logs or debug messages.
- Accidental introduction of network-capable dependencies or manifest permissions.
- Unauthorized local device access to shortcuts (mitigated by optional App Lock / Private Vault).
- Unencrypted backup files being inspected or altered (mitigated by password-based AES-256 encryption).
- Misconfigured Android components or release flags (`debuggable`, `allowBackup`, exported components).

### Out Of Scope Threats

- Fully compromised, rooted, or physically tampered hardware.
- OS-level kernel compromise or malicious keyloggers.
- Privacy or tracking behavior inside the external YouTube app after intent dispatch.

---

## 4. Sensitive Data Inventory

| Data Type | Example | Where It Exists | Protection Required |
|-----------|---------|-----------------|---------------------|
| Shortcut name | `My Tech Playlist` | In-memory state, local JSON store | Do not log; keep in app-private storage |
| YouTube URL | `https://youtu.be/...` | In-memory state, local JSON store | Do not log; keep in app-private storage |
| Privacy Lock PIN | `1234` | Memory during entry only | Never stored plaintext; store only salted SHA-256 hash |
| PIN Salt | 32-character hex | `SharedPreferences` | Stored per installation |
| Backup Password | `MySecretPass` | Memory during import/export only | Never stored; wiped after PBKDF2 derivation |
| Exported Backup File | `shortcuts_backup.json` | User-selected SAF location | Plain JSON or AES-256 encrypted at user discretion |
| QR Code Payloads | Single/Bulk QR string | On-screen rendering / camera frame | Ephemeral, purely on-device |

---

## 5. Storage Model

### At Rest

- Primary local storage: `SharedPreferences` (versioned JSON).
- Private Vault shortcuts: Stored with `isPrivate: true`, hidden from main list when vault is locked.
- PIN Storage: Salted SHA-256 hash string and unique salt stored in `SharedPreferences`.
- Android Backup: Disabled with `android:allowBackup="false"`.

### In Memory

- Form controllers hold input temporarily and are disposed after submission.
- Backups and PINs are processed and immediately discarded; plain passwords are never cached in memory.

### In Transit

- Network use: Zero. Shipped release has no `INTERNET` permission.
- Inter-app handoff: Explicit Android intent to `com.google.android.youtube` via `android_intent_plus`.
- Receiving share targets: Captured via `android.intent.action.SEND` receiver in `MainActivity`.

---

## 6. Cryptography Design

The app uses standard cryptographic primitives for authentication and data protection:

### 6.1 PIN Hashing (Privacy Lock)
- Algorithm: SHA-256 (`crypto` package).
- Salt: 16-byte cryptographically secure random salt generated on initial PIN setup and stored in preferences.
- Storage: Salted hash string compared in constant-time equivalent logic. The raw PIN is never stored.

### 6.2 Encrypted Backups
- Algorithm: AES-256-CBC (`encrypt` and `pointycastle` packages).
- Key Derivation: PBKDF2 with HMAC-SHA256, 10,000 iterations, using a 16-byte random salt per export.
- Initialization Vector (IV): 16-byte random IV generated per export.
- File Envelope: Versioned JSON containing:
  - `version`: backup format version (`1`)
  - `salt`: hex-encoded PBKDF2 salt
  - `iv`: hex-encoded AES IV
  - `ciphertext`: base64-encoded encrypted JSON shortcut payload

---

## 7. Authentication And Access Control

- App-lock strategy: Optional PIN lock configured by the user.
- Biometrics: Optional fingerprint/face unlock via `local_auth` (`LocalAuthentication`).
- Scope options:
  - App-level lock: Requires unlock upon opening the app.
  - Private Vault lock: Hides marked shortcuts (`isPrivate == true`) until unlocked.
- Lifecycle lock rule: Re-locks automatically when the app enters `AppLifecycleState.paused`.
- Lock Screen implementation: Full-screen modal gate in `lib/screens/privacy_lock_screen.dart` preventing UI interaction until verified.

---

## 8. Binary Protections

### 8.1 Obfuscation

All production release builds MUST be compiled with:

```bash
--obfuscate --split-debug-info=build/symbols/android-prod-<version>/
```

### 8.2 R8 / ProGuard

Android release builds run R8 code shrinking (`isMinifyEnabled = true`). Verify `proguard-rules.pro` keeps Flutter engine
and plugin classes.

### 8.3 Debuggable Flag

Verify `android:debuggable=false` in the merged release manifest before every production release.

---

## 9. Logging And Telemetry Policy

### Never Log

- Original YouTube URLs or canonical URLs.
- User-entered shortcut names or tags.
- PIN values, salts, hashes, or backup passwords.
- Full backup or shortcut JSON payloads.

### Allowed Diagnostic Context

- Operation names (`add_shortcut`, `launch_shortcut`, `backup_export`).
- Error codes from `AppErrorCode` (`validation_failed`, `decryptFailed`, etc.).
- Total counts (e.g. shortcut count, selected count).

### Logging Controls

- Telemetry SDKs: None.
- Verbose logging: Debug mode only via `debugPrint`.
- Redaction strategy: Omit sensitive fields entirely.

---

## 10. Platform Security Controls

### Android

- `android:allowBackup`: `false`
- `android:debuggable`: MUST be `false` in release builds
- `android:usesCleartextTraffic`: `false`
- `INTERNET` permission: absent in release builds
- Runtime permissions: `CAMERA` (optional, requested only when scanning QR codes)
- Exported components: `MainActivity` (`android:exported="true"`) handling `MAIN` and `SEND` intents

---

## 11. Permissions

| Permission | Why It Is Needed | Requested When | Denial Handling |
|------------|------------------|----------------|-----------------|
| `android.permission.CAMERA` | Scanning QR codes to import shortcuts or backups | Only when user taps "Scan QR Code" | UI explains permission requirement; gracefully offers gallery image pick alternative |

Permission review rules:
- Do not add `INTERNET`.
- Do not add broad storage permissions (use Android Storage Access Framework via system picker).

---

## 12. OWASP Mobile Top 10 Compliance

| ID | Risk | Control | Status |
|----|------|---------|--------|
| M1 | Improper Credential Usage | No cloud credentials; PIN stored as salted SHA-256 hash | `verified` |
| M2 | Inadequate Supply Chain Security | Audit dependencies; strictly block network and analytics SDKs | `verified` |
| M3 | Insecure Authentication | Optional local PIN and biometric lock with lifecycle auto-lock | `verified` |
| M4 | Insufficient Input/Output Validation | Validate YouTube URLs, handles, and QR payloads before processing | `verified` |
| M5 | Insecure Communication | Zero network communication; `usesCleartextTraffic="false"` | `verified` |
| M6 | Inadequate Privacy Controls | No logging of user data; `allowBackup="false"`; private vault support | `verified` |
| M7 | Insufficient Binary Protections | `--obfuscate` applied and `android:debuggable=false` verified | `verified` |
| M8 | Security Misconfiguration | Minimal manifest, only camera permission for QR, no internet | `verified` |
| M9 | Insecure Data Storage | App-private storage; AES-256 encrypted backups supported | `verified` |
| M10 | Insufficient Cryptography | Industry-standard AES-256-CBC, PBKDF2 (10,000 iter), and salted SHA-256 | `verified` |

---

## 13. Data Retention And Purge Policy

### Retention Schedule

| Data Type | Retention Period | Deletion Trigger |
|-----------|-----------------|-----------------|
| Saved shortcuts | Indefinite | User deletes shortcut, clears all, or uninstalls |
| Privacy lock PIN & salt | Indefinite | User disables PIN lock or clears app data |

### Purge Implementation

- Single shortcut delete and bulk delete.
- User-accessible "Clear All Shortcuts" confirmation dialog.
- PIN removal resets lock preferences and purges stored hash and salt.
- Android uninstallation purges all app-private storage.

---

## 14. Backup, Import, Export, And Recovery

- Backup supported: Yes (JSON export via Storage Access Framework).
- Backup formats:
  - Plain JSON: Unencrypted readable JSON backup.
  - Encrypted JSON: Password-protected AES-256-CBC envelope with PBKDF2 key derivation.
  - QR Code Backup: On-screen single QR or animated multi-frame chunked QR sequence.
- Import modes:
  - Merge mode: Adds non-duplicate shortcuts without overwriting existing entries.
  - Replace mode: Replaces current shortcuts after explicit user confirmation.
- Concurrency guard: App prevents starting a second export/import while an operation is running.

---

## 15. Security Testing Strategy

| Area | Test Type | Notes |
|------|-----------|-------|
| YouTube URL validation | Unit | Accept valid shapes and reject malformed/non-YouTube links |
| Local persistence | Unit | Verify save, load, delete, clear-all, and preference migration |
| Encryption / Decryption | Unit | Test AES-256 backup export/import with valid and incorrect passwords |
| PIN Hashing | Unit | Verify salt generation, deterministic hash matching, and bad PIN rejection |
| Privacy Lock Store | Unit | Verify lock, unlock, lifecycle pause locking, and vault filtering |
| QR Payload Parsing | Unit | Verify valid payload parsing, corrupt data rejection, and chunk reassembly |
| Android Manifest | Manual / CI | Confirm no `INTERNET`, `allowBackup=false`, `usesCleartextTraffic=false` |

---

## 16. Incident Response Notes

- Triage owner: Developer
- Severity model: Low to medium depending on whether logs, backup, or manifest scope is affected
- Immediate containment actions:
  - Stop distributing the affected build
  - Remove or patch the leaking code path
  - Rebuild with corrected manifest or logging behavior
- Patch release process reference: `docs/release_process.md`

---

## 17. Open Risks And Future Hardening

- Risk: Stored shortcut names and URLs may reveal viewing preferences if device is unlocked.
  Mitigation: Optional PIN and biometric lock, private vault feature, and encrypted backups.
- Risk: Malicious QR codes containing phishing or oversized text payloads.
  Mitigation: Rigorous input validation, payload format check, and strict YouTube domain filtering before URL handoff.

---

## 18. Security Review Checklist

Complete before every production release.

- [ ] Threat model reviewed.
- [ ] Sensitive data inventory reviewed.
- [ ] Logging policy reviewed and zero user URLs/PINs logged.
- [ ] `INTERNET` permission confirmed absent in release manifest.
- [ ] `android:allowBackup=false` confirmed in merged manifest.
- [ ] `android:usesCleartextTraffic=false` confirmed.
- [ ] Only `CAMERA` permission declared and properly gated.
- [ ] `--obfuscate` confirmed in release commands.
- [ ] Debug symbols archived securely.
- [ ] `android:debuggable=false` verified.
- [ ] ProGuard / R8 rules reviewed (`proguard-rules.pro`).
- [ ] OWASP Mobile Top 10 checklist completed.
- [ ] Cryptographic key derivation and AES-256 backup tests passing.
- [ ] Tests cover URL validation, persistence, encryption, and lock stores.
