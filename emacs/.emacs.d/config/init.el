;;;
;; Packages
;;;;

;; Define package repositories
(require 'package)

;; Load and activate emacs packages. Do this first so that the
;; packages are loaded before you start trying to modify them.
;; This also sets the load path.
(package-initialize)

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)


(when (not (package-installed-p 'use-package))
  (package-refresh-contents)
  (package-install 'use-package))


;; Initialise use-package
(require 'use-package)

(load "/home/tsimon/.emacs.d/config/general.el")
(load "/home/tsimon/.emacs.d/config/helm.el")
;; (load "/home/tsimon/.emacs.d/config/casual.el")
(load "/home/tsimon/.emacs.d/config/orgmode.el")
(load "/home/tsimon/.emacs.d/config/dev.el")
(load "/home/tsimon/.emacs.d/config/tsimon-theme.el")
(load "/home/tsimon/.emacs.d/config/themes.el")g
(load "/home/tsimon/.emacs.d/config/misc.el")

(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell (replace-regexp-in-string
                          "[ \t\n]*$"
                          ""
                          (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq eshell-path-env path-from-shell) ; for eshell users
    (setq exec-path (split-string path-from-shell path-separator))))

(when window-system (set-exec-path-from-shell-PATH))


