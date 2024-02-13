;; mostly taken from
;; https://zzamboni.org/post/beautifying-org-mode-in-emacs/

(setq org-hide-emphasis-markers t)

(font-lock-add-keywords 'org-mode
     '(("^ *\\([-]\\) "
     (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

(use-package org-bullets
   :ensure t
   :config
   (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))


;; Add support for JS babel
(require 'ob-js)

(add-to-list 'org-babel-load-languages '(js . t))
(org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages)
(add-to-list 'org-babel-tangle-lang-exts '("js" . "js"))

;; pdf export?
(use-package minted
   :ensure t)

(setq org-latex-listings 'minted) 
(setq org-latex-pdf-process
      '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
        "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
        "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))


;; Html export
(use-package htmlize
   :ensure t)

