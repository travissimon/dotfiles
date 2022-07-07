
;; ensure themes exist
(use-package bliss-theme
  :ensure t)

;; different themes for X and terminal
(if (display-graphic-p)
  (load-theme 'tsimon t)
  ;; -nw
  (load-theme 'bliss t))


;; Set default font
(set-face-attribute 'default nil
                    :family "Operator Mono SSm"
                    :height 98
                    :weight 'normal
                    :width 'normal)
