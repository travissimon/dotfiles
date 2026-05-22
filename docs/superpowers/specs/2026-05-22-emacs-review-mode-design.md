# Emacs review-mode — Design Spec

**Date:** 2026-05-22
**Status:** Approved (pending implementation plan)

## Goal

Add an Emacs major mode that displays a dired-like, flat recursive listing of files in the current git repo that have any of three states: working-tree-modified-staged, working-tree-modified-unstaged, or committed-on-this-branch-but-not-yet-on-main. Clicking a file opens the existing `magit-diff-review-mode` showing the full diff against the main branch.

Exposed via `M-x review` (whole repo) and `M-x review-current` (current dir, or current file if buffer visits one).

## Scope

In scope:
- New file `nix/tsimon-modules/emacs/review.el`
- Wiring in `nix/tsimon-modules/emacs/dev.el` (load the file)
- Wiring in `nix/tsimon-modules/emacs.nix` (install the file into `.emacs.d/config/`)
- 4 face variables + 1 major mode + 2 interactive commands

Out of scope:
- Modifying `magit-diff-review.el` (it is consumed as-is via `magit-diff-review-open`)
- Any UI for choosing the comparison branch (always vs main/master)
- Multi-repo or worktree-aware behavior
- Editing changes from the review buffer (it is read-only, like dired with no edit)

## Comparison baseline

All "committed" detection is **vs the repo's main branch**. Detection order:
1. `main` (if it exists locally or as `origin/main`)
2. `master` (if it exists locally or as `origin/master`)
3. Fall back to `git symbolic-ref --short refs/remotes/origin/HEAD` (strip `origin/` prefix)
4. If none found, signal an error: `"review: cannot detect main branch"`

The detected branch name is used in:
- `git diff --name-only <main>..HEAD -- <root>` to find committed-not-on-main files
- The revision argument passed to `magit-diff-review-open` when a file is clicked

## Data model

Per file under the review root, compute a bitmask of three independent booleans:

| Bit | Source command                                                               |
|-----|------------------------------------------------------------------------------|
| S   | `git diff --cached --name-only -- <root>`                                    |
| U   | `git diff --name-only -- <root>` **∪** `git ls-files --others --exclude-standard -- <root>` |
| C   | `git diff --name-only <main>..HEAD -- <root>`                                |

A file appears in the listing iff any bit is set.

Untracked files count as U (unstaged). Rationale: otherwise newly-added files don't appear in a review at all, which would be a serious blind spot.

## Faces

Four `defface` definitions, all using muted/desaturated tones so they don't dominate the buffer:

| Face                    | When applied                                            | Default foreground |
|-------------------------|---------------------------------------------------------|--------------------|
| `review-unstaged-face`  | Only U bit set                                          | `#b8a13e` (muted yellow) |
| `review-staged-face`    | Only S bit set                                          | `#b87a3d` (muted orange) |
| `review-committed-face` | Only C bit set                                          | `#a85858` (muted red)    |
| `review-mixed-face`     | Any combination of two or more bits (SU, SC, UC, SUC)   | `#a85858` (muted red, same as committed by user request) |

The faces are independent `defface`s even though committed and mixed share a default — the user can later redefine them separately.

## Buffer layout

Buffer name: `*review: <abbreviated-root>*` (or `*review: <subdir>*` for the subtree case).

Header line (rendered as the first lines of the buffer, not the `header-line-format`):
```
*review: ~/dotfiles/  (vs main)*

```

Each file line is exactly 10 characters wide before the path begins:

```
  S U C   nix/tsimon-modules/emacs/dev.el
  S         nix/tsimon-modules/emacs/general.el
    U       nix/tsimon-modules/emacs/init.el
      C     nix/tsimon-modules/emacs/review.el
  S   C   nix/tsimon-modules/emacs.nix
```

Breakdown (10 chars total before path):
- 2-space indent
- S-marker: `S` or space (1 char)
- separator: space (1 char)
- U-marker: `U` or space (1 char)
- separator: space (1 char)
- C-marker: `C` or space (1 char)
- 3-space gap, then path

Path properties:
- Face: determined by bitmask → face mapping above
- `mouse-face 'highlight`
- `'review-file` text property = absolute file path (used by RET/click)

Files are sorted alphabetically by relative path (locale-independent, case-sensitive).

Empty case: if no files match, the buffer shows the header followed by a single line: `  (no changes)`.

## Major mode

`review-mode`, derived from `special-mode`. Buffer is read-only.

Keymap:

| Key       | Command                       | Behavior                                                                                          |
|-----------|-------------------------------|---------------------------------------------------------------------------------------------------|
| `RET`     | `review-visit-file`           | Open file at point via `magit-diff-review-open` with main branch as rev                           |
| `<mouse-2>` | `review-visit-file`         | Same as RET                                                                                       |
| `n`       | `review-next-file`            | Move point to next file line                                                                      |
| `p`       | `review-prev-file`            | Move point to previous file line                                                                  |
| `g`       | `review-refresh`              | Re-run git commands and rebuild the buffer in place, preserving point on the same file if possible |
| `q`       | `quit-window`                 | Standard special-mode quit                                                                        |

All other printable-character keys inherit `special-mode`'s default (no self-insert; effectively a no-op). Unlike `magit-diff-review-mode`, no edit-on-disk prompt — the review buffer is purely a navigation listing.

## Entry points

### `(defun review () (interactive) ...)`

1. Find git root via `(magit-toplevel)`. If nil, signal `user-error "review: not inside a git repository"`.
2. Open/reuse buffer `*review: <abbreviated-root>*` rooted at that directory.
3. Populate via `review--build-buffer ROOT ROOT` (review-root and listing-scope are the same).
4. `pop-to-buffer` it.

### `(defun review-current () (interactive) ...)`

Branch on `(buffer-file-name)`:

- **Buffer visits a file:**
  1. Verify the file is inside a git repo (`magit-toplevel` from the file's directory).
  2. Detect main branch.
  3. Call `(magit-diff-review-open <relative-path-from-toplevel> <main-branch>)`. The review listing is skipped entirely.

- **Buffer does NOT visit a file** (e.g., dired, eshell, scratch):
  1. Use `default-directory` as the listing scope.
  2. Find git root via `magit-toplevel`. Error if not in a git repo.
  3. Open buffer `*review: <abbreviated-default-directory>*`.
  4. Populate via `review--build-buffer GIT-ROOT DEFAULT-DIRECTORY` — the git commands are scoped via `-- <default-directory>` so only files under that subtree appear.
  5. `pop-to-buffer` it.

## File visit (RET handler)

`review-visit-file` reads the `'review-file` text property at point. If non-nil:
1. Compute the file path relative to `magit-toplevel`.
2. Call `(magit-diff-review-open RELATIVE-PATH MAIN-BRANCH)`.

If nil (point is on the header or empty-state line), do nothing (or message "No file at point").

The main branch is captured as a buffer-local variable `review--main-branch` at buffer construction time, so RET doesn't have to re-detect it each time.

## Internal API

```elisp
(defvar-local review--root nil
  "Git root for this review buffer.")

(defvar-local review--scope nil
  "Listing scope (subdir under root) for this review buffer.")

(defvar-local review--main-branch nil
  "Detected main branch name (e.g. \"main\" or \"master\").")

(defun review--detect-main-branch () ...)
  ;; Returns string or signals user-error.

(defun review--collect-files (root scope main-branch)
  ;; Returns list of (RELATIVE-PATH . BITMASK) sorted by path.
  ;; BITMASK is an integer: 1=S, 2=U, 4=C.

(defun review--face-for-bitmask (bitmask) ...)
  ;; Returns one of the 4 face symbols.

(defun review--build-buffer (root scope) ...)
  ;; Erases current buffer, sets buffer-locals, inserts header + lines.
  ;; Caller is responsible for putting the right buffer current.
```

## Error handling

- Not in a git repo → `user-error "review: not inside a git repository"`
- No main branch detected → `user-error "review: cannot detect main branch (tried main, master, origin/HEAD)"`
- git command failure → let `magit-git-*` signal naturally; do not swallow

## Nix wiring

Add to `nix/tsimon-modules/emacs.nix` under `home.file`:
```nix
file.".emacs.d/config/review.el" = {
  source = ./emacs/review.el;
};
```

Add to `nix/tsimon-modules/emacs/dev.el` near the `magit-diff-review.el` load line:
```elisp
(load "/home/tsimon/.emacs.d/config/review.el")
```

(Load order: must come *after* `magit-diff-review.el` since `review.el` calls `magit-diff-review-open`.)

## Testing strategy

Manual testing in a scratch git repo with a mix of file states:
1. Create a repo, make initial commit on `main`.
2. Create branch `feature`, make a commit (→ C state).
3. Stage an edit to a file (→ S state, or SC if same file).
4. Make an unstaged edit to another file (→ U state).
5. Add an untracked file (→ U state via untracked).
6. Create combinations: same file with both staged and unstaged edits (SU), staged edit to a committed file (SC), etc.
7. Verify:
   - `M-x review` shows all 7 possible bitmask combinations correctly colored
   - `M-x review-current` from inside a subdir filters to that subtree
   - `M-x review-current` from a file buffer opens magit-diff-review directly
   - RET on each file opens the correct diff against main
   - `g` refreshes after external git operations
   - Behavior outside a git repo errors cleanly
   - Behavior on the default branch (where no `<main>..HEAD` commits exist) is sane (just shows S/U files)

## Open questions / risks

- **`magit-toplevel` vs `projectile-project-root`:** Using `magit-toplevel` because this feature is intrinsically git-centric. If a user's project root differs from the git toplevel (e.g., monorepo with submodules), the review will be scoped to the containing git repo, which is correct for diff semantics.
- **Performance on large repos:** Each invocation runs ~3 git commands. Should be fast (sub-second) for repos up to ~10k changed files. No caching for v1 — `g` refresh is manual.
- **`magit-diff-review-open` advice on `magit-diff-visit-file`:** Already installed by `magit-diff-review.el`. The new `review` mode reuses the same entry function and is unaffected.
