# Security

Use this document when the repository handles secrets, protected personal data, health data,
financial data, private files, or any local encrypted store.

If the app is not security-sensitive, keep this file short and document that decision explicitly.

---

## 1. Security Scope

- App: `SreerajP YouTube Shortcuts`
- Framework: `Flutter 3.44.8`
- Data sensitivity level: `low`
- Engineering standard profiles in force:
  - `Core Baseline`
- Platforms in scope:
  - `Android`

The app is not security-sensitive in the traditional sense. It stores user-provided YouTube URLs
and shortcut names locally, with no authentication, no secrets, and no app-managed network
traffic. The main security goals are avoiding accidental data leakage, avoiding accidental network
capabilities, and keeping the Android manifest minimal.

---

## 2. Security Objectives

- Keep the Flutter app fully offline with no `INTERNET` permission and no app-managed HTTP calls.
- Prevent user-entered shortcut names and YouTube URLs from appearing in logs.
- Keep local data in app-private storage only and disable Android backup for v1.
- Avoid unintended exported Android components or unnecessary permissions.
- Fail safely when malformed URLs or missing YouTube-app launches occur.

---

## 3. Threat Model Summary

Document the threats the product is designed to address and those it explicitly does not address.

### In Scope Threats

- Malformed user input causing crashes or incorrect deep links.
- User-provided URLs leaking through logs, diagnostics, or backup.
- Accidental introduction of network-capable dependencies or manifest permissions.
- Misconfigured Android components or release flags (`debuggable`, `allowBackup`, exported
  components).

### Out Of Scope Threats

- Fully compromised or rooted devices.
- Physical hardware attacks.
- OS-level compromise.
- Reverse engineering by determined attackers beyond normal mobile hardening.
- Privacy or security behavior inside the external YouTube app after the launch handoff.

---

## 4. Sensitive Data Inventory

| Data Type | Example | Where It Exists | Protection Required |
|-----------|---------|-----------------|---------------------|
| Shortcut name | `My Tamil Songs` | In-memory form state, local JSON store | Do not log; keep in app-private storage |
| Original YouTube URL | `https://youtu.be/...` | In-memory form state, local JSON store | Do not log; keep in app-private storage |
| Canonical launch URL | `https://www.youtube.com/watch?v=...` | Derived in memory, local JSON store | Do not log; keep in app-private storage |
| About metadata | Version, build date, AI-used label | Android build config + package info + `--dart-define` | Public metadata; no special protection |

Although the stored data is low sensitivity, it can still reveal viewing preferences. Treat it as
private user input for logging and backup decisions.

---

## 5. Storage Model

### At Rest

- Primary local storage: `SharedPreferences`
- Storage shape: versioned JSON payload under an app-owned key
- Secure key storage: not applicable
- Backup behavior: Android backup disabled with `android:allowBackup="false"`

### In Memory

- User-entered values live briefly in form controllers before save or cancel.
- Saved shortcuts are loaded into app state for list rendering.
- No explicit memory wiping is required because the data is low sensitivity, but controllers and
  state objects must be disposed normally.

### In Transit

- Network use: none by the Flutter app
- Inter-app handoff: explicit Android intent targeting the YouTube app package

---

## 6. Cryptography Design

Not applicable. No encryption is planned in v1 because the app stores no secrets, credentials,
tokens, or regulated personal data.

If future requirements add protected exports, sync, or account data, this section must be
rewritten before implementation begins.

---

## 7. Authentication And Access Control

- App-lock strategy: none
- Fallback behavior: not applicable
- Session-expiry rule: not applicable
- Background lock rule: not applicable
- Protected-route strategy: none
- Lock screen implementation: none

Access is governed entirely by normal Android device access. The app does not expose share targets,
content providers, custom exported activities, or deep-link entry points in v1.

---

## 8. Binary Protections

### 8.1 Obfuscation

All production release builds MUST be compiled with:

```bash
--obfuscate --split-debug-info=build/symbols/android-<version>/
```

Obfuscation is applied for baseline resistance against casual reverse engineering.

### 8.2 R8 / ProGuard

Android release builds run R8 code shrinking. Verify `proguard-rules.pro` keeps Flutter engine
classes and any future native plugin classes that require reflection rules.

### 8.3 Debuggable Flag

Verify `android:debuggable=false` in the merged release manifest before every production release.
A debuggable release build allows an attacker to attach a debugger to the process, inspect memory,
and change behavior at runtime.

---

## 9. Logging And Telemetry Policy

### Never Log

- Original YouTube URLs
- Canonical launch URLs
- User-entered shortcut names
- Full serialized shortcut payloads

### Allowed Diagnostic Context

- Operation name such as `add_shortcut` or `launch_shortcut`
- Error category such as `validation_failed`, `storage_failed`, or `youtube_unavailable`
- Aggregate counts such as total shortcut count

### Logging Controls

- Logger implementation: thin app wrapper around `debugPrint` / `dart:developer`
- Telemetry SDKs: none
- Verbose logging gate: debug mode only
- Log level in production: info, warning, and error only
- Redaction strategy: avoid logging user input entirely rather than partial masking

---

## 10. Platform Security Controls

### Android

- `android:allowBackup`: `false`
- `android:debuggable`: MUST be `false` in release builds
- `android:usesCleartextTraffic`: `false` or omitted
- `INTERNET` permission: absent
- Runtime permissions: none
- Screenshot protection: not required in v1
- Root detection: none
- Exported components: only the main launcher activity

### iOS

Not applicable.

### Windows

Not applicable.

---

## 11. Permissions

| Permission | Why It Is Needed | Requested When | Denial Handling |
|------------|------------------|----------------|-----------------|
| None | The app is offline and launches YouTube through normal Android intent handling | Never | Not applicable |

Permission review rules:
- Do not add `INTERNET`.
- Do not add broad package visibility or unrelated media/storage permissions.
- If a future feature requires package-install checks, prefer catching launch failure over adding
  wider visibility rules.

---

## 12. OWASP Mobile Top 10 Compliance

Review and sign off each item before every production release.

| ID | Risk | Control | Status |
|----|------|---------|--------|
| M1 | Improper Credential Usage | No credentials, tokens, or secrets used | `n/a` |
| M2 | Inadequate Supply Chain Security | Keep `pubspec.lock`; audit dependencies for offline safety and analytics risk | `verified` |
| M3 | Insecure Authentication | No authentication flow | `n/a` |
| M4 | Insufficient Input/Output Validation | Validate supported YouTube hosts, paths, and empty names before save or launch | `verified` |
| M5 | Insecure Communication | No app-managed network communication | `n/a` |
| M6 | Inadequate Privacy Controls | No logs of user-entered URLs or names; backup disabled | `verified` |
| M7 | Insufficient Binary Protections | `--obfuscate` applied and `android:debuggable=false` verified | `verified` |
| M8 | Security Misconfiguration | Minimal manifest, no permissions, no exported extras, `allowBackup=false` | `verified` |
| M9 | Insecure Data Storage | Data stored only in app-private storage; low sensitivity; no backup | `verified` |
| M10 | Insufficient Cryptography | No cryptography required in v1 | `n/a` |

For each `risk-accepted` item, document the justification and owner below the table.

---

## 13. Data Retention And Purge Policy

Define what data is stored, how long it lives, and what triggers deletion.

### Retention Schedule

| Data Type | Retention Period | Deletion Trigger |
|-----------|-----------------|-----------------|
| Saved shortcuts | Indefinite | User deletes an item, clears all shortcuts, or uninstalls the app |

### Purge Implementation

- Provide per-shortcut delete.
- Provide a user-accessible "Clear all shortcuts" action.
- Uninstall removes app data by default.

### Data Purge On Uninstall

- Android: app data deleted on uninstall.

---

## 14. Backup, Import, Export, And Recovery

- Backup supported: no
- Backup format: not applicable
- Import supported: no
- Export supported: no
- Recovery flow: no
- Plaintext export policy: not applicable

Because backup is disabled and no import/export is supported in v1, there is no recovery
mechanism beyond recreating shortcuts manually.

---

## 15. Security Testing Strategy

| Area | Test Type | Notes |
|------|-----------|-------|
| YouTube URL validation | Unit | Accept supported URL shapes and reject malformed or non-YouTube input |
| Local persistence | Unit | Verify save, load, delete, and clear-all behavior |
| External launch behavior | Unit / integration | Verify explicit YouTube-app launch path and safe failure when unavailable |
| Android manifest | Manual release review | Confirm no `INTERNET`, `allowBackup=false`, and no unnecessary permissions |

### Required Test Vectors Or Regression Areas

- Standard watch URL
- `youtu.be` short URL
- Shorts URL
- Playlist or channel URL if supported in the current build
- Empty name
- Empty URL
- Non-YouTube URL
- YouTube-app launch failure path

---

## 16. Incident Response Notes

- Triage owner: Developer
- Severity model: Low to medium depending on whether logs, backup, or manifest scope is affected
- Immediate containment actions:
  - Stop distributing the affected build
  - Remove or patch the leaking code path
  - Rebuild with corrected manifest or logging behavior
- User communication trigger: Required only if a shipped build exposed user-entered shortcut data
- Patch release process reference: `docs/release_process.md`

---

## 17. Open Risks And Future Hardening

- Risk: Stored shortcut names and URLs may reveal viewing preferences to someone with device access.
  Mitigation: Keep data local, disable backup, and never log user input.
- Risk: A future dependency may introduce analytics or hidden network behavior.
  Mitigation: Audit every added dependency and verify the merged manifest before release.
- Future hardening option: Optional app lock if the product scope ever expands to more sensitive
  personal media data.

---

## 18. Security Review Checklist

Complete before every production release.

- [ ] Threat model reviewed.
- [ ] Sensitive data inventory reviewed.
- [ ] Logging policy reviewed and enforced.
- [ ] `INTERNET` permission confirmed absent.
- [ ] `android:allowBackup=false` confirmed in merged manifest.
- [ ] No unnecessary permissions declared.
- [ ] No unexpected exported components present.
- [ ] `--obfuscate` confirmed in release commands.
- [ ] Debug symbols archived.
- [ ] `android:debuggable=false` verified.
- [ ] ProGuard / R8 rules reviewed.
- [ ] OWASP Mobile Top 10 checklist completed.
- [ ] Data retention and clear-all behavior reviewed.
- [ ] Tests cover URL validation, persistence, and launch failure behavior.

