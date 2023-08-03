;; cider

(dolist (p my-packages)
  (unless (package-installed-p p)
    (package-install p)))
