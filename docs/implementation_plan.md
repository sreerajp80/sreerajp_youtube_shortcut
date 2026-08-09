# Implementation Plan — SreerajP YouTube Shortcuts

This point-in-time document records the project build roadmap and compliance milestones.

**Date:** 2026-08-09
**Scope:** Compliance with Shared Flutter Guidelines & About Screen JSON Architecture

---

## 1. Phase 1: Submodule Integration & Pointer Setup

- Objective: Integrate `Flutter_Guidelines` repository as Git submodule.
- Deliverables:
  - Added Git submodule at `docs/guidelines`.
  - Added `docs/GUIDELINES_MANIFEST.md` pointer file.

## 2. Phase 2: Root Instruction Alignment

- Objective: Align `CLAUDE.md` and `AGENTS.md` with master guidelines.
- Deliverables:
  - Standardized identity table.
  - Added explicit link to `docs/GUIDELINES_MANIFEST.md` in read-first table.
  - Inlined mandatory Workflow Rules (plan-approve-log) and Communication Rules (simple English).

## 3. Phase 3: Baseline Documentation Expansion

- Objective: Ensure all 8 mandatory baseline docs exist under `docs/`.
- Deliverables:
  - `docs/workflow_rules.md`
  - `docs/dependencies.md`
  - `docs/project_structure.md`
  - `docs/implementation_plan.md`
  - `docs/implementation_progress.md`

## 4. Phase 4: About Screen JSON Architecture

- Objective: Migrate hardcoded About metadata to `assets/config/app_config.json`.
- Deliverables:
  - Created `assets/config/app_config.json`.
  - Registered asset path in `pubspec.yaml`.
  - Created `lib/core/config/app_config.dart` and `lib/core/config/config_service.dart`.
  - Updated `AboutScreen` to render `details` map dynamically.
