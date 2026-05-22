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

;; --- Rendering ---

(defun review--face-for-bitmask (bits)
  "Return the face symbol matching state BITS (1=S, 2=U, 4=C)."
  (pcase bits
    (1 'review-staged-face)
    (2 'review-unstaged-face)
    (4 'review-committed-face)
    (_ 'review-mixed-face)))

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

(provide 'review)
;;; review.el ends here
