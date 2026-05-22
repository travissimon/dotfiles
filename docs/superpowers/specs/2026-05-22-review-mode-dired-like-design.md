# review-mode — Dired-like single-level listing

**Date:** 2026-05-22
**Status:** Approved (pending implementation plan)
**Supersedes (partially):** [2026-05-22-emacs-review-mode-design.md](2026-05-22-emacs-review-mode-design.md) — rendering and navigation only; data layer and faces unchanged.

## Goal

Change the review buffer from a flat recursive listing (all files with full repo-relative paths) to a single-level dired-like listing of the current scope's immediate entries. Directories show one row with the union of their descendants' status bits; RET descends into a directory in the same buffer; `^` ascends to the parent.

The data layer, git baseline detection, face definitions, bitmask scheme, and file-row visit behavior (`magit-diff-review-open`) are unchanged.

## Motivation

The current flat listing puts every changed file in a repo on one screen with full paths. For repos with deep trees this is noisy and hard to scan, and it hides the structural shape of where changes live. A dired-like view makes the same data legible by collapsing entire subtrees into a single row when the user doesn't care about their internals, and lets the user navigate in to see detail on demand.

## Scope

In scope:
- Edits to `nix/tsimon-modules/emacs/review.el` only.
- New buffer-local navigation between sibling scopes.
- New aggregation function that folds the full recursive `(relpath . bits)` list into one-level entries.
- New `review-descend` and `review-ascend` commands; updated RET dispatcher; new `^` binding.

Out of scope:
- Changes to `review--collect-files`, git helpers, `review--detect-main-branch`, or face definitions.
- Changes to `review-current`'s file-visiting shortcut (when the buffer visits a file with changes).
- A tree-expand-inline (dired-subtree-style) variant.
- Opening descended scopes in separate buffers.
- Sorting controls, filtering, hidden-file toggling, or any new view options.

## Behavior

### Rendering

A review buffer at scope S (a repo-relative directory path, possibly the repo root) shows:

1. Optionally, a `..` entry as the first row when S is not the repo root. The `..` row uses no status columns (three spaces) and has the directory face/property pointing at the parent scope.
2. All immediate subdirectories of S that contain at least one file in the underlying collection, sorted alphabetically. Each row shows the basename with a trailing `/`, the union of all descendant files' bits in the S/U/C columns, and the matching face from `review--face-for-bitmask`.
3. All immediate files of S, sorted alphabetically, each row showing the basename (not the relative path), its own bits, and matching face.

Empty scopes (no immediate files or subdirs) show `  (no files)` exactly as today.

The header line continues to show `review: <root><scope>  (vs <main>)`.

### Navigation

- **RET on a file row** — unchanged: `magit-diff-review-open` against the main branch; deleted-file message preserved.
- **RET on a directory row** — calls `review-descend`, which rebuilds the buffer with the new scope (current scope joined with the directory's basename, with trailing `/`). Buffer name is updated to reflect the new scope. Point lands on the first entry (the `..` row).
- **RET on the `..` row** — calls `review-ascend`, equivalent to pressing `^`.
- **`^`** — calls `review-ascend`, which rebuilds the buffer with the parent scope. Clamped at the repo root: ascending from the root is a no-op with `(message "review: already at repo root")`.
- **`C-o`** — unchanged: `find-file` on the entry. If the entry is a directory, opens it in dired; if a file, opens it normally.
- **`n` / `p`** — unchanged behavior, but now traverse both file and directory rows (any row with a `review-entry` property).
- **`g`** — `review-refresh` preserves the current scope and tries to restore point on the same entry (file or directory) as before.
- **`q`** — unchanged.

Scope changes (descend, ascend, refresh) reuse the same buffer. The buffer is renamed via `rename-buffer` to `*review: <abbreviated-abs-scope>*` so the modeline reflects where you are.

### Aggregation

Given the full recursive list `((relpath . bits) ...)` already returned by `review--collect-files`, and a scope prefix P (empty string for repo root, or `"sub/dir/"`):

For each `(relpath . bits)` whose relpath begins with P, take the remainder R = relpath minus P. If R contains no `/`, it is an immediate file of the scope → emit `(:kind file :name R :bits bits :relpath relpath)`. Otherwise, let D be the first path component of R → contribute `bits` to the entry for directory D via bitwise-OR; the directory's repo-relative path is `P + D + "/"`.

Sort: directories alphabetically first, then files alphabetically. Prepend the `..` row when scope is non-root.

## Data structures

A new buffer-local does not need to be added; `review--scope` already holds the current scope as a repo-relative string. Its semantics are clarified:

- `nil` and `"."` both mean "repo root" (current code already treats both the same in `review--collect-files`). For navigation purposes, scope is normalized to either `""` (root) or `"sub/dir/"` (with leading no-slash and trailing slash).

A line-level property change: rows store `'review-entry (KIND . RELPATH)` where KIND is `'file`, `'dir`, or `'parent`, and RELPATH is the repo-relative path (with trailing `/` for dirs). The existing `'review-file` property is removed.

## Function inventory

New / modified functions in `review.el`:

| Function | Status | Purpose |
|---|---|---|
| `review--normalize-scope` | new | Returns `""` for nil/`"."`/`""`, else ensures trailing `/`. |
| `review--parent-scope` | new | `""` → `""`, `"a/"` → `""`, `"a/b/"` → `"a/"`. |
| `review--aggregate-entries` | new | Pure: `(entries scope) → ((:kind … :name … :bits … :relpath …) …)` sorted dirs-then-files. |
| `review--format-line` | modified | Takes an entry plist; emits `..` rows with blank status columns; appends `/` to dir names; stores `'review-entry` property. |
| `review--build-buffer` | modified | Calls aggregation before rendering; prepends `..` row when scope ≠ root; renames buffer to reflect scope. |
| `review--line-entry` | new (replaces `review--line-file`) | Returns the `(KIND . RELPATH)` cons or nil. |
| `review-visit-file` | modified | Dispatches on KIND: file → existing magit-diff-review-open path; dir → `review-descend`; parent → `review-ascend`. |
| `review-find-file` | modified | Uses `review--line-entry`; opens dirs in dired, files via `find-file`. |
| `review-descend` | new | Rebuilds buffer at `(scope + dir-basename + "/")`. |
| `review-ascend` | new | Rebuilds buffer at parent scope; no-op at root. |
| `review-refresh` | modified | Uses `review--line-entry` to remember/restore the entry under point. |
| `review-mode-map` | modified | Bind `^` to `review-ascend`. |
| `review--path-column` | unchanged | Still `10` — same `  S U C   ` prefix. |
| `review--collect-files` | unchanged | Still returns the full recursive list scoped to the *whole* path passed in. |

## Edge cases

- **Untracked files in directories not otherwise tracked by git.** Already handled by `review--collect-files` via `git ls-files --others --exclude-standard -z`. These contribute the unstaged bit to whichever immediate-subdir they live in, so a directory containing only untracked files still shows up.
- **Deleted files.** Still present in the bit-tracked entries (staged or unstaged). Their directory aggregates the bit normally. The existing "deleted on disk" message on RET still fires.
- **Renames.** `-M` is already passed to the relevant diff invocations; the rename's new path is the one that lands in the aggregation.
- **Symlinks to directories** are treated as files by `git ls-files`; no special handling needed.
- **A subdir whose name shadows a file at the same level.** Cannot happen — git won't allow both `foo` and `foo/bar` in the same tree.
- **`review-current` invoked from the repo root.** Scope normalizes to `""`; behavior identical to `M-x review`.
- **`g` after the directory under point has been entirely cleaned up** (e.g., user committed all changes inside it). Refresh rebuilds; the directory no longer appears; point falls back to `(point-min)` per the existing code path.
- **Descending into a subdir that has been deleted on disk between renderings.** `review--collect-files` simply returns nothing for that prefix; the buffer shows `(no files)`. User can `^` out.

## Collection-time optimization (deferred)

`review--collect-files` currently runs five git invocations across the entire scope. When descending into a subdirectory, we could narrow the pathspec to the new scope to speed things up, but for any plausibly-sized repo the cost is already negligible, and the current behavior (always scoped at the repo root) means descend/ascend can reuse the same data if we cache it. We do **not** add caching in this change — each scope change re-runs the collection. If users observe latency in large monorepos, caching can be added later behind `review--cache` without changing the rendering layer.

## Testing

Manual verification (no automated test infrastructure exists for these elisp modules):

1. `M-x review` at repo root — shows top-level dirs (`nix/`, `docs/`, etc.) with aggregated bits matching `git status` summary, plus any top-level files.
2. RET on `nix/` — buffer rescopes to `nix/`, shows `..`, `tsimon-modules/`, and any direct files like `home-tsimon.nix`.
3. `^` from `nix/` — returns to root with point on `nix/`.
4. RET on `..` — same as `^`.
5. `^` at root — message "already at repo root"; no buffer change.
6. `M-x review-current` from a buffer visiting `nix/tsimon-modules/emacs/review.el` — file has changes, goes straight to magit-diff-review (unchanged behavior).
7. `M-x review-current` from a `dired` buffer in `nix/tsimon-modules/` — opens review buffer scoped there.
8. `g` after an external `git add` — refresh shows updated status; point preserved on the same entry.
9. Directory containing only an untracked file — directory appears with `U` bit set, descending into it shows the untracked file.

## Implementation order

1. Add `review--normalize-scope`, `review--parent-scope`, `review--aggregate-entries` (pure functions, no rendering yet — test with `(review--aggregate-entries '(("a/b" . 1) ("c" . 2)) "")` in `M-:`).
2. Rename `review--line-file` → `review--line-entry` and update its return type; update callers minimally to keep compilation.
3. Rewrite `review--format-line` to take an entry plist; update `review--build-buffer` to call the aggregator and emit `..`.
4. Add `review-descend` and `review-ascend`; modify `review-visit-file` to dispatch.
5. Bind `^`; update `review-find-file`; update `review-refresh` restore logic.
6. Manual pass through the test list above.
