# Change log: Create docs/features.md

Implements plan: `plans/20260802_153206_docs_features_file.md`

## What changed

Added a new file, `docs/features.md`, that describes the app and lists every current
feature: the shortcut data model, the supported YouTube link formats, every screen and
what it does (Home, Add/Edit Shortcut, Shortcut Detail, Settings, About, Permissions,
Channel Handles, Backup & Restore, Fatal Error), the app-wide settings, how opening a
shortcut works, and a clear list of things the app does not do (no internet, no sign-in,
no home-screen widgets, no analytics, etc.).

The content was written after reading the app's screens, models, URL formatter,
launcher service, and Android manifest, so it reflects the app as it exists today. No
other files were changed.

## Why

The user wants a single, accurate document they can hand to an LLM before asking it to
add a feature to this or another app, so the LLM can see what already exists and avoid
duplicating or conflicting work.
