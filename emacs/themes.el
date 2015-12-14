
;; ensure themes exist
(unless (package-installed-p 'color-theme)
  (package-install 'color-theme))
(unless (package-installed-p 'bliss-theme)
  (package-install 'cider))

;; different themes for X and terminal
(if (display-graphic-p)
	(progn
	  ;; X Window
	  (color-theme-initialize)
	  (color-theme-dark-blue2))
  ;; -nw
  (load-theme 'bliss))
