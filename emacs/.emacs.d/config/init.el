;;;
;; Packages
;;;;

;; Define package repositories
(require 'package)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)

;; Load and activate emacs packages. Do this first so that the
;; packages are loaded before you start trying to modify them.
;; This also sets the load path.
(package-initialize)

(load "/home/tsimon/.emacs.d/config/general.el")
(load "/home/tsimon/.emacs.d/config/themes.el")
(load "/home/tsimon/.emacs.d/config/helm.el")
(load "/home/tsimon/.emacs.d/config/dev.el")
(load "/home/tsimon/.emacs.d/config/dev-html.el")
(load "/home/tsimon/.emacs.d/config/dev-js.el")
(load "/home/tsimon/.emacs.d/config/dev-typescript.el")
(load "/home/tsimon/.emacs.d/config/dev-clojure.el")
(load "/home/tsimon/.emacs.d/config/dev-go.el")

(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell (replace-regexp-in-string
                          "[ \t\n]*$"
                          ""
                          (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq eshell-path-env path-from-shell) ; for eshell users
    (setq exec-path (split-string path-from-shell path-separator))))

(when window-system (set-exec-path-from-shell-PATH))
