;; miscellaneous functions

(defun unfill-paragraph (&optional region)
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max))
    ;; This would override `fill-column' if it's an integer.
    (emacs-lisp-docstring-fill-column t))
    (fill-paragraph nil region)))


(defun open-as-text ()
  "Open the current buffer's file in GNOME Text Editor.
  If the buffer has unsaved changes, prompt to save first."
  (interactive)
  (when (and (buffer-modified-p)
             (y-or-n-p "Buffer has unsaved changes. Save first? "))
    (save-buffer))
  (if buffer-file-name
      (start-process "gnome-text-editor" nil "gnome-text-editor" buffer-file-name)
    (error "Buffer is not visiting a file")))
