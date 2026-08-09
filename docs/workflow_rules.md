# Workflow Rules — SreerajP YouTube Shortcuts

This living document outlines the mandatory workflow standards for making changes in this repository.

Read [AGENTS.md](../AGENTS.md) and [CLAUDE.md](../CLAUDE.md) before making changes.

---

## 1. Plan Before Changing

Every non-trivial modification must begin with an explicit implementation plan written to `plans/` named `yyyymmdd_hhMMss_<short-slug>.md`.

The plan must include:
- `**Status:**` indicator (e.g., Pending Approval).
- List of target files to edit, create, or delete.
- Problem statement / requirement description.
- Detailed solution design and verification strategy.

## 2. Explicit User Approval Gate

After writing the plan:
- **STOP execution and request explicit user approval.**
- Do not edit, create, or delete any project files until explicit approval is received.
- A question or ambiguous response from the user is not an approval.

## 3. Log After Changing

Once implementation and verification are complete:
- Write a change log file to `change_log/` named `yyyymmdd_hhMMss_<short-slug>.md`.
- Detail what was changed, referencing the original plan file.

## 4. Privacy and Relative Paths Only

All files created in `plans/` and `change_log/`:
- MUST use relative repository paths only (never absolute paths such as `C:\...` or `l:\...`).
- MUST NOT contain any sensitive, private, or internet-inappropriate data (tokens, keys, secrets, passwords, local paths, PII).
