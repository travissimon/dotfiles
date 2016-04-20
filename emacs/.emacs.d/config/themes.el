
;; ensure themes exist
(unless (package-installed-p 'color-theme)
  (package-install 'color-theme))
(unless (package-installed-p 'bliss-theme)
  (package-install 'bliss-theme))

;; different themes for X and terminal
(if (display-graphic-p)
	(progn
	  ;; X Window
	  (color-theme-initialize)
	  (color-theme-dark-blue2)
	  (custom-set-faces
	   ;; custom-set-faces was added by Custom.
	   ;; If you edit it by hand, you could mess it up, so be careful.
	   ;; Your init file should contain only one such instance.
	   ;; If there is more than one, they won't work right.
	   '(dired-directory ((t (:foreground "cyan" :slant italic :weight normal))))
	   '(font-lock-builtin-face ((t (:foreground "LightSteelBlue" :weight normal))))
	   '(font-lock-constant-face ((t (:foreground "Aquamarine"))))
	   '(font-lock-doc-face ((t nil)))
	   '(font-lock-doc-string-face ((t (:foreground "aquamarine"))))
	   '(font-lock-function-name-face ((t (:foreground "LightSkyBlue" :weight normal))))
	   '(font-lock-keyword-face ((t (:foreground "Cyan" :weight normal))))
	   '(font-lock-regexp-grouping-backslash ((t (:inherit nil))))
	   '(font-lock-type-face ((t (:foreground "PaleGreen" :weight normal))))
	   '(font-lock-variable-name-face ((t (:foreground "DarkSlateGray1" :slant italic))))
	   '(font-lock-warning-face ((t (:foreground "Salmon"))))
	   '(html-helper-italic-face ((t (:foreground "yellow" :slant italic))))
	   '(html-tag-face ((t nil)))
	   '(magit-diff-file-heading ((t nil)))
	   '(magit-section-heading ((t (:foreground "LightGoldenrod2" :weight semi-bold))))
	   '(magit-section-secondary-heading ((t nil)))))
  ;; -nw
  (load-theme 'bliss))
