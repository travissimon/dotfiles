;; Casual

(use-package casual
  :ensure t)

(use-package casual-suite
  :ensure t)


;; Open casual with "C-c m"
(keymap-global-set "C-c m" #'casual-editkit-main-tmenu)


;; Org agenda
(keymap-set org-agenda-mode-map "C-c m" #'casual-agenda-tmenu)

;; optional key bindings to make it consistent between casual and org agenda
(keymap-set org-agenda-mode-map "M-j" #'org-agenda-clock-goto) ; optional
(keymap-set org-agenda-mode-map "J" #'bookmark-jump) ; optional


;; bookmarks
(keymap-set bookmark-bmenu-mode-map "C-c m" #'casual-bookmarks-tmenu)
(keymap-set bookmark-bmenu-mode-map "J" #'bookmark-jump)

(require 'hl-line)
(add-hook 'bookmark-bmenu-mode-hook #'hl-line-mode)


;; calc
(keymap-set calc-mode-map "C-c m" #'casual-calc-tmenu)
(keymap-set calc-alg-map "C-c m" #'casual-calc-tmenu)


;; calendar
(keymap-set calendar-mode-map "C-o" #'casual-calendar)


;; dired
(keymap-set dired-mode-map "C-o" #'casual-dired-tmenu)
(keymap-set dired-mode-map "s" #'casual-dired-sort-by-tmenu) ; optional
(keymap-set dired-mode-map "/" #'casual-dired-search-replace-tmenu) ; optional

;; ibuffer
(keymap-set ibuffer-mode-map "C-o" #'casual-ibuffer-tmenu)
(keymap-set ibuffer-mode-map "F" #'casual-ibuffer-filter-tmenu)
(keymap-set ibuffer-mode-map "s" #'casual-ibuffer-sortby-tmenu)

(keymap-set ibuffer-mode-map "{" #'ibuffer-backwards-next-marked)
(keymap-set ibuffer-mode-map "}" #'ibuffer-forward-next-marked)
(keymap-set ibuffer-mode-map "[" #'ibuffer-backward-filter-group)
(keymap-set ibuffer-mode-map "]" #'ibuffer-forward-filter-group)
(keymap-set ibuffer-mode-map "$" #'ibuffer-toggle-filter-group)


(require 'hl-line)
(require 'mouse)
(add-hook 'ibuffer-mode-hook #'hl-line-mode)
(add-hook 'ibuffer-mode-hook #'ibuffer-auto-mode)
(keymap-set ibuffer-mode-map "<double-mouse-1>" #'ibuffer-visit-buffer)
(keymap-set ibuffer-mode-map "M-<double-mouse-1>" #'ibuffer-visit-buffer-other-window)


;; info
(keymap-set Info-mode-map "C-o" #'casual-info-tmenu)

;; Use web-browser history navigation bindings
(keymap-set Info-mode-map "M-[" #'Info-history-back)
(keymap-set Info-mode-map "M-]" #'Info-history-forward)
;; Bind p and n to paragraph navigation
(keymap-set Info-mode-map "p" #'casual-info-browse-backward-paragraph)
(keymap-set Info-mode-map "n" #'casual-info-browse-forward-paragraph)
;; Bind h and l to navigate to previous and next nodes
;; Bind j and k to navigate to next and previous references
(keymap-set Info-mode-map "h" #'Info-prev)
(keymap-set Info-mode-map "j" #'Info-next-reference)
(keymap-set Info-mode-map "k" #'Info-prev-reference)
(keymap-set Info-mode-map "l" #'Info-next)
;; Bind / to search
(keymap-set Info-mode-map "/" #'Info-search)
;; Set Bookmark
(keymap-set Info-mode-map "B" #'bookmark-set)

(add-hook 'Info-mode-hook #'hl-line-mode)
(add-hook 'Info-mode-hook #'scroll-lock-mode)


;; isearch
(keymap-set isearch-mode-map "C-o" #'casual-isearch-tmenu)
