# Dependencies — SreerajP YouTube Shortcuts

This living document records the approved package dependencies and strict dependency constraints for this project.

Read [security.md](security.md) for full offline security guidelines.

---

## 1. Approved Runtime Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | Framework UI foundation |
| `provider` | `^6.1.5+1` | State management (`ChangeNotifierProvider`, `Provider`) |
| `shared_preferences` | `^2.5.5` | Persistent local key-value JSON storage |
| `package_info_plus` | `^9.0.1` | Reads platform version and build number for verification |
| `android_intent_plus` | `^6.0.0` | Explicit Android intent launcher to open YouTube |

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
