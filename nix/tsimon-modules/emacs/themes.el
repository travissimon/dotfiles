;; Use different themes for X and terminal
(if (display-graphic-p)
  (load-theme 'tsimon t)
  ;; -nw
  (load-theme 'tsimon-shell t))


;; Set default font
(set-face-attribute 'default nil
  ;; :family "Operator Mono SSm"   ; not installed on this system
  :family "RobotoMono Nerd Font"
  :height 110
  :weight 'medium
  :width 'normal)
