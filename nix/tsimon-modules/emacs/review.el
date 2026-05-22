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
