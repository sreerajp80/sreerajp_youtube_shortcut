# Project Structure — SreerajP YouTube Shortcuts

This living document details the repository layout and layer responsibilities for SreerajP YouTube Shortcuts.

Read [architecture.md](architecture.md) for architectural rules and layer boundaries.

---

## 1. Directory Overview

```
.
├── AGENTS.md                  # Project instructions for AI agents / LLMs
├── CLAUDE.md                  # Project instructions for Claude Code
├── assets/
│   └── config/
│       └── app_config.json    # About screen metadata (source of truth)
├── android/                   # Android native platform project & Gradle configuration
├── change_log/                # Record of completed changes
├── docs/                      # Architectural, security, and build documentation
│   ├── GUIDELINES_MANIFEST.md # Shared guidelines pointer manifest
│   └── guidelines/            # Shared Flutter guidelines Git submodule
├── lib/
│   ├── core/
│   │   ├── config/            # AppConfig model & ConfigService loader
│   │   └── errors/            # Sealed domain exceptions
│   ├── models/                # Immutable domain models (ShortcutEntry, AppConfig, etc.)
│   ├── repositories/          # Data access abstractions & SharedPreferences implementation
│   ├── services/              # Platform & business logic services (Launcher, Backup, Share)
│   ├── providers/             # State holders & ChangeNotifier stores
│   ├── screens/               # Full page UI screens (Home, About, Settings, Backup)
│   ├── widgets/               # Reusable UI components & dialogs
│   └── main.dart              # App bootstrap and error handling entry point
├── plans/                     # Implementation plans awaiting approval
├── pubspec.yaml               # Flutter package configuration & asset registration
└── test/                      # Unit and widget test suite
```

## 2. Layer Responsibilities

- **`lib/core/`**: Core infrastructure, error hierarchy, and configuration loaders.
- **`lib/src/` (or `lib/models`, `lib/services`, `lib/repositories`)**: Domain logic, data access, and platform integration.
- **`lib/src/screens/`**: Screen widgets responsible for UI layout and user interaction.
- **`lib/src/widgets/`**: Reusable component widgets.
- **`test/`**: Unit and widget tests mirroring the source file structure.
