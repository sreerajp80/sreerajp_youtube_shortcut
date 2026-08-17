# Dependencies — SreerajP YouTube Shortcuts

This living document records the approved package dependencies and strict dependency constraints for this project.

Read [security.md](security.md) for full offline security guidelines.

---

## 1. Approved Runtime Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | Framework UI foundation |
| `flutter_localizations` | SDK | Localization delegates required by `AppLocalizations` |
| `intl` | `any` | Locale-aware date and time formatting (version pinned by `flutter_localizations`) |
| `provider` | `^6.1.5+1` | State management (`ChangeNotifierProvider`, `Provider`) |
| `shared_preferences` | `^2.5.5` | Persistent local key-value JSON storage |
| `package_info_plus` | `^9.0.1` | Reads platform version and build number for verification |
| `android_intent_plus` | `^6.0.0` | Explicit Android intent launcher to open YouTube |
| `image_picker` | `^1.1.2` | Picks a QR image from the gallery (system picker only) |
| `mobile_scanner` | `^7.4.0` | On-device camera QR scanning, no network |
| `qr_flutter` | `^4.1.0` | Renders shortcut and backup QR codes |
| `crypto` | `^3.0.6` | Hashing for the privacy-lock PIN |
| `encrypt` | `^5.0.3` | AES-256 encryption for password-protected backups |
| `pointycastle` | `^3.9.1` | PBKDF2 key derivation for backup encryption |
| `local_auth` | `^2.3.0` | Biometric unlock for the privacy lock |

## 2. Approved Development Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Widget and unit testing framework |
| `flutter_lints` | `^6.0.0` | Static analysis lint rules |

## 3. Prohibited Dependencies

The app is strictly offline-first. The following types of packages are forbidden:
- HTTP clients (`http`, `dio`, `chopper`, etc.)
- Cloud / BaaS platforms (Firebase, AWS Amplify, Supabase)
- Telemetry, crash reporting, or analytics (Sentry, Crashlytics, Mixpanel)
- Ad networks or tracking SDKs
- Network status / connectivity listeners

## 4. Audit Checklist

Before adding any package:
1. Inspect its `pubspec.yaml` to ensure no transitive network dependencies are introduced.
2. Confirm the package introduces zero network permissions in the merged `AndroidManifest.xml`.
