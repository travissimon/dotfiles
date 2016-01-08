(unless (package-installed-p 'go-mode)
  (package-install 'go-mode))
(unless (package-installed-p 'go-autocomplete)
  (package-install 'go-autocomplete))
(unless (package-installed-p 'go-projectile)
  (package-install 'go-projectile))
(unless (package-installed-p 'go-rename)
  (package-install 'go-rename))
(unless (package-installed-p 'gotest)
  (package-install 'gotest))
(unless (package-installed-p 'golint)
  (package-install 'golint))
(unless (package-installed-p 'flymake-go)
  (package-install 'flymake-go))

(require 'go-autocomplete)
(define-key ac-mode-map (kbd "M-TAB") 'auto-complete)

(require 'go-eldoc)
(add-hook 'go-mode-hook 'go-eldoc-setup)

(require 'go-projectile)

(require 'golint)
