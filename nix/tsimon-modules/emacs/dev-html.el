;; HTML development

(add-to-list 'auto-mode-alist '("\\.html" . html-mode))

;; C-c b to beautify

(eval-after-load 'json-mode
  '(define-key json-mode-map (kbd "C-c b") 'web-beautify-js))
(eval-after-load 'sgml-mode
  '(define-key html-mode-map (kbd "C-c b") 'web-beautify-html))
(eval-after-load 'css-mode
  '(define-key css-mode-map (kbd "C-c b") 'web-beautify-css))

(eval-after-load 'js2-mode
  '(add-hook 'js2-mode-hook
    (lambda ()
      (add-hook 'before-save-hook 'web-beautify-js-buffer t t))))

(eval-after-load 'json-mode
  '(add-hook 'json-mode-hook
    (lambda ()
      (add-hook 'before-save-hook 'web-beautify-js-buffer t t))))


(eval-after-load 'css-mode
  '(add-hook 'css-mode-hook
    (lambda ()
      (add-hook 'before-save-hook 'web-beautify-css-buffer t t))))

;; Oh yeah, and TABS for html
(add-hook 'html-mode-hook
  (lambda()
    (setq sgml-basic-offset 4)
    (setq indent-tabs-mode t)))



(add-hook 'js2-ts-mode-hook (lambda ()
	(subword-mode +1)
	(setopt display-fill-column-indicator-column 100)
	(display-fill-column-indicator-mode)))

(add-hook 'css-ts-mode-hook (lambda ()
	(subword-mode +1)
	(setopt display-fill-column-indicator-column 80)
	(display-fill-column-indicator-mode)))

(add-hook 'html-ts-mode-hook (lambda ()
	(subword-mode +1)
	(setopt display-fill-column-indicator-column 100)
	(display-fill-column-indicator-mode)))

(add-hook 'json-ts-mode-hook (lambda ()
	(subword-mode +1)
	(setopt display-fill-column-indicator-column 80)
	(display-fill-column-indicator-mode)))
