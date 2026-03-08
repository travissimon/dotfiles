;; Elixir

(add-to-list 'auto-mode-alist '("\\.ex\\'" . elixir-mode))
(add-hook 'elixir-mode-hook #'display-fill-column-indicator-mode)


(use-package elixir-mode
  :ensure t
  :custom
  (lsp-elixir-server-command '("expert" "--stdio")))


;; (use-package lsp-mode
;;   :commands lsp
;;   :ensure t
;;   :diminish lsp-mode
;;   :hook
;;   (elixir-mode . lsp)
;;   :init
;;   (add-to-list 'exec-path "/home/tsimon/bin/elixir-ls"))
