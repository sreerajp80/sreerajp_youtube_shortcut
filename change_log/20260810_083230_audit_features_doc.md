# Change Log: Audited and Completed Features Reference (`docs/features.md`)

**Date:** 2026-08-10
**Plan Reference:** `plans/20260810_083200_audit_features_doc.md`

## Summary of Changes
- Audited `docs/features.md` against the YT Shortcuts codebase (`lib/src/`, `lib/core/config/`, `lib/main.dart`).
- Updated Section 5.6 (About Screen) to document the dynamic loading of `assets/config/app_config.json` via `ConfigService` (`AppConfig`) alongside static constants in `lib/src/about_constants.dart`.
- Updated Section 6 (App-Wide State & Persistence Model) to include `AppConfig` as a provided root object (`Provider<AppConfig>`).
- Verified complete accuracy across all 8 sections covering offline architecture, security hardening, data model, link normalization, screen capabilities, theme picker, biometric/PIN privacy lock, AES-256-GCM encrypted backup vault, QR scanner/generator, intent handoff, and non-scope boundaries.

## Files Changed
- `docs/features.md`
- `plans/20260810_083200_audit_features_doc.md`
