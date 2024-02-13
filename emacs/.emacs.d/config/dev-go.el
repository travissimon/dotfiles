(unless (package-installed-p 'go-mode)
  (package-install 'go-mode))
(unless (package-installed-p 'exec-path-from-shell)
  (package-install 'exec-path-from-shell))
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

(require 'go-autocomplete)
(require 'auto-complete-config)
(require 'go-eldoc)
(require 'go-projectile)
(require 'golint)

(defun my-go-mode-hook ()
  (setq gofmt-command "goimports")
  (setq exec-path (cons "/usr/local/go/bin" exec-path))
  (add-to-list 'exec-path "/home/tsimon/go/bin")

  ;; Call Gofmt before saving                                                    
  (add-hook 'before-save-hook 'gofmt-before-save)

  (go-eldoc-setup)
  (local-set-key (kbd "M-.") 'godef-jump)

  ;; auto complete
  (auto-complete-mode 1)
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
           "go build -v && go test -v && go vet"))

  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)

  (global-set-key "\C-c\C-c" 'compile))

(add-hook 'go-mode-hook 'my-go-mode-hook)



;; Helm go package

(autoload 'helm-go-package "helm-go-package")
(eval-after-load 'go-mode
  '(substitute-key-definition 'go-import-add 'helm-go-package go-mode-map))
