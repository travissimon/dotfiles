
;; ensure themes exist
(use-package bliss-theme
  :ensure t)

;; different themes for X and terminal
(if (display-graphic-p)
  (load-theme 'tsimon)
  ;; -nw
  (load-theme 'bliss))


;; Set default font
(set-face-attribute 'default nil
                    :family "Operator Mono SSm"
                    :height 98
                    :weight 'normal
                    :width 'normal)
