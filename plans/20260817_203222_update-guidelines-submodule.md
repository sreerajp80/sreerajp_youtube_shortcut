# Update `docs/guidelines` Submodule

**Status:** completed

## Issue

The `docs/guidelines` submodule (Flutter Guidelines) points to an old commit.

- Current pinned commit: `aed1261`
- Latest on `origin/master`: `2b381be` ("Update")

The repo has one new commit that is not yet used by this project.

## Files to be changed

- `docs/guidelines` (submodule pointer, recorded in the git index of the parent repo)

No source code, config, or docs files in this repo change.

## Plan for the fix

1. In `docs/guidelines`, check out the latest `origin/master` commit (`2b381be`).
2. Confirm the submodule work tree is clean.
3. Show the new pointer with `git submodule status` and `git status` in the parent repo.
4. Leave the parent repo change **unstaged/uncommitted** unless you ask for a commit.
5. Write the change log to `change_log/`.

## Notes

- This only moves a documentation submodule. It does not touch app code, so
  `flutter analyze` / `flutter test` are not needed for this change.
- The working tree already has other unrelated modified files; they will not be touched.
