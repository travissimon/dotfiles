
;; different themes for X and terminal
(if (display-graphic-p)
  (load-theme 'tsimon t)
  ;; -nw
  (load-theme 'tsimon-shell t))


;; Set default font
(set-face-attribute 'default nil
                    :family "Operator Mono SSm"
                    :height 100
                    :weight 'normal
                    :width 'normal)
