;;; magit-diff-review.el --- Custom major mode for reviewing magit diffs -*- lexical-binding: t; -*-

;;; Commentary:
;; A read-only major mode that shows full-file diffs with colored formatting.
;; Invoked when pressing RET on a changed file in magit status.
;;
;; Keys:
;;   M-n       - Jump to next diff hunk
;;   M-p       - Jump to previous diff hunk
;;   TAB       - Toggle between diff view and syntax-highlighted view
;;   Any other - Warn read-only, offer to edit the on-disk file

;;; Code:

(require 'magit)
(require 'diff-mode)

;; --- Faces ---

(defface magit-diff-review-added
  '((t :foreground "#22863a"
       :background "#e6ffec"
       :extend t))
  "Face for added lines in diff review."
  :group 'magit-diff-review)

(defface magit-diff-review-removed
  '((t :foreground "#cb2431"
       :background "#ffeef0"
       :extend t))
  "Face for removed lines in diff review."
  :group 'magit-diff-review)

;; --- Buffer-local variables ---

(defvar-local magit-diff-review--file nil
  "The on-disk file path being reviewed.")

(defvar-local magit-diff-review--diff-text nil
  "The formatted diff text for this buffer.")

(defvar-local magit-diff-review--normal-text nil
  "The syntax-highlighted normal text for this buffer.")

(defvar-local magit-diff-review--showing-diff t
  "Non-nil when showing the diff view, nil when showing normal view.")

(defvar-local magit-diff-review--revision nil
  "The revision being compared against (usually HEAD~1 or index).")

;; --- Keymap ---

(defvar magit-diff-review-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "M-n") #'magit-diff-review-next-hunk)
    (define-key map (kbd "M-p") #'magit-diff-review-prev-hunk)
    (define-key map (kbd "<tab>") #'magit-diff-review-toggle-view)
    (define-key map (kbd "TAB") #'magit-diff-review-toggle-view)
    (define-key map (kbd "q") #'quit-window)
    map)
  "Keymap for `magit-diff-review-mode'.")

;; --- Major mode ---

(define-derived-mode magit-diff-review-mode special-mode "DiffReview"
  "Major mode for reviewing magit diffs with full file context.

\\{magit-diff-review-mode-map}"
  (setq buffer-read-only t)
  (setq truncate-lines t)
  ;; Intercept self-insert keys to warn about read-only
  (add-hook 'post-command-hook #'magit-diff-review--check-edit nil t))

(defun magit-diff-review--check-edit ()
  "After any command, if it was a self-insert attempt, offer to edit the file."
  (when (and (eq this-command 'self-insert-command)
             magit-diff-review--file)
    (when (yes-or-no-p
           (format "Buffer is read-only. Edit %s on disk? "
                   (abbreviate-file-name magit-diff-review--file)))
      (find-file magit-diff-review--file))))

;; Override the default undefined-key behavior for non-bound keys
(defun magit-diff-review--handle-undefined ()
  "Handle undefined keys by offering to edit the file."
  (interactive)
  (if magit-diff-review--file
      (when (yes-or-no-p
             (format "Buffer is read-only. Edit %s on disk? "
                     (abbreviate-file-name magit-diff-review--file)))
        (find-file magit-diff-review--file))
    (message "Buffer is read-only")))

;; Bind all printable characters to the handler
(let ((map magit-diff-review-mode-map))
  (dolist (key '("a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m"
                 "n" "o" "p" "r" "s" "t" "u" "v" "w" "x" "y" "z"
                 "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M"
                 "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z"
                 "0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
                 " " "!" "@" "#" "$" "%" "^" "&" "*" "(" ")"
                 "-" "_" "=" "+" "[" "]" "{" "}" "\\" "|"
                 ";" ":" "'" "\"" "," "." "<" ">" "/" "?" "`" "~"
                 "RET" "<return>"))
    (define-key map (kbd key) #'magit-diff-review--handle-undefined)))

;; --- Navigation ---

(defun magit-diff-review-next-hunk ()
  "Jump to the next diff hunk in the buffer."
  (interactive)
  (if (not magit-diff-review--showing-diff)
      (message "Switch to diff view first (TAB)")
    (let ((pos (next-single-property-change (point) 'magit-diff-review-hunk)))
      (if pos
          (progn
            (goto-char pos)
            ;; If we landed between hunks, find the next one
            (unless (get-text-property (point) 'magit-diff-review-hunk)
              (let ((next (next-single-property-change (point) 'magit-diff-review-hunk)))
                (when next (goto-char next)))))
        (message "No more hunks")))))

(defun magit-diff-review-prev-hunk ()
  "Jump to the previous diff hunk in the buffer."
  (interactive)
  (if (not magit-diff-review--showing-diff)
      (message "Switch to diff view first (TAB)")
    (let ((pos (previous-single-property-change (point) 'magit-diff-review-hunk)))
      (if pos
          (progn
            (goto-char pos)
            ;; Move to start of this hunk
            (when (get-text-property (point) 'magit-diff-review-hunk)
              (let ((start (previous-single-property-change (point) 'magit-diff-review-hunk)))
                (when start (goto-char start))))
            ;; If not on a hunk, find the previous one
            (unless (get-text-property (point) 'magit-diff-review-hunk)
              (let ((prev (previous-single-property-change (point) 'magit-diff-review-hunk)))
                (when prev (goto-char prev)))))
        (message "No previous hunks")))))

;; --- Toggle view ---

(defun magit-diff-review-toggle-view ()
  "Toggle between the diff view and syntax-highlighted normal view."
  (interactive)
  (setq magit-diff-review--showing-diff (not magit-diff-review--showing-diff))
  (let ((line (line-number-at-pos))
        (inhibit-read-only t))
    (erase-buffer)
    (if magit-diff-review--showing-diff
        (progn
          (insert magit-diff-review--diff-text)
          (message "Diff view (M-n/M-p to navigate hunks, TAB to toggle)"))
      (insert magit-diff-review--normal-text)
      (message "Normal view (TAB to toggle back to diff)"))
    (goto-char (point-min))
    (forward-line (1- line))))

;; --- Building the diff and normal views ---

(defun magit-diff-review--get-file-content (file rev)
  "Get content of FILE at revision REV. If REV is nil, get working tree version."
  (if rev
      (condition-case nil
          (magit-git-string "show" (concat rev ":" file))
        (error ""))
    (condition-case nil
        (with-temp-buffer
          (insert-file-contents (expand-file-name file (magit-toplevel)))
          (buffer-string))
      (error ""))))

(defun magit-diff-review--get-diff-lines (file rev)
  "Get unified diff output for FILE against REV."
  (let ((default-directory (magit-toplevel)))
    (with-temp-buffer
      (if rev
          (magit-git-insert "diff" rev "--" file)
        (magit-git-insert "diff" "HEAD" "--" file))
      (buffer-string))))

(defun magit-diff-review--parse-hunks (diff-text)
  "Parse unified diff TEXT into a list of hunks.
Each hunk is a plist with :old-start :old-count :new-start :new-count :lines."
  (let ((hunks nil)
        (lines (split-string diff-text "\n")))
    (while lines
      (let ((line (car lines)))
        (when (string-match "^@@ -\\([0-9]+\\),?\\([0-9]*\\) \\+\\([0-9]+\\),?\\([0-9]*\\) @@"
                            line)
          (let ((old-start (string-to-number (match-string 1 line)))
                (old-count (if (string= (match-string 2 line) "")
                               1
                             (string-to-number (match-string 2 line))))
                (new-start (string-to-number (match-string 3 line)))
                (new-count (if (string= (match-string 4 line) "")
                               1
                             (string-to-number (match-string 4 line))))
                (hunk-lines nil))
            ;; Collect lines belonging to this hunk
            (setq lines (cdr lines))
            (while (and lines
                        (let ((l (car lines)))
                          (and (> (length l) 0)
                               (memq (aref l 0) '(?+ ?- ?\s)))))
              (push (car lines) hunk-lines)
              (setq lines (cdr lines)))
            (push (list :old-start old-start :old-count old-count
                        :new-start new-start :new-count new-count
                        :lines (nreverse hunk-lines))
                  hunks)
            ;; Don't advance lines again since the while above already did
            (setq lines (cons "" lines)))))
      (setq lines (cdr lines)))
    (nreverse hunks)))

(defun magit-diff-review--build-diff-view (file rev)
  "Build the formatted diff view string for FILE compared to REV.
Shows the full new file content with diff markers on changed lines."
  (let* ((new-content (magit-diff-review--get-file-content file nil))
         (new-lines (split-string new-content "\n"))
         (diff-output (magit-diff-review--get-diff-lines file rev))
         (hunks (magit-diff-review--parse-hunks diff-output))
         (result (list))
         (new-idx 1)  ; 1-based line index into new file
         (hunk-id 0))
    ;; For each hunk, we need to figure out what to output
    (dolist (hunk hunks)
      (let ((new-start (plist-get hunk :new-start))
            (hunk-lines (plist-get hunk :lines)))
        (setq hunk-id (1+ hunk-id))
        ;; Output unchanged lines before this hunk
        (while (< new-idx new-start)
          (let ((line (nth (1- new-idx) new-lines)))
            (push (propertize (concat "  " (or line "") "\n")
                              'magit-diff-review-hunk nil)
                  result))
          (setq new-idx (1+ new-idx)))
        ;; Output hunk lines
        (dolist (hline hunk-lines)
          (cond
           ((string-prefix-p "+" hline)
            (push (propertize (concat hline "\n")
                              'font-lock-face 'magit-diff-review-added
                              'face 'magit-diff-review-added
                              'magit-diff-review-hunk hunk-id)
                  result)
            (setq new-idx (1+ new-idx)))
           ((string-prefix-p "-" hline)
            (push (propertize (concat hline "\n")
                              'font-lock-face 'magit-diff-review-removed
                              'face 'magit-diff-review-removed
                              'magit-diff-review-hunk hunk-id)
                  result))
           (t
            ;; Context line (starts with space)
            (push (propertize (concat hline "\n")
                              'magit-diff-review-hunk nil)
                  result)
            (setq new-idx (1+ new-idx)))))))
    ;; Output remaining lines after the last hunk
    (while (<= new-idx (length new-lines))
      (let ((line (nth (1- new-idx) new-lines)))
        (push (propertize (concat "  " (or line "") "\n")
                          'magit-diff-review-hunk nil)
              result))
      (setq new-idx (1+ new-idx)))
    (apply #'concat (nreverse result))))

(defun magit-diff-review--build-normal-view (file)
  "Build syntax-highlighted view of FILE."
  (let ((filepath (expand-file-name file (magit-toplevel))))
    (with-temp-buffer
      (insert-file-contents filepath)
      ;; Use the file's major mode for syntax highlighting
      (let ((buffer-file-name filepath))
        (delay-mode-hooks
          (set-auto-mode))
        (font-lock-ensure))
      (buffer-string))))

;; --- Entry point ---

(defun magit-diff-review-open (file rev)
  "Open FILE in diff review mode, comparing against REV."
  (let* ((toplevel (magit-toplevel))
         (filepath (expand-file-name file toplevel))
         (buf-name (format "*diff-review: %s*" (file-name-nondirectory file)))
         (buf (get-buffer-create buf-name)))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (erase-buffer)
        (setq magit-diff-review--file filepath)
        (setq magit-diff-review--revision rev)
        (setq magit-diff-review--showing-diff t)
        ;; Build both views
        (setq magit-diff-review--diff-text
              (magit-diff-review--build-diff-view file rev))
        (setq magit-diff-review--normal-text
              (magit-diff-review--build-normal-view file))
        ;; Show diff view
        (insert magit-diff-review--diff-text)
        (goto-char (point-min))
        (magit-diff-review-mode)
        (message "Diff review: M-n/M-p navigate hunks, TAB toggle view, q quit")))
    (pop-to-buffer buf)))

;; --- Magit integration ---

(defun magit-diff-review--get-rev-for-section ()
  "Determine the appropriate revision to diff against for the current magit section."
  (let ((section (magit-current-section)))
    (cond
     ;; Staged changes: compare against HEAD
     ((magit-section-match 'staged)
      "HEAD")
     ;; Unstaged changes: compare against index (staged version)
     ((magit-section-match 'unstaged)
      nil)
     ;; Default: compare against HEAD
     (t "HEAD"))))

(defun magit-diff-review-visit-file (&rest _args)
  "Replacement for `magit-diff-visit-file' that opens diff review mode."
  (interactive)
  (let* ((section (magit-current-section))
         (file (magit-file-at-point))
         (rev (magit-diff-review--get-rev-for-section)))
    (if file
        (magit-diff-review-open file rev)
      ;; Fall back to default behavior if we can't determine the file
      (call-interactively #'magit-diff-visit-file--original))))

;; Store original function and install advice
(unless (fboundp 'magit-diff-visit-file--original)
  (defalias 'magit-diff-visit-file--original
    (symbol-function 'magit-diff-visit-file)))

(advice-add 'magit-diff-visit-file :override #'magit-diff-review-visit-file)

(provide 'magit-diff-review)
;;; magit-diff-review.el ends here
