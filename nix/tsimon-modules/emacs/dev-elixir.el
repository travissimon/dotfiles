;; Elixir

;; pug-mode for HAML-like express templates

(add-to-list 'auto-mode-alist '("\\.ex\\'" . elixir-ts-mode))
(add-hook 'elixir-ts-mode-hook 'subword-mode)
