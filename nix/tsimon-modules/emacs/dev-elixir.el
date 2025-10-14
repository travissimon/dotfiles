;; Elixir

(add-to-list 'auto-mode-alist '("\\.ex\\'" . elixir-mode))
(add-hook 'elixir-mode-hook 'subword-mode)
(add-hook 'elixir-mode-hook #'display-fill-column-indicator-mode)
