;; cider
(defvar my-packages '(cider ac-cider clj-refactor
							cljr-helm clojure-mode clojure-mode-extra-font-locking
							paredit paren-completer rainbow-delimiters))

(dolist (p my-packages)
  (unless (package-installed-p p)
    (package-install p)))
