
;; ensure themes exist
(use-package bliss-theme
  :ensure t)

;; different themes for X and terminal
(if (display-graphic-p)
	(progn
	  ;; X Window
	  (load-theme 'dark-blue2 t t)
	  (enable-theme 'dark-blue2)
	  (custom-set-faces
	   ;; custom faces set after applying theme
	   '(mode-line ((t (:background "#3c5473" :foreground "lightgray" :box (:line-width -1 :style released-button)))))
	   '(mode-line-buffer-id ((t (:background "#3C5473" :foreground "gainsboro" :slant normal :weight normal :width normal :family "Operator Mono SSm"))))
	   '(mode-line-inactive ((t (:background "#344B63" :foreground "#9ca19e" :weight light))))))

  ;; -nw
  (load-theme 'bliss))


;; Set default font
(set-face-attribute 'default nil
                    :family "Operator Mono SSm"
                    :height 98
                    :weight 'normal
                    :width 'normal)
