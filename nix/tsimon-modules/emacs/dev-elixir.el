;; Elixir

(add-to-list 'auto-mode-alist '("\\.ex\\'" . elixir-mode))
(add-hook 'elixir-mode-hook #'display-fill-column-indicator-mode)

;; Alchemist
;; ?? (setq alchemist-mix-command "env mix")
