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

(provide 'review)
;;; review.el ends here
