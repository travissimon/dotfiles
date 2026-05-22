;;; review.el --- Dired-like listing of git-changed files -*- lexical-binding: t; -*-

;;; Commentary:
;; Major mode showing a flat recursive listing of all files in the current
;; git repository (similar to dired, but flat and rooted at the repo).
;; Each file is annotated with any of three states it is in: staged (S),
;; unstaged or untracked (U), and committed-but-not-on-main (C).
;;
;; Entry points:
;;   M-x review          - listing rooted at the repo's git toplevel
;;   M-x review-current  - listing scoped to default-directory, OR direct
;;                         hand-off to magit-diff-review when the current
;;                         buffer visits a file
;;
;; Pressing RET on a file opens it via `magit-diff-review-open' with the
;; auto-detected main branch as the comparison revision.  C-o opens the
;; file with plain `find-file' (no diff/review wrapper).

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

(defconst review--path-column 10
  "Column at which the entry name begins on each entry line.
Matches the 10-char prefix produced by `review--format-line':
2 indent + 3 status chars + 2 separators + 3 trailing spaces.")

(defun review--collect-files (root scope main-branch)
  "Collect all files under ROOT, scoped to SCOPE relative path or nil.
MAIN-BRANCH is the branch name to compare HEAD against for committed state.
Return a list of (RELATIVE-PATH . BITMASK) sorted alphabetically.  Unchanged
files have BITMASK 0; files with changes set one or more of the bits below.

BITMASK uses `review--bit-staged' (1), `review--bit-unstaged' (2),
`review--bit-committed' (4)."
  (let* ((default-directory root)
         (pathspec-args (when (and scope
                                   (not (string-empty-p scope))
                                   (not (string= scope ".")))
                          (list "--" scope)))
         (table (make-hash-table :test 'equal)))
    (cl-labels ((mark (path bit)
                  (puthash path (logior bit (gethash path table 0)) table)))
      ;; All tracked files (seeded with bitmask 0; diff loops below add bits)
      (dolist (p (apply #'review--git-lines-z
                        (append (list "ls-files" "-z")
                                pathspec-args)))
        (mark p 0))
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

;; --- Scope and aggregation helpers ---

(defun review--normalize-scope (scope)
  "Normalize SCOPE to either \"\" (repo root) or \"sub/dir/\" (trailing slash).
Accepts nil, \"\", \".\", \"./\", or any repo-relative directory path."
  (cond
   ((null scope) "")
   ((member scope '("" "." "./")) "")
   ((string-suffix-p "/" scope) scope)
   (t (concat scope "/"))))

(defun review--parent-scope (scope)
  "Return the parent of normalized SCOPE.
\"\" stays \"\"; \"a/\" → \"\"; \"a/b/\" → \"a/\"."
  (let ((s (review--normalize-scope scope)))
    (if (string-empty-p s)
        ""
      (let* ((trimmed (substring s 0 -1))
             (slash (cl-position ?/ trimmed :from-end t)))
        (if slash
            (substring s 0 (1+ slash))
          "")))))

(defun review--aggregate-entries (entries scope)
  "Fold ENTRIES (a list of (RELPATH . BITS)) into one-level entries under SCOPE.
SCOPE must be normalized (\"\" or \"sub/dir/\").  Returns a list of plists
sorted directories-first then alphabetically:

  (:kind file :name BASENAME :bits BITS :relpath RELPATH)
  (:kind dir  :name \"NAME/\" :bits BITS :relpath \"SCOPE+NAME/\")

A directory's BITS is the bitwise-OR of all descendant files' BITS."
  (let ((prefix-len (length scope))
        (files nil)
        (dirs (make-hash-table :test 'equal)))
    (dolist (cell entries)
      (let ((relpath (car cell))
            (bits (cdr cell)))
        (when (string-prefix-p scope relpath)
          (let* ((rest (substring relpath prefix-len))
                 (slash (cl-position ?/ rest)))
            (if (null slash)
                (push (list :kind 'file
                            :name rest
                            :bits bits
                            :relpath relpath)
                      files)
              (let* ((dirname (substring rest 0 slash))
                     (existing (gethash dirname dirs 0)))
                (puthash dirname (logior existing bits) dirs)))))))
    (let (dir-entries)
      (maphash (lambda (name bits)
                 (push (list :kind 'dir
                             :name (concat name "/")
                             :bits bits
                             :relpath (concat scope name "/"))
                       dir-entries))
               dirs)
      (append
       (sort dir-entries
             (lambda (a b) (string< (plist-get a :name)
                                    (plist-get b :name))))
       (sort files
             (lambda (a b) (string< (plist-get a :name)
                                    (plist-get b :name))))))))

;; --- Rendering ---

(defun review--face-for-bitmask (bits)
  "Return the face symbol matching state BITS (0=unchanged, 1=S, 2=U, 4=C)."
  (pcase bits
    (0 'default)
    (1 'review-staged-face)
    (2 'review-unstaged-face)
    (4 'review-committed-face)
    (_ 'review-mixed-face)))

(defun review--format-line (entry)
  "Return a propertized string for ENTRY plist (:kind :name :bits :relpath).
Parent rows (:kind parent) have blank status columns."
  (let* ((kind (plist-get entry :kind))
         (name (plist-get entry :name))
         (bits (plist-get entry :bits))
         (relpath (plist-get entry :relpath))
         (s (if (or (eq kind 'parent)
                    (zerop (logand bits review--bit-staged)))    ?\s ?S))
         (u (if (or (eq kind 'parent)
                    (zerop (logand bits review--bit-unstaged)))  ?\s ?U))
         (c (if (or (eq kind 'parent)
                    (zerop (logand bits review--bit-committed))) ?\s ?C))
         (face (if (eq kind 'parent)
                   'default
                 (review--face-for-bitmask bits)))
         (prefix (format "  %c %c %c   " s u c))
         (label (propertize name
                            'face face
                            'mouse-face 'highlight
                            'review-entry (cons kind relpath))))
    (concat prefix label "\n")))

(defun review--build-buffer (root scope)
  "Populate the current buffer with a single-level review listing for ROOT, SCOPE.
SCOPE is normalized to \"\" or \"sub/dir/\".  Sets buffer-locals, switches to
`review-mode' if not already, sets `header-line-format', and renames the
buffer to reflect the current scope.  Caller must `pop-to-buffer' afterwards
(only required for the first display; descend/ascend rebuild in place)."
  (let* ((scope (review--normalize-scope scope))
         (main (review--detect-main-branch))
         (all-entries (review--collect-files root scope main))
         (entries (review--aggregate-entries all-entries scope))
         (inhibit-read-only t))
    (unless (derived-mode-p 'review-mode)
      (review-mode))
    (setq review--root root
          review--scope scope
          review--main-branch main)
    (setq header-line-format
          (format "review: %s%s  (vs %s)"
                  (abbreviate-file-name root)
                  scope
                  main))
    (rename-buffer
     (format "*review: %s*"
             (abbreviate-file-name (expand-file-name scope root)))
     'unique)
    (erase-buffer)
    (when (not (string-empty-p scope))
      (insert (review--format-line
               (list :kind 'parent
                     :name ".."
                     :bits 0
                     :relpath (review--parent-scope scope)))))
    (if (null entries)
        (insert "  (no files)\n")
      (dolist (e entries)
        (insert (review--format-line e))))
    (goto-char (point-min))
    (when (review--line-entry)
      (goto-char (+ (line-beginning-position) review--path-column)))))

;; --- Major mode ---

(defvar review-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET")     #'review-visit-file)
    (define-key map (kbd "<mouse-2>") #'review-visit-file)
    (define-key map (kbd "C-o")     #'review-find-file)
    (define-key map (kbd "n")       #'review-next-file)
    (define-key map (kbd "p")       #'review-prev-file)
    (define-key map (kbd "^")       #'review-ascend)
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

(defun review--line-entry ()
  "Return the entry cons (KIND . RELPATH) at the path column of the current line,
or nil if not on an entry line.  KIND is `file', `dir', or `parent'."
  (let ((col-pos (+ (line-beginning-position) review--path-column)))
    (and (<= col-pos (line-end-position))
         (get-text-property col-pos 'review-entry))))

;; --- RET handler ---

(defun review-visit-file ()
  "Open the entry at point.
Files: open via `magit-diff-review-open' against the main branch.
Directories: rescope the buffer into the directory.
Parent (..): rescope to the parent directory.
If a file no longer exists on disk (deleted), message and decline."
  (interactive)
  (let ((entry (review--line-entry)))
    (cond
     ((null entry)
      (message "No entry at point"))
     ((eq (car entry) 'parent)
      (review-ascend))
     ((eq (car entry) 'dir)
      (review-descend (cdr entry)))
     ((eq (car entry) 'file)
      (let* ((relpath (cdr entry))
             (root (or review--root
                       (user-error "review: buffer has no root")))
             (main (or review--main-branch
                       (user-error "review: buffer has no main-branch")))
             (abs  (expand-file-name relpath root)))
        (if (not (file-exists-p abs))
            (message "review: %s is deleted — use magit-status to view the deletion"
                     relpath)
          (let ((default-directory root))
            (magit-diff-review-open relpath main))))))))

(defun review-find-file ()
  "Open the entry at point with `find-file' (no diff/review wrapper).
File entries open with `find-file'; directory entries open in dired."
  (interactive)
  (let* ((entry (review--line-entry))
         (relpath (and entry (cdr entry))))
    (cond
     ((null relpath)
      (message "No entry at point"))
     (t
      (let* ((root (or review--root
                       (user-error "review: buffer has no root")))
             (abs  (expand-file-name relpath root)))
        (if (not (file-exists-p abs))
            (message "review: %s does not exist on disk" relpath)
          (find-file abs)))))))

;; --- Navigation and refresh ---

(defun review--goto-file-line-direction (direction)
  "Move point to the next entry line in DIRECTION (+1 or -1)."
  (let ((start (point))
        (found nil))
    (forward-line direction)
    (while (and (not found)
                (not (if (> direction 0) (eobp) (bobp))))
      (if (review--line-entry)
          (setq found t)
        (forward-line direction)))
    (when (and (not found) (review--line-entry))
      (setq found t))
    (if found
        (goto-char (+ (line-beginning-position) review--path-column))
      (goto-char start)
      (message "No more entries"))))

(defun review-next-file ()
  "Move point to the next file line."
  (interactive)
  (review--goto-file-line-direction 1))

(defun review-prev-file ()
  "Move point to the previous file line."
  (interactive)
  (review--goto-file-line-direction -1))

(defun review-refresh ()
  "Rebuild the review buffer in place.  Tries to preserve point on the same entry."
  (interactive)
  (unless (derived-mode-p 'review-mode)
    (user-error "Not in a review buffer"))
  (let* ((current-entry (review--line-entry))
         (root review--root)
         (scope review--scope))
    (unless root (user-error "review-refresh: buffer has no root"))
    (review--build-buffer root scope)
    (when current-entry
      (goto-char (point-min))
      (while (and (not (eobp))
                  (not (equal current-entry (review--line-entry))))
        (forward-line 1))
      (if (eobp)
          (goto-char (point-min))
        (goto-char (+ (line-beginning-position) review--path-column))))))

;; --- Scope navigation ---

(defun review-descend (relpath)
  "Rebuild the current review buffer scoped to RELPATH (a normalized dir path)."
  (unless (derived-mode-p 'review-mode)
    (user-error "Not in a review buffer"))
  (let ((root (or review--root
                  (user-error "review-descend: buffer has no root"))))
    (review--build-buffer root relpath)))

(defun review-ascend ()
  "Rebuild the current review buffer at the parent scope.  No-op at repo root."
  (interactive)
  (unless (derived-mode-p 'review-mode)
    (user-error "Not in a review buffer"))
  (let* ((scope (review--normalize-scope review--scope))
         (parent (review--parent-scope scope)))
    (if (and (string-empty-p scope))
        (message "review: already at repo root")
      (review--build-buffer review--root parent))))

;; --- Entry points ---

(defun review--bitmask-for-file (root relpath main-branch)
  "Compute the state bitmask for the single file RELPATH under ROOT.
Calls `review--collect-files' scoped to that exact path."
  (or (cdr (assoc relpath
                  (review--collect-files root relpath main-branch)))
      0))

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

(provide 'review)
;;; review.el ends here
