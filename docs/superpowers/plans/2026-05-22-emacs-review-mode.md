# Emacs review-mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an `M-x review` / `M-x review-current` Emacs feature: a dired-like flat recursive listing of files with working-tree or unmerged-commit changes, color-coded by state, with RET handing off to the existing `magit-diff-review-mode`.

**Architecture:** Single new Elisp file `nix/tsimon-modules/emacs/review.el` defining 4 faces, 1 major mode (`review-mode`), and 2 interactive commands. Data layer shells out to git with `-z` and `-M` for safe path parsing and rename detection. RET delegates to the existing `magit-diff-review-open` (from `magit-diff-review.el`) with the auto-detected main branch as the revision. Wiring: load line in `dev.el`, file install entry in `emacs.nix`.

**Tech Stack:** GNU Emacs 30.2, Emacs Lisp, magit (for `magit-toplevel`, `magit-git-*`, and `magit-diff-review-open`), NixOS home-manager for installation.

**Spec:** [`docs/superpowers/specs/2026-05-22-emacs-review-mode-design.md`](../specs/2026-05-22-emacs-review-mode-design.md)

---

## Background for the implementer

You are editing a NixOS dotfiles repo. Emacs configuration files live in `/home/tsimon/dotfiles/nix/tsimon-modules/emacs/`. They are copied into `~/.emacs.d/config/` by `emacs.nix` whenever the user runs `nrs` (alias for `sudo nixos-rebuild switch --flake /home/tsimon/dotfiles/nix`).

**During development you do NOT need to rebuild Nix between code edits.** You can load the source file directly into a running Emacs session via:

```
M-x load-file RET /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el RET
```

Or in batch mode:

```
emacs --batch -l /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el --eval '<expr>'
```

The final task (Task 9) wires the file into Nix and runs the rebuild so that the configuration persists across sessions.

**Reference file to read before starting:** `/home/tsimon/dotfiles/nix/tsimon-modules/emacs/magit-diff-review.el` — defines `magit-diff-review-open` (the entry point you will call from RET) and shows the project's Elisp style conventions (lexical binding, `defvar-local` for buffer state, `define-derived-mode` from `special-mode`).

**Existing test convention:** the project has no ERT test suite. Verification is via `emacs --batch` evaluations for pure functions and explicit manual steps for UI behavior. Do not introduce a test framework.

---

## File structure

| File                                                           | Action  | Responsibility                                                |
|----------------------------------------------------------------|---------|---------------------------------------------------------------|
| `nix/tsimon-modules/emacs/review.el`                           | Create  | Faces, mode, data layer, commands, RET handler.               |
| `nix/tsimon-modules/emacs/dev.el`                              | Modify  | Add a `(load …/review.el)` line after the magit-diff-review one. |
| `nix/tsimon-modules/emacs.nix`                                 | Modify  | Add a `home.file.".emacs.d/config/review.el"` entry.          |

All implementation lives in `review.el`; the other two files only wire it in.

---

## Task 1: Skeleton — file header, faces, buffer-locals

**Files:**
- Create: `/home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el`

- [ ] **Step 1: Create the file with header, faces, buffer-locals, and provide**

```elisp
;;; review.el --- Dired-like listing of git-changed files -*- lexical-binding: t; -*-

;;; Commentary:
;; Major mode showing a flat recursive listing of files in the current git
;; repository with any of three states: staged (S), unstaged or untracked
;; (U), and committed-but-not-on-main (C).
;;
;; Entry points:
;;   M-x review          - listing rooted at the repo's git toplevel
;;   M-x review-current  - listing scoped to default-directory, OR direct
;;                         hand-off to magit-diff-review when the current
;;                         buffer visits a file
;;
;; Pressing RET on a file opens it via `magit-diff-review-open' with the
;; auto-detected main branch as the comparison revision.

;;; Code:

(require 'magit)
(require 'magit-diff-review nil 'noerror)

;; --- Faces ---

(defface review-unstaged-face
  '((t :foreground "#b8a13e"))
  "Face for files with only unstaged/untracked changes."
  :group 'review)

(defface review-staged-face
  '((t :foreground "#b87a3d"))
  "Face for files with only staged changes."
  :group 'review)

(defface review-committed-face
  '((t :foreground "#a85858"))
  "Face for files with only committed changes (not yet on main)."
  :group 'review)

(defface review-mixed-face
  '((t :foreground "#a85858"))
  "Face for files with two or more of {staged, unstaged, committed}."
  :group 'review)

;; --- Buffer-local state ---

(defvar-local review--root nil
  "Absolute path of the git root for this review buffer (with trailing slash).")

(defvar-local review--scope nil
  "Listing scope: nil for whole-repo, or a repo-relative path string
like \"nix/tsimon-modules/emacs/\" for subdir-scoped reviews.")

(defvar-local review--main-branch nil
  "Detected main branch name (e.g. \"main\" or \"master\").")

(provide 'review)
;;; review.el ends here
```

- [ ] **Step 2: Verify the file byte-compiles cleanly**

Run: `emacs --batch -L /home/tsimon/dotfiles/nix/tsimon-modules/emacs/ -f batch-byte-compile /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el`

Expected: Output may contain warnings about unused functions/vars or undefined magit symbols (since we only have skeleton), but must not contain any "Error:" lines. A `.elc` file is produced.

Cleanup: `rm /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.elc`

- [ ] **Step 3: Verify the file loads in a fresh Emacs**

Run: `emacs --batch -l /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el --eval '(message "loaded: %s" (featurep (quote review)))'`

Expected: stderr contains `loaded: t` and no `Symbol's value/function definition is void` errors.

- [ ] **Step 4: Commit**

```bash
cd /home/tsimon/dotfiles
git add nix/tsimon-modules/emacs/review.el
git commit -m "Add review.el skeleton with faces and buffer-locals"
```

---

## Task 2: Git helpers — `review--git-lines-z` and `review--detect-main-branch`

**Files:**
- Modify: `/home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el` — append before `(provide 'review)`

- [ ] **Step 1: Add `review--git-lines-z` helper**

Insert before the `(provide 'review)` line:

```elisp
;; --- Git helpers ---

(defun review--git-lines-z (&rest args)
  "Run `git ARGS' (which should include -z) in `default-directory'.
Return a list of strings split on NUL.  Trailing empty element discarded."
  (with-temp-buffer
    (let ((exit (apply #'process-file "git" nil t nil args)))
      (unless (zerop exit)
        (error "git %s failed (exit %s): %s"
               (mapconcat #'identity args " ")
               exit
               (buffer-string))))
    (let* ((raw (buffer-string))
           (parts (split-string raw "\0")))
      ;; A trailing NUL produces an empty last element; drop it.
      (if (and parts (string= (car (last parts)) ""))
          (butlast parts)
        parts))))
```

- [ ] **Step 2: Add `review--detect-main-branch`**

Insert immediately after the previous block:

```elisp
(defun review--detect-main-branch ()
  "Return the name of the main branch (\"main\", \"master\", or origin/HEAD target).
Signal `user-error' if none can be found.  Must be called inside a git repo."
  (let ((default-directory (or (magit-toplevel)
                               (user-error "review: not inside a git repository"))))
    (cond
     ;; Local branch named main or master
     ((zerop (process-file "git" nil nil nil
                           "show-ref" "--verify" "--quiet" "refs/heads/main"))
      "main")
     ((zerop (process-file "git" nil nil nil
                           "show-ref" "--verify" "--quiet" "refs/heads/master"))
      "master")
     ;; Remote tracking branch
     ((zerop (process-file "git" nil nil nil
                           "show-ref" "--verify" "--quiet" "refs/remotes/origin/main"))
      "origin/main")
     ((zerop (process-file "git" nil nil nil
                           "show-ref" "--verify" "--quiet" "refs/remotes/origin/master"))
      "origin/master")
     ;; origin/HEAD fallback
     (t
      (let ((sym (with-temp-buffer
                   (when (zerop (process-file "git" nil t nil
                                              "symbolic-ref" "--short"
                                              "refs/remotes/origin/HEAD"))
                     (string-trim (buffer-string))))))
        (if (and sym (not (string-empty-p sym)))
            sym
          (user-error
           "review: cannot detect main branch (tried main, master, origin/HEAD)")))))))
```

- [ ] **Step 3: Verify `review--git-lines-z` against the dotfiles repo**

Run:
```bash
emacs --batch -l /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el \
  --eval '(let ((default-directory "/home/tsimon/dotfiles/")) (princ (review--git-lines-z "ls-files" "-z" "--" "README.md")))'
```

Expected stdout: `(README.md)` — a one-element list.

- [ ] **Step 4: Verify `review--detect-main-branch` against the dotfiles repo**

Run:
```bash
emacs --batch -l /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el \
  --eval '(let ((default-directory "/home/tsimon/dotfiles/")) (message "%s" (review--detect-main-branch)))'
```

Expected stderr: `master` (the dotfiles repo uses `master` per `git status` shown in env).

- [ ] **Step 5: Commit**

```bash
cd /home/tsimon/dotfiles
git add nix/tsimon-modules/emacs/review.el
git commit -m "Add git helpers: NUL-safe lines reader and main-branch detection"
```

---

## Task 3: Data layer — `review--collect-files`

**Files:**
- Modify: `/home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el` — append before `(provide 'review)`

- [ ] **Step 1: Add `review--collect-files`**

Insert before the `(provide 'review)` line:

```elisp
;; --- Data layer ---

(defconst review--bit-staged 1)
(defconst review--bit-unstaged 2)
(defconst review--bit-committed 4)

(defun review--collect-files (root scope main-branch)
  "Collect changed files under ROOT, scoped to SCOPE relative path or nil.
MAIN-BRANCH is the branch name to compare HEAD against for committed state.
Return a list of (RELATIVE-PATH . BITMASK) sorted alphabetically.

BITMASK uses `review--bit-staged' (1), `review--bit-unstaged' (2),
`review--bit-committed' (4)."
  (let* ((default-directory root)
         (pathspec-args (when (and scope (not (string-empty-p scope)))
                          (list "--" scope)))
         (table (make-hash-table :test 'equal)))
    (cl-labels ((mark (path bit)
                  (puthash path (logior bit (gethash path table 0)) table)))
      ;; Staged: git diff --cached --name-only -z -M
      (dolist (p (apply #'review--git-lines-z
                        (append (list "diff" "--cached" "--name-only" "-z" "-M")
                                pathspec-args)))
        (mark p review--bit-staged))
      ;; Unstaged: git diff --name-only -z -M
      (dolist (p (apply #'review--git-lines-z
                        (append (list "diff" "--name-only" "-z" "-M")
                                pathspec-args)))
        (mark p review--bit-unstaged))
      ;; Untracked (also U): git ls-files --others --exclude-standard -z
      (dolist (p (apply #'review--git-lines-z
                        (append (list "ls-files" "--others" "--exclude-standard" "-z")
                                pathspec-args)))
        (mark p review--bit-unstaged))
      ;; Committed not on main: git diff --name-only -z -M <main>..HEAD
      (dolist (p (apply #'review--git-lines-z
                        (append (list "diff" "--name-only" "-z" "-M"
                                      (concat main-branch "..HEAD"))
                                pathspec-args)))
        (mark p review--bit-committed)))
    (let (result)
      (maphash (lambda (path bits) (push (cons path bits) result)) table)
      (sort result (lambda (a b) (string< (car a) (car b)))))))
```

- [ ] **Step 2: Build a fixture git repo for testing**

Save this script to `/tmp/review-fixture.sh` and run it (`bash /tmp/review-fixture.sh`):

```bash
#!/usr/bin/env bash
set -euo pipefail
FIX=/tmp/review-fixture
rm -rf "$FIX"
mkdir -p "$FIX"
cd "$FIX"
git init -q -b main
git config user.email test@example.com
git config user.name test
# Initial commit on main
echo "base" > base.txt
echo "to-stage-modify" > to-stage-modify.txt
echo "to-unstage-modify" > to-unstage-modify.txt
echo "to-mixed-modify" > to-mixed-modify.txt
echo "to-commit-modify" > to-commit-modify.txt
echo "to-staged-commit" > to-staged-commit.txt
echo "to-delete-unstaged" > to-delete-unstaged.txt
mkdir sub
echo "in-sub" > sub/in-sub.txt
echo "weird name" > "spaced name.txt"
git add -A
git commit -q -m "base"
# Branch off and add a committed-only change
git checkout -q -b feature
echo "committed change" >> to-commit-modify.txt
git commit -q -am "feature commit"
echo "staged + committed" >> to-staged-commit.txt
git commit -q -am "another feature commit"
# Now create working-tree state on top
echo "staged edit" >> to-stage-modify.txt
git add to-stage-modify.txt
echo "unstaged edit" >> to-unstage-modify.txt
echo "first edit (staged)" >> to-mixed-modify.txt
git add to-mixed-modify.txt
echo "second edit (unstaged)" >> to-mixed-modify.txt
# Stage a further edit to the staged+committed file
echo "more staged" >> to-staged-commit.txt
git add to-staged-commit.txt
# Working-tree delete
rm to-delete-unstaged.txt
# Untracked file
echo "untracked" > new-untracked.txt
# Edit in subdir (unstaged)
echo "sub edit" >> sub/in-sub.txt
# Working-tree edit on a file whose name has a space (tests -z NUL splitting)
echo "edit in spaced" >> "spaced name.txt"
echo "Fixture ready at $FIX"
```

Expected: `Fixture ready at /tmp/review-fixture` printed; no errors.

- [ ] **Step 3: Verify `review--collect-files` against the fixture**

Run:
```bash
emacs --batch -l /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el \
  --eval '(let ((default-directory "/tmp/review-fixture/")) (dolist (e (review--collect-files default-directory nil "main")) (princ (format "%d  %s\n" (cdr e) (car e)))))'
```

Expected stdout — the set of lines below (order is alphabetical by path; `string<` ordering puts `sub/...` after `spaced name.txt` per character codes):

```
2  new-untracked.txt
2  spaced name.txt
2  sub/in-sub.txt
4  to-commit-modify.txt
2  to-delete-unstaged.txt
3  to-mixed-modify.txt
1  to-stage-modify.txt
5  to-staged-commit.txt
2  to-unstage-modify.txt
```

Test passes iff the SET of `<bitmask>  <path>` lines matches (order may shift slightly across git/locale versions). Critical assertions:

- `spaced name.txt` appears as **one** entry (verifies `-z` NUL splitting handled the space correctly — would split into two entries on bad parsers).
- `to-stage-modify.txt` has bitmask **1** (S only).
- `to-mixed-modify.txt` has bitmask **3** (S + U).
- `to-commit-modify.txt` has bitmask **4** (C only — no working-tree edit on this file in the fixture).
- `to-staged-commit.txt` has bitmask **5** (S + C).

- [ ] **Step 4: Verify the subdir-scoped case**

Run:
```bash
emacs --batch -l /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el \
  --eval '(let ((default-directory "/tmp/review-fixture/")) (dolist (e (review--collect-files default-directory "sub/" "main")) (princ (format "%d  %s\n" (cdr e) (car e)))))'
```

Expected stdout — only the subdir file:
```
2  sub/in-sub.txt
```

- [ ] **Step 5: Commit**

```bash
cd /home/tsimon/dotfiles
git add nix/tsimon-modules/emacs/review.el
git commit -m "Add review--collect-files with NUL-safe parsing and rename detection"
```

---

## Task 4: Rendering — `review--face-for-bitmask` and `review--build-buffer`

**Files:**
- Modify: `/home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el` — append before `(provide 'review)`

- [ ] **Step 1: Add `review--face-for-bitmask`**

Insert before the `(provide 'review)` line:

```elisp
;; --- Rendering ---

(defun review--face-for-bitmask (bits)
  "Return the face symbol matching state BITS (1=S, 2=U, 4=C)."
  (pcase bits
    (1 'review-staged-face)
    (2 'review-unstaged-face)
    (4 'review-committed-face)
    (_ 'review-mixed-face)))
```

- [ ] **Step 2: Add `review--format-line` and `review--build-buffer`**

Insert immediately after the previous block:

```elisp
(defun review--format-line (relpath bits)
  "Return a propertized string for one file line: `  S U C   RELPATH\\n'."
  (let* ((s (if (zerop (logand bits review--bit-staged))    ?\s ?S))
         (u (if (zerop (logand bits review--bit-unstaged))  ?\s ?U))
         (c (if (zerop (logand bits review--bit-committed)) ?\s ?C))
         (face (review--face-for-bitmask bits))
         (prefix (format "  %c %c %c   " s u c))
         (path (propertize relpath
                           'face face
                           'mouse-face 'highlight
                           'review-file relpath)))
    (concat prefix path "\n")))

(defun review--build-buffer (root scope)
  "Populate the current buffer with a review listing for ROOT, SCOPE.
Sets buffer-locals, switches to `review-mode' if not already, and
sets `header-line-format'.  Caller must `pop-to-buffer' afterwards."
  (let* ((main (review--detect-main-branch))
         (entries (review--collect-files root scope main))
         (inhibit-read-only t))
    (unless (derived-mode-p 'review-mode)
      (review-mode))
    (setq review--root root
          review--scope scope
          review--main-branch main)
    (setq header-line-format
          (format "review: %s%s  (vs %s)"
                  (abbreviate-file-name root)
                  (or scope "")
                  main))
    (erase-buffer)
    (if (null entries)
        (insert "  (no changes)\n")
      (dolist (e entries)
        (insert (review--format-line (car e) (cdr e)))))
    (goto-char (point-min))))
```

- [ ] **Step 3: Verify `review--face-for-bitmask` for all bitmask values**

Run:
```bash
emacs --batch -l /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el \
  --eval '(dotimes (i 8) (princ (format "%d -> %s\n" i (review--face-for-bitmask i))))'
```

Expected stdout:
```
0 -> review-mixed-face
1 -> review-staged-face
2 -> review-unstaged-face
3 -> review-mixed-face
4 -> review-committed-face
5 -> review-mixed-face
6 -> review-mixed-face
7 -> review-mixed-face
```

(Bitmask 0 should not occur in practice, but `pcase`'s default arm returns mixed; this is harmless.)

- [ ] **Step 4: Verify `review--format-line` byte-compiles**

Run: `emacs --batch -L /home/tsimon/dotfiles/nix/tsimon-modules/emacs/ -f batch-byte-compile /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el 2>&1 | grep -i error || echo OK`

Expected: `OK`. (Warnings about `review-mode` not yet defined are fine — it's defined in the next task.)

Cleanup: `rm /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.elc`

- [ ] **Step 5: Commit**

```bash
cd /home/tsimon/dotfiles
git add nix/tsimon-modules/emacs/review.el
git commit -m "Add review--face-for-bitmask and buffer rendering"
```

---

## Task 5: Major mode — `review-mode` with keymap

**Files:**
- Modify: `/home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el` — append before `(provide 'review)`

- [ ] **Step 1: Add keymap and major mode**

Insert before the `(provide 'review)` line:

```elisp
;; --- Major mode ---

(defvar review-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET")     #'review-visit-file)
    (define-key map (kbd "<mouse-2>") #'review-visit-file)
    (define-key map (kbd "n")       #'review-next-file)
    (define-key map (kbd "p")       #'review-prev-file)
    (define-key map (kbd "g")       #'review-refresh)
    (define-key map (kbd "q")       #'quit-window)
    map)
  "Keymap for `review-mode'.")

(define-derived-mode review-mode special-mode "Review"
  "Major mode for the dired-like review listing.

\\{review-mode-map}"
  (setq buffer-read-only t)
  (setq truncate-lines t))
```

Stub the four command symbols (so `define-key` doesn't warn and the mode can be activated for testing) — insert immediately after the `define-derived-mode` block:

```elisp
;; Forward declarations — implemented in later sections.
(declare-function review-visit-file "review")
(declare-function review-next-file "review")
(declare-function review-prev-file "review")
(declare-function review-refresh "review")
```

- [ ] **Step 2: Verify the mode activates cleanly in batch**

Run:
```bash
emacs --batch -l /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el \
  --eval '(with-temp-buffer (review-mode) (message "mode: %s, ro: %s" major-mode buffer-read-only))'
```

Expected stderr: `mode: review-mode, ro: t`.

- [ ] **Step 3: Commit**

```bash
cd /home/tsimon/dotfiles
git add nix/tsimon-modules/emacs/review.el
git commit -m "Add review-mode and keymap"
```

---

## Task 6: RET handler — `review-visit-file` with deleted-file branch

**Files:**
- Modify: `/home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el` — append before `(provide 'review)`

**Prerequisite:** Remove the `(declare-function review-visit-file …)` line added in Task 5, since we are now defining it.

- [ ] **Step 1: Remove the `review-visit-file` forward declaration**

Find this line in `review.el`:
```elisp
(declare-function review-visit-file "review")
```
Delete it. (Leave the other three `declare-function` lines for now.)

- [ ] **Step 2: Add path-column helpers and `review-visit-file`**

Insert before the `(provide 'review)` line:

```elisp
;; --- Line-level helpers ---

(defconst review--path-column 10
  "Column at which the file path begins on each file line.
Matches the 10-char prefix produced by `review--format-line':
2 indent + 3 status chars + 2 separators + 3 trailing spaces.")

(defun review--line-file ()
  "Return the `review-file' text property at the path column of the current line,
or nil if not on a file line."
  (let ((col-pos (+ (line-beginning-position) review--path-column)))
    (and (<= col-pos (line-end-position))
         (get-text-property col-pos 'review-file))))

;; --- RET handler ---

(defun review-visit-file ()
  "Open the file at point via `magit-diff-review-open' against the main branch.
If the file no longer exists on disk (deleted), message and decline."
  (interactive)
  (let ((relpath (review--line-file)))
    (cond
     ((null relpath)
      (message "No file at point"))
     (t
      (let* ((root (or review--root
                       (user-error "review: buffer has no root")))
             (main (or review--main-branch
                       (user-error "review: buffer has no main-branch")))
             (abs  (expand-file-name relpath root)))
        (if (not (file-exists-p abs))
            (message "review: %s is deleted — use magit-status to view the deletion"
                     relpath)
          (let ((default-directory root))
            (magit-diff-review-open relpath main))))))))
```

- [ ] **Step 3: Verify byte-compile**

Run: `emacs --batch -L /home/tsimon/dotfiles/nix/tsimon-modules/emacs/ -f batch-byte-compile /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el 2>&1 | grep -i error || echo OK`

Expected: `OK`. (Some warnings about the remaining undefined `review-next-file`, `review-prev-file`, `review-refresh` are fine.)

Cleanup: `rm /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.elc`

- [ ] **Step 4: Verify "no file at point" path in batch**

Run:
```bash
emacs --batch -l /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el \
  --eval '(with-temp-buffer (review-mode) (review-visit-file))'
```

Expected stderr: `No file at point`.

- [ ] **Step 5: Commit**

```bash
cd /home/tsimon/dotfiles
git add nix/tsimon-modules/emacs/review.el
git commit -m "Add review-visit-file with deleted-file handling"
```

---

## Task 7: Navigation and refresh — `review-next-file`, `review-prev-file`, `review-refresh`

**Files:**
- Modify: `/home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el` — append before `(provide 'review)`

**Prerequisite:** Remove the three remaining `declare-function` lines from Task 5.

- [ ] **Step 1: Remove the remaining forward declarations**

Delete these three lines from `review.el`:
```elisp
(declare-function review-next-file "review")
(declare-function review-prev-file "review")
(declare-function review-refresh "review")
```

- [ ] **Step 2: Add navigation and refresh commands**

Insert before the `(provide 'review)` line:

```elisp
;; --- Navigation and refresh ---

(defun review--goto-file-line-direction (direction)
  "Move point to the next file line in DIRECTION (+1 or -1)."
  (let ((start (point))
        (found nil))
    (forward-line direction)
    (while (and (not found)
                (not (if (> direction 0) (eobp) (bobp))))
      (if (review--line-file)
          (setq found t)
        (forward-line direction)))
    ;; bobp may have fired before line 1 was tested; check the current line.
    (when (and (not found) (review--line-file))
      (setq found t))
    (if found
        (goto-char (+ (line-beginning-position) review--path-column))
      (goto-char start)
      (message "No more files"))))

(defun review-next-file ()
  "Move point to the next file line."
  (interactive)
  (review--goto-file-line-direction 1))

(defun review-prev-file ()
  "Move point to the previous file line."
  (interactive)
  (review--goto-file-line-direction -1))

(defun review-refresh ()
  "Rebuild the review buffer in place.  Tries to preserve point on the same file."
  (interactive)
  (unless (derived-mode-p 'review-mode)
    (user-error "Not in a review buffer"))
  (let* ((current-file (review--line-file))
         (root review--root)
         (scope review--scope))
    (unless root (user-error "review-refresh: buffer has no root"))
    (review--build-buffer root scope)
    (when current-file
      (goto-char (point-min))
      (while (and (not (eobp))
                  (not (equal current-file (review--line-file))))
        (forward-line 1))
      (if (eobp)
          (goto-char (point-min))
        (goto-char (+ (line-beginning-position) review--path-column))))))
```

- [ ] **Step 3: Verify byte-compile is clean (no remaining warnings about undefined symbols)**

Run: `emacs --batch -L /home/tsimon/dotfiles/nix/tsimon-modules/emacs/ -f batch-byte-compile /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el 2>&1`

Expected: No `Error:` lines. Warnings about `magit-diff-review-open` are OK (it's only loaded when the user actually has the file).

Cleanup: `rm /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.elc`

- [ ] **Step 4: Commit**

```bash
cd /home/tsimon/dotfiles
git add nix/tsimon-modules/emacs/review.el
git commit -m "Add navigation (n/p) and refresh (g) commands"
```

---

## Task 8: Entry points — `review` and `review-current`

**Files:**
- Modify: `/home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el` — append before `(provide 'review)`

- [ ] **Step 1: Add `review--bitmask-for-file` helper**

Insert before the `(provide 'review)` line. (This lets `review-current` decide whether to open the file normally.)

```elisp
;; --- Entry points ---

(defun review--bitmask-for-file (root relpath main-branch)
  "Compute the state bitmask for the single file RELPATH under ROOT.
Calls `review--collect-files' scoped to that exact path."
  (or (cdr (assoc relpath
                  (review--collect-files root relpath main-branch)))
      0))
```

- [ ] **Step 2: Add `review` command**

Insert immediately after the previous block:

```elisp
(defun review ()
  "Open a review buffer rooted at the current repo's git toplevel."
  (interactive)
  (let ((root (or (magit-toplevel)
                  (user-error "review: not inside a git repository"))))
    (let ((buf (get-buffer-create
                (format "*review: %s*" (abbreviate-file-name root)))))
      (with-current-buffer buf
        (review--build-buffer root nil))
      (pop-to-buffer buf))))
```

- [ ] **Step 3: Add `review-current` command**

Insert immediately after the `review` block:

```elisp
(defun review-current ()
  "Review the current directory's changes, or the current file's diff.

If the current buffer visits a file:
  - if the file has changes vs main/index/working-tree, open it in
    `magit-diff-review-mode' directly;
  - if the file has no changes, fall back to `find-file' (open normally).
Otherwise, open a review buffer scoped to `default-directory'."
  (interactive)
  (let ((file (buffer-file-name)))
    (cond
     (file
      (let* ((default-directory (file-name-directory file))
             (root (or (magit-toplevel)
                       (user-error "review-current: file not in a git repository")))
             (main (review--detect-main-branch))
             (relpath (file-relative-name file root))
             (bits (review--bitmask-for-file root relpath main)))
        (if (zerop bits)
            (progn
              (message "review-current: no changes — opening normally")
              (find-file file))
          (let ((default-directory root))
            (magit-diff-review-open relpath main)))))
     (t
      (let* ((root (or (magit-toplevel)
                       (user-error "review-current: not in a git repository")))
             (scope (file-relative-name default-directory root))
             (buf (get-buffer-create
                   (format "*review: %s*" (abbreviate-file-name default-directory)))))
        (with-current-buffer buf
          (review--build-buffer root scope))
        (pop-to-buffer buf))))))
```

- [ ] **Step 4: Final byte-compile check**

Run: `emacs --batch -L /home/tsimon/dotfiles/nix/tsimon-modules/emacs/ -f batch-byte-compile /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el 2>&1 | grep -i error || echo OK`

Expected: `OK`.

Cleanup: `rm /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.elc`

- [ ] **Step 5: Manual GUI smoke test against the fixture**

In a running GUI Emacs:
1. `M-x load-file RET /home/tsimon/dotfiles/nix/tsimon-modules/emacs/review.el RET`
2. `M-x dired RET /tmp/review-fixture/ RET`
3. `M-x review RET`

Expected: a `*review: ~/...fixture/*` buffer opens, header line reads approximately `review: /tmp/review-fixture/  (vs main)`, and contains **9 file lines**:

| Path                       | Status cols | Face / color                |
|----------------------------|-------------|-----------------------------|
| `new-untracked.txt`        | `  U  `     | yellow (unstaged)           |
| `spaced name.txt`          | `  U  `     | yellow (unstaged)           |
| `sub/in-sub.txt`           | `  U  `     | yellow (unstaged)           |
| `to-commit-modify.txt`     | `    C`     | red (committed)             |
| `to-delete-unstaged.txt`   | `  U  `     | yellow (unstaged)           |
| `to-mixed-modify.txt`      | `S U  `     | red (mixed, S+U)            |
| `to-stage-modify.txt`      | `S    `     | orange (staged)             |
| `to-staged-commit.txt`     | `S   C`     | red (mixed, S+C)            |
| `to-unstage-modify.txt`    | `  U  `     | yellow (unstaged)           |

(Status-column spacing in the table above is illustrative — actual columns are exactly 5 chars wide, format `S U C` with `S`/`U`/`C` replaced by space when absent.)

Then:
- Press `n` and `p` — point moves between file lines.
- Press `RET` on `to-stage-modify.txt` — a `*diff-review: to-stage-modify.txt*` buffer opens.
- Quit that buffer (`q`), back in the review buffer, press `RET` on `to-delete-unstaged.txt` — message in echo area: `review: to-delete-unstaged.txt is deleted — use magit-status to view the deletion`.
- Press `g` — buffer redisplays, point stays on the same file line if possible.

If any of those fail, fix the issue in `review.el` before committing.

- [ ] **Step 6: Commit**

```bash
cd /home/tsimon/dotfiles
git add nix/tsimon-modules/emacs/review.el
git commit -m "Add review and review-current entry points"
```

---

## Task 9: Wire into Nix and verify end-to-end

**Files:**
- Modify: `/home/tsimon/dotfiles/nix/tsimon-modules/emacs/dev.el`
- Modify: `/home/tsimon/dotfiles/nix/tsimon-modules/emacs.nix`

- [ ] **Step 1: Add the load line to `dev.el`**

In `/home/tsimon/dotfiles/nix/tsimon-modules/emacs/dev.el`, find the existing line:
```elisp
;; custom magit diff review mode
(load "/home/tsimon/.emacs.d/config/magit-diff-review.el")
```

Add immediately after it:
```elisp

;; review mode (M-x review / M-x review-current)
(load "/home/tsimon/.emacs.d/config/review.el")
```

- [ ] **Step 2: Add the file-install entry to `emacs.nix`**

In `/home/tsimon/dotfiles/nix/tsimon-modules/emacs.nix`, find the existing block:
```nix
    file.".emacs.d/config/magit-diff-review.el" = {
      source = ./emacs/magit-diff-review.el;
    };
```

Add immediately after it (still inside the `home = { file = { ... } }` block):
```nix
    file.".emacs.d/config/review.el" = {
      source = ./emacs/review.el;
    };
```

- [ ] **Step 3: Rebuild NixOS**

Run: `cd /home/tsimon/dotfiles && nrs`

(The `nrs` alias runs `sudo nixos-rebuild switch --flake /home/tsimon/dotfiles/nix`. It will prompt for a sudo password.)

Expected: rebuild succeeds (`activating the configuration...` followed by a normal prompt).

If it fails with a permission/sudo error, ask the user to run `nrs` themselves in a terminal.

- [ ] **Step 4: End-to-end manual verification**

Restart Emacs (or start a fresh one). Then **without** explicitly loading any file:

1. `M-x review RET` from within `/home/tsimon/dotfiles/` — opens a review buffer of the dotfiles repo. Since the dotfiles repo's master is up-to-date and there are no working changes, expect the buffer to show `  (no changes)`. (If there ARE changes, verify they render with correct faces and status columns.)
2. `M-x dired RET /tmp/review-fixture/ RET`, then `M-x review RET` — same as Task 8 Step 5 verification, but loaded from Nix-installed location rather than manual `load-file`.
3. Open a file: `C-x C-f /tmp/review-fixture/to-stage-modify.txt RET`. Then `M-x review-current RET` — opens `*diff-review: to-stage-modify.txt*` directly.
4. Open a file with no changes: `C-x C-f /tmp/review-fixture/base.txt RET`. Then `M-x review-current RET` — echo area says `review-current: no changes — opening normally`, and the buffer for `base.txt` becomes current.

- [ ] **Step 5: Commit**

```bash
cd /home/tsimon/dotfiles
git add nix/tsimon-modules/emacs/dev.el nix/tsimon-modules/emacs.nix
git commit -m "Wire review.el into emacs configuration"
```

- [ ] **Step 6: Clean up the fixture**

Run: `rm -rf /tmp/review-fixture /tmp/review-fixture.sh`

(Not strictly necessary, but tidies up.)

---

## Done

After Task 9, `M-x review` and `M-x review-current` are available in any Emacs session.
