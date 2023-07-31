;; auto-complete
(unless (package-installed-p 'ac-html)
  (package-install 'ac-html))

(unless (package-installed-p 'css-mode)
  (package-install 'css-mode))

(unless (package-installed-p 'less-css-mode)
  (package-install 'less-css-mode))



;; bootstrap ac
(unless (package-installed-p 'ac-html-bootstrap)
  (package-install 'ac-html-bootstrap))

;; web beautify
(unless (package-installed-p 'web-beautify)
  (package-install 'web-beautify))

(eval-after-load 'js2-mode
  '(define-key js2-mode-map (kbd "C-c b") 'web-beautify-js))
(eval-after-load 'json-mode
  '(define-key json-mode-map (kbd "C-c b") 'web-beautify-js))
(eval-after-load 'sgml-mode
  '(define-key html-mode-map (kbd "C-c b") 'web-beautify-html))
(eval-after-load 'css-mode
  '(define-key css-mode-map (kbd "C-c b") 'web-beautify-css))


;; automatically format before saving a file,

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
