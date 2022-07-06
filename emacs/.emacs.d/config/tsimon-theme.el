;;; Based off dark-blue-2


;;; dark-blue2-theme.el --- dark-blue2 theme

;; Copyright (C) 2002 by Chris McMahan
;; Copyright (C) 2013 by Syohei YOSHIDA

;; Author: Syohei YOSHIDA <syohex@gmail.com>
;; URL: https://github.com/emacs-jp/replace-colorthemes
;; Version: 0.01

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Port of dark-blue2 theme from `color-themes'

;;; Code:

(set-face-attribute 'default nil
                    :family "Operator Mono SSm"
                    :height 98
                    :weight 'normal
                    :width 'normal)
'(mode-line ((t (:background "#3c5473" :foreground "lightgray" :box (:line-width -1 :style released-button)))))
'(mode-line-buffer-id ((t (:background "#3C5473" :foreground "gainsboro" :slant normal :weight normal :width normal :family "Operator Mono SSm"))))
'(mode-line-inactive ((t (:background "#344B63" :foreground "#9ca19e" :weight light))))


(deftheme tsimon
  "tsimon theme")

(custom-theme-set-faces
 'tsimon

 '(default ((t (:background "#233b5a" :foreground "#fff8dc"))))
 '(mouse ((t (:background "Grey"))))
 '(cursor ((t (:background "Yellow"))))
 '(border ((t (:background "black"))))

 '(cperl-invalid-face ((t (:underline t))))
 '(gnus-article-button-face ((t (:bold t :foreground "cyan" :weight bold))))
 '(gnus-article-mouse-face ((t (:background "SkyBlue3"))))
 '(help-highlight-face ((t (:underline t))))
 '(list-matching-lines-face ((t (:bold t :foreground "cyan" :weight bold))))
 '(view-highlight-face ((t (:background "SkyBlue3"))))
 '(vm-highlight-url-face ((t (:bold t :foreground "cyan" :weight bold)))-italic)
 '(vm-highlighted-header-face ((t (:bold t :foreground "cyan" :weight bold))))
 '(vm-mime-button-face ((t (:background "grey75" :foreground "gray30"))))
 '(vm-summary-highlight-face ((t (:bold t :foreground "cyan" :weight bold))))
 '(widget-mouse-face ((t (:background "SkyBlue3"))))

 '(Info-title-1-face ((t (:bold t :weight bold :height 1.728 :family "helv"))))
 '(Info-title-2-face ((t (:bold t :weight bold :height 1.44 :family "helv"))))
 '(Info-title-3-face ((t (:bold t :weight bold :height 1.2 :family "helv"))))
 '(Info-title-4-face ((t (:bold t :weight bold :family "helv"))))
 '(antlr-font-lock-keyword-face ((t (:bold t :foreground "Gray85" :weight bold))))
 '(antlr-font-lock-literal-face ((t (:bold t :foreground "Gray85" :weight bold))))
 '(antlr-font-lock-ruledef-face ((t (:bold t :foreground "Gray85" :weight bold))))
 '(antlr-font-lock-ruleref-face ((t (:foreground "Gray85"))))
 '(antlr-font-lock-tokendef-face ((t (:bold t :foreground "Gray85" :weight bold))))
 '(antlr-font-lock-tokenref-face ((t (:foreground "Gray85"))))
 '(bbdb-company ((t (:italic t :slant italic))))
 '(bbdb-field-name ((t (:bold t :weight bold))))
 '(bbdb-field-value ((t (nil))))
 '(bbdb-name ((t (:underline t))))
 '(bg:erc-color-face0 ((t (:background "White"))))
 '(bg:erc-color-face1 ((t (:background "black"))))
 '(bg:erc-color-face10 ((t (:background "lightblue1"))))
 '(bg:erc-color-face11 ((t (:background "cyan"))))
 '(bg:erc-color-face12 ((t (:background "blue"))))
 '(bg:erc-color-face13 ((t (:background "deeppink"))))
 '(bg:erc-color-face14 ((t (:background "gray50"))))
 '(bg:erc-color-face15 ((t (:background "gray90"))))
 '(bg:erc-color-face2 ((t (:background "blue4"))))
 '(bg:erc-color-face3 ((t (:background "green4"))))
 '(bg:erc-color-face4 ((t (:background "red"))))
 '(bg:erc-color-face5 ((t (:background "brown"))))
 '(bg:erc-color-face6 ((t (:background "purple"))))
 '(bg:erc-color-face7 ((t (:background "orange"))))
 '(bg:erc-color-face8 ((t (:background "yellow"))))
 '(bg:erc-color-face9 ((t (:background "green"))))
 '(blank-space-face ((t (:background "LightGray"))))
 '(blank-tab-face ((t (:background "Wheat"))))
 '(blue ((t (:foreground "blue"))))
 '(bold ((t (:bold t :foreground "cyan" :weight bold))))
 '(bold-italic ((t (:italic t :bold t :foreground "cyan2" :slant italic :weight bold))))
 '(border-glyph ((t (nil))))
 '(buffers-tab ((t (:background "gray30" :foreground "LightSkyBlue"))))
 '(calendar-today-face ((t (:underline t))))
 '(change-log-acknowledgement-face ((t (:foreground "firebrick"))))
 '(change-log-conditionals-face ((t (:background "sienna" :foreground "khaki"))))
 '(change-log-date-face ((t (:foreground "gold"))))
 '(change-log-email-face ((t (:foreground "khaki" :underline t))))
 '(change-log-file-face ((t (:bold t :foreground "lemon chiffon" :weight bold))))
 '(change-log-function-face ((t (:background "sienna" :foreground "khaki"))))
 '(change-log-list-face ((t (:foreground "wheat"))))
 '(change-log-name-face ((t (:bold t :foreground "light goldenrod" :weight bold))))
 '(comint-highlight-input ((t (:bold t :weight bold))))
 '(comint-highlight-prompt ((t (:foreground "cyan"))))
 '(comint-input-face ((t (:foreground "deepskyblue"))))
 '(custom-button-face ((t (:bold t :weight bold))))
 '(custom-button-pressed-face ((t (:background "lightgrey" :foreground "gray30"))))
 '(custom-changed-face ((t (:background "blue" :foreground "white"))))
 '(custom-comment-face ((t (:foreground "white"))))
 '(custom-comment-tag-face ((t (:foreground "white"))))
 '(custom-documentation-face ((t (:foreground "light blue"))))
 '(custom-face-tag-face ((t (:underline t))))
 '(custom-group-tag-face ((t (:bold t :foreground "gray85" :underline t :weight bold))))
 '(custom-group-tag-face-1 ((t (:foreground "gray85" :underline t))))
 '(custom-invalid-face ((t (:background "red" :foreground "yellow"))))
 '(custom-modified-face ((t (:background "blue" :foreground "white"))))
 '(custom-rogue-face ((t (:background "gray30" :foreground "pink"))))
 '(custom-saved-face ((t (:underline t))))
 '(custom-set-face ((t (:background "white" :foreground "blue"))))
 '(custom-state-face ((t (:foreground "gray85"))))
 '(custom-variable-button-face ((t (:bold t :underline t :weight bold))))
 '(custom-variable-tag-face ((t (:bold t :foreground "gray85" :underline t :weight bold))))
 '(cvs-filename-face ((t (:foreground "white"))))
 '(cvs-handled-face ((t (:foreground "pink"))))
 '(cvs-header-face ((t (:foreground "green"))))
 '(cvs-marked-face ((t (:bold t :foreground "green3" :weight bold))))
 '(cvs-msg-face ((t (:foreground "gray85"))))
 '(cvs-need-action-face ((t (:foreground "yellow"))))
 '(cvs-unknown-face ((t (:foreground "grey"))))
 '(cyan ((t (:foreground "cyan"))))
 '(diary-face ((t (:bold t :foreground "gray85" :weight bold))))
 '(diff-added-face ((t (nil))))
 '(diff-changed-face ((t (nil))))
 '(diff-context-face ((t (:foreground "grey50"))))
 '(diff-file-header-face ((t (:bold t :background "grey70" :weight bold))))
 '(diff-function-face ((t (:foreground "grey50"))))
 '(diff-header-face ((t (:foreground "lemon chiffon"))))
 '(diff-hunk-header-face ((t (:background "grey85"))))
 '(diff-index-face ((t (:bold t :background "grey70" :weight bold))))
 '(diff-nonexistent-face ((t (:bold t :background "grey70" :weight bold))))
 '(diff-removed-face ((t (nil))))
 '(dired-face-boring ((t (:foreground "Gray65"))))
 '(dired-face-directory ((t (:bold t :weight bold))))
 '(dired-face-executable ((t (:foreground "gray85"))))
 '(dired-face-flagged ((t (:background "LightSlateGray"))))
 '(dired-face-header ((t (:background "grey75" :foreground "gray30"))))
 '(dired-face-marked ((t (:background "PaleVioletRed"))))
 '(dired-face-permissions ((t (:background "grey75" :foreground "gray30"))))
 '(dired-face-setuid ((t (:foreground "gray85"))))
 '(dired-face-socket ((t (:foreground "gray85"))))
 '(dired-face-symlink ((t (:foreground "cyan"))))
 '(display-time-mail-balloon-enhance-face ((t (:background "orange"))))
 '(display-time-mail-balloon-gnus-group-face ((t (:foreground "blue"))))
 '(display-time-time-balloon-face ((t (:foreground "gray85"))))
 '(ebrowse-default-face ((t (nil))))
 '(ebrowse-file-name-face ((t (:italic t :slant italic))))
 '(ebrowse-member-attribute-face ((t (:foreground "red"))))
 '(ebrowse-member-class-face ((t (:foreground "Gray85"))))
 '(ebrowse-progress-face ((t (:background "blue"))))
 '(ebrowse-root-class-face ((t (:bold t :foreground "Gray85" :weight bold))))
 '(ebrowse-tree-mark-face ((t (:foreground "Gray85"))))
 '(ecb-bucket-token-face ((t (:bold t :weight bold))))
 '(ecb-default-general-face ((t (:height 1.0))))
 '(ecb-default-highlight-face ((t (:background "magenta" :height 1.0))))
 '(ecb-directories-general-face ((t (:height 0.9))))
 '(ecb-directory-face ((t (:background "Cyan4"))))
 '(ecb-history-face ((t (:background "Cyan4"))))
 '(ecb-history-general-face ((t (:height 0.9))))
 '(ecb-method-face ((t (:background "Cyan4" :slant normal :weight normal))))
 '(ecb-methods-general-face ((t (:slant normal))))
 '(ecb-source-face ((t (:background "Cyan4"))))
 '(ecb-source-in-directories-buffer-face ((t (:foreground "LightBlue1" :background "Cyan4"))))
 '(ecb-sources-face ((t (:foreground "LightBlue1"))))
 '(ecb-sources-general-face ((t (:height 0.9))))
 '(ecb-token-header-face ((t (:background "Steelblue4"))))
 '(ecb-type-token-class-face ((t (:bold t :weight bold))))
 '(ecb-type-token-enum-face ((t (:bold t :weight bold))))
 '(ecb-type-token-group-face ((t (:bold t :foreground "dim gray" :weight bold))))
 '(ecb-type-token-interface-face ((t (:bold t :weight bold))))
 '(ecb-type-token-struct-face ((t (:bold t :weight bold))))
 '(ecb-type-token-typedef-face ((t (:bold t :weight bold))))
 '(ediff-current-diff-face-A ((t (:background "pale green" :foreground "firebrick"))))
 '(ediff-current-diff-face-Ancestor ((t (:background "VioletRed" :foreground "Gray30"))))
 '(ediff-current-diff-face-B ((t (:background "Yellow" :foreground "DarkOrchid"))))
 '(ediff-current-diff-face-C ((t (:background "Pink" :foreground "Navy"))))
 '(ediff-even-diff-face-A ((t (:background "light grey" :foreground "Gray30"))))
 '(ediff-even-diff-face-Ancestor ((t (:background "Grey" :foreground "White"))))
 '(ediff-even-diff-face-B ((t (:background "Grey" :foreground "White"))))
 '(ediff-even-diff-face-C ((t (:background "light grey" :foreground "Gray30"))))
 '(ediff-fine-diff-face-A ((t (:background "sky blue" :foreground "Navy"))))
 '(ediff-fine-diff-face-Ancestor ((t (:background "Green" :foreground "Gray30"))))
 '(ediff-fine-diff-face-B ((t (:background "cyan" :foreground "Gray30"))))
 '(ediff-fine-diff-face-C ((t (:background "Turquoise" :foreground "Gray30"))))
 '(ediff-odd-diff-face-A ((t (:background "Grey" :foreground "White"))))
 '(ediff-odd-diff-face-Ancestor ((t (:background "light grey" :foreground "Gray30"))))
 '(ediff-odd-diff-face-B ((t (:background "light grey" :foreground "Gray30"))))
 '(ediff-odd-diff-face-C ((t (:background "Grey" :foreground "White"))))
 '(erc-action-face ((t (:bold t :weight bold))))
 '(erc-bold-face ((t (:bold t :weight bold))))
 '(erc-dangerous-host-face ((t (:foreground "red"))))
 '(erc-default-face ((t (nil))))
 '(erc-direct-msg-face ((t (:foreground "pale green"))))
 '(erc-error-face ((t (:bold t :foreground "gray85" :weight bold))))
 '(erc-fool-face ((t (:foreground "Gray85"))))
 '(erc-highlight-face ((t (:bold t :foreground "pale green" :weight bold))))
 '(erc-input-face ((t (:foreground "light blue"))))
 '(erc-inverse-face ((t (:background "Black" :foreground "White"))))
 '(erc-keyword-face ((t (:bold t :foreground "pale green" :weight bold))))
 '(erc-notice-face ((t (:foreground "light salmon"))))
 '(erc-pal-face ((t (:foreground "pale green"))))
 '(erc-prompt-face ((t (:bold t :foreground "light blue" :weight bold))))
 '(erc-timestamp-face ((t (:bold t :foreground "green" :weight bold))))
 '(erc-underline-face ((t (:underline t))))
 '(eshell-ls-archive-face ((t (:bold t :weight bold))))
 '(eshell-ls-backup-face ((t (:foreground "gray85"))))
 '(eshell-ls-clutter-face ((t (:bold t :foreground "gray85" :weight bold))))
 '(eshell-ls-directory-face ((t (:bold t :foreground "Cyan" :weight bold))))
 '(eshell-ls-executable-face ((t (:bold t :weight bold))))
 '(eshell-ls-missing-face ((t (:bold t :weight bold))))
 '(eshell-ls-picture-face ((t (:foreground "gray85"))))
 '(eshell-ls-product-face ((t (:foreground "gray85"))))
 '(eshell-ls-readonly-face ((t (:foreground "gray70"))))
 '(eshell-ls-special-face ((t (:bold t :weight bold))))
 '(eshell-ls-symlink-face ((t (:bold t :weight bold))))
 '(eshell-ls-text-face ((t (:foreground "gray85"))))
 '(eshell-ls-todo-face ((t (:bold t :weight bold))))
 '(eshell-ls-unreadable-face ((t (:foreground "gray85"))))
 '(eshell-prompt-face ((t (:bold t :foreground "Yellow" :weight bold))))
 '(eshell-test-failed-face ((t (:bold t :weight bold))))
 '(eshell-test-ok-face ((t (:bold t :weight bold))))
 '(excerpt ((t (:italic t :slant italic))))
 '(ff-paths-non-existant-file-face ((t (:bold t :foreground "gray85" :weight bold))))
 '(fg:black ((t (:foreground "black"))))
 '(fg:erc-color-face0 ((t (:foreground "White"))))
 '(fg:erc-color-face1 ((t (:foreground "black"))))
 '(fg:erc-color-face10 ((t (:foreground "lightblue1"))))
 '(fg:erc-color-face11 ((t (:foreground "cyan"))))
 '(fg:erc-color-face12 ((t (:foreground "blue"))))
 '(fg:erc-color-face13 ((t (:foreground "deeppink"))))
 '(fg:erc-color-face14 ((t (:foreground "gray50"))))
 '(fg:erc-color-face15 ((t (:foreground "gray90"))))
 '(fg:erc-color-face2 ((t (:foreground "blue4"))))
 '(fg:erc-color-face3 ((t (:foreground "green4"))))
 '(fg:erc-color-face4 ((t (:foreground "red"))))
 '(fg:erc-color-face5 ((t (:foreground "brown"))))
 '(fg:erc-color-face6 ((t (:foreground "purple"))))
 '(fg:erc-color-face7 ((t (:foreground "orange"))))
 '(fg:erc-color-face8 ((t (:foreground "yellow"))))
 '(fg:erc-color-face9 ((t (:foreground "green"))))
 '(fixed ((t (:bold t :weight bold))))
 '(fixed-pitch ((t (:family "outline-lucida console"))))
 '(fl-comment-face ((t (:foreground "gray85"))))
 '(fl-function-name-face ((t (:foreground "green"))))
 '(fl-keyword-face ((t (:foreground "LightGreen"))))
 '(fl-string-face ((t (:foreground "light coral"))))
 '(fl-type-face ((t (:foreground "cyan"))))
 '(flyspell-duplicate-face ((t (:bold t :foreground "Gold3" :underline t :weight bold))))
 '(flyspell-incorrect-face ((t (:bold t :foreground "OrangeRed" :underline t :weight bold))))
 '(font-latex-bold-face ((t (nil))))
 '(font-latex-italic-face ((t (nil))))
 '(font-latex-math-face ((t (nil))))
 '(font-latex-sedate-face ((t (:foreground "Gray85"))))
 '(font-latex-string-face ((t (:foreground "orange"))))
 '(font-latex-warning-face ((t (:foreground "gold"))))
 '(font-lock-builtin-face ((t (:bold t :foreground "LightSteelBlue" :weight bold))))
 '(font-lock-comment-face ((t (:italic t :foreground "medium aquamarine" :slant italic))))
 '(font-lock-constant-face ((t (:bold t :foreground "Aquamarine" :weight bold))))
 '(font-lock-doc-face ((t (:bold t :weight bold))))
 '(font-lock-doc-string-face ((t (:bold t :foreground "aquamarine" :weight bold))))
 '(font-lock-exit-face ((t (:foreground "green"))))
 '(font-lock-function-name-face ((t (:italic t :bold t :foreground "LightSkyBlue" :slant italic :weight bold))))
 '(font-lock-keyword-face ((t (:bold t :foreground "Cyan" :weight bold))))
 '(font-lock-preprocessor-face ((t (:foreground "Gray85"))))
 '(font-lock-reference-face ((t (:foreground "cyan"))))
 '(font-lock-string-face ((t (:italic t :foreground "aquamarine" :slant italic))))
 '(font-lock-type-face ((t (:bold t :foreground "PaleGreen" :weight bold))))
 '(font-lock-variable-name-face ((t (:italic t :bold t :foreground "LightGoldenrod" :slant italic :weight bold))))
 '(font-lock-warning-face ((t (:bold t :foreground "Salmon" :weight bold))))
 '(fringe ((t (:background "#3c5473"))))
 '(gnus-cite-attribution-face ((t (:italic t :bold t :foreground "beige" :underline t :slant italic :weight bold))))
 '(gnus-cite-face-1 ((t (:foreground "gold"))))
 '(gnus-cite-face-10 ((t (:foreground "coral"))))
 '(gnus-cite-face-11 ((t (:foreground "turquoise"))))
 '(gnus-cite-face-2 ((t (:foreground "wheat"))))
 '(gnus-cite-face-3 ((t (:foreground "light pink"))))
 '(gnus-cite-face-4 ((t (:foreground "khaki"))))
 '(gnus-cite-face-5 ((t (:foreground "pale green"))))
 '(gnus-cite-face-6 ((t (:foreground "beige"))))
 '(gnus-cite-face-7 ((t (:foreground "orange"))))
 '(gnus-cite-face-8 ((t (:foreground "magenta"))))
 '(gnus-cite-face-9 ((t (:foreground "violet"))))
 '(gnus-emphasis-bold ((t (:bold t :foreground "light gray" :weight bold))))
 '(gnus-emphasis-bold-italic ((t (:italic t :bold t :foreground "cyan" :slant italic :weight bold))))
 '(gnus-emphasis-highlight-words ((t (:background "gray30" :foreground "gold"))))
 '(gnus-emphasis-italic ((t (:italic t :foreground "cyan" :slant italic))))
 '(gnus-emphasis-underline ((t (:foreground "white" :underline t))))
 '(gnus-emphasis-underline-bold ((t (:bold t :foreground "white" :underline t :weight bold))))
 '(gnus-emphasis-underline-bold-italic ((t (:italic t :bold t :foreground "white" :underline t :slant italic :weight bold))))
 '(gnus-emphasis-underline-italic ((t (:italic t :foreground "white" :underline t :slant italic))))
 '(gnus-filterhist-face-1 ((t (nil))))
 '(gnus-group-mail-1-empty-face ((t (:foreground "Magenta"))))
 '(gnus-group-mail-1-face ((t (:bold t :foreground "Magenta" :weight bold))))
 '(gnus-group-mail-2-empty-face ((t (:foreground "aquamarine2"))))
 '(gnus-group-mail-2-face ((t (:bold t :foreground "aquamarine2" :weight bold))))
 '(gnus-group-mail-3-empty-face ((t (:foreground "Cyan"))))
 '(gnus-group-mail-3-face ((t (:bold t :foreground "Cyan" :weight bold))))
 '(gnus-group-mail-low-empty-face ((t (:foreground "Wheat"))))
 '(gnus-group-mail-low-face ((t (:bold t :foreground "Gray85" :weight bold))))
 '(gnus-group-news-1-empty-face ((t (:foreground "PaleTurquoise"))))
 '(gnus-group-news-1-face ((t (:bold t :foreground "PaleTurquoise" :weight bold))))
 '(gnus-group-news-2-empty-face ((t (:foreground "turquoise"))))
 '(gnus-group-news-2-face ((t (:bold t :foreground "turquoise" :weight bold))))
 '(gnus-group-news-3-empty-face ((t (:foreground "wheat"))))
 '(gnus-group-news-3-face ((t (:bold t :foreground "Wheat" :weight bold))))
 '(gnus-group-news-4-empty-face ((t (:foreground "Aquamarine"))))
 '(gnus-group-news-4-face ((t (:bold t :weight bold))))
 '(gnus-group-news-5-empty-face ((t (:foreground "MediumAquamarine"))))
 '(gnus-group-news-5-face ((t (:bold t :weight bold))))
 '(gnus-group-news-6-empty-face ((t (:foreground "MediumAquamarine"))))
 '(gnus-group-news-6-face ((t (:bold t :weight bold))))
 '(gnus-group-news-low-empty-face ((t (:foreground "MediumAquamarine"))))
 '(gnus-group-news-low-face ((t (:bold t :foreground "MediumAquamarine" :weight bold))))
 '(gnus-header-content-face ((t (:italic t :foreground "Wheat" :slant italic))))
 '(gnus-header-from-face ((t (:bold t :foreground "light yellow" :weight bold))))
 '(gnus-header-name-face ((t (:bold t :foreground "Wheat" :weight bold))))
 '(gnus-header-newsgroups-face ((t (:italic t :bold t :foreground "gold" :slant italic :weight bold))))
 '(gnus-header-subject-face ((t (:bold t :foreground "Gold" :weight bold))))
 '(gnus-picons-face ((t (:background "white" :foreground "gray30"))))
 '(gnus-picons-xbm-face ((t (:background "white" :foreground "gray30"))))
 '(gnus-signature-face ((t (:italic t :foreground "white" :slant italic))))
 '(gnus-splash ((t (:foreground "Brown"))))
 '(gnus-splash-face ((t (:foreground "orange"))))
 '(gnus-summary-cancelled-face ((t (:background "gray30" :foreground "orange"))))
 '(gnus-summary-high-ancient-face ((t (:bold t :foreground "SkyBlue" :weight bold))))
 '(gnus-summary-high-read-face ((t (:bold t :foreground "gray85" :weight bold))))
 '(gnus-summary-high-ticked-face ((t (:bold t :foreground "coral" :weight bold))))
 '(gnus-summary-high-unread-face ((t (:italic t :bold t :foreground "gold" :slant italic :weight bold))))
 '(gnus-summary-low-ancient-face ((t (:italic t :foreground "SkyBlue" :slant italic))))
 '(gnus-summary-low-read-face ((t (:italic t :foreground "gray85" :slant italic))))
 '(gnus-summary-low-ticked-face ((t (:italic t :bold t :foreground "coral" :slant italic :weight bold))))
 '(gnus-summary-low-unread-face ((t (:italic t :foreground "white" :slant italic))))
 '(gnus-summary-normal-ancient-face ((t (:foreground "SkyBlue"))))
 '(gnus-summary-normal-read-face ((t (:foreground "gray70"))))
 '(gnus-summary-normal-ticked-face ((t (:bold t :foreground "pink" :weight bold))))
 '(gnus-summary-normal-unread-face ((t (:bold t :foreground "gray85" :weight bold))))
 '(gnus-summary-selected-face ((t (:foreground "white" :underline t))))
 '(gnus-x-face ((t (:background "white" :foreground "gray30"))))
 '(green ((t (:foreground "green"))))
 '(gui-button-face ((t (:background "grey75" :foreground "gray30"))))
 '(gui-element ((t (:background "Gray80"))))
 '(header-line ((t (:background "grey20" :foreground "grey90"))))
 '(hi-black-b ((t (:bold t :weight bold))))
 '(hi-black-hb ((t (:bold t :weight bold :height 1.67 :family "helv"))))
 '(hi-blue ((t (:background "light blue"))))
 '(hi-blue-b ((t (:bold t :foreground "blue" :weight bold))))
 '(hi-green ((t (:background "green"))))
 '(hi-green-b ((t (:bold t :foreground "green" :weight bold))))
 '(hi-pink ((t (:background "pink"))))
 '(hi-red-b ((t (:bold t :foreground "red" :weight bold))))
 '(hi-yellow ((t (:background "yellow"))))
 '(highlight ((t (:background "SkyBlue3"))))
 '(highlight-changes-delete-face ((t (:foreground "gray85" :underline t))))
 '(highlight-changes-face ((t (:foreground "gray85"))))
 '(highline-face ((t (:background "#3c5473"))))
 '(highline-vertical-face ((t (:background "lightcyan"))))
 '(holiday-face ((t (:background "pink" :foreground "gray30"))))
 '(html-helper-bold-face ((t (:bold t :weight bold))))
 '(html-helper-bold-italic-face ((t (nil))))
 '(html-helper-builtin-face ((t (:foreground "gray85" :underline t))))
 '(html-helper-italic-face ((t (:bold t :foreground "yellow" :weight bold))))
 '(html-helper-underline-face ((t (:underline t))))
 '(html-tag-face ((t (:bold t :weight bold))))
 '(hyper-apropos-documentation ((t (:foreground "white"))))
 '(hyper-apropos-heading ((t (:bold t :weight bold))))
 '(hyper-apropos-hyperlink ((t (:foreground "sky blue"))))
 '(hyper-apropos-major-heading ((t (:bold t :weight bold))))
 '(hyper-apropos-section-heading ((t (:bold t :weight bold))))
 '(hyper-apropos-warning ((t (:bold t :foreground "gray85" :weight bold))))
 '(ibuffer-marked-face ((t (:foreground "gray85"))))
 '(idlwave-help-link-face ((t (:foreground "Blue"))))
 '(idlwave-shell-bp-face ((t (:background "Pink" :foreground "Black"))))
 '(info-header-node ((t (:italic t :bold t :foreground "brown" :slant italic :weight bold))))
 '(info-header-xref ((t (:bold t :foreground "magenta4" :weight bold))))
 '(info-menu-5 ((t (:underline t))))
 '(info-menu-6 ((t (nil))))
 '(info-menu-header ((t (:bold t :weight bold :family "helv"))))
 '(info-node ((t (:italic t :bold t :slant italic :weight bold))))
 '(info-xref ((t (:bold t :weight bold))))
 '(isearch ((t (:background "LightSeaGreen"))))
 '(isearch-lazy-highlight-face ((t (:background "cyan4"))))
 '(isearch-secondary ((t (:foreground "red3"))))
 '(italic ((t (:italic t :bold t :slant italic :weight bold))))
 '(jde-bug-breakpoint-cursor ((t (:background "brown" :foreground "cyan"))))
 '(jde-bug-breakpoint-marker ((t (:background "yellow" :foreground "red"))))
 '(jde-java-font-lock-api-face ((t (:foreground "LightBlue"))))
 '(jde-java-font-lock-bold-face ((t (:bold t :weight bold))))
 '(jde-java-font-lock-code-face ((t (nil))))
 '(jde-java-font-lock-constant-face ((t (:foreground "LightBlue"))))
 '(jde-java-font-lock-doc-tag-face ((t (:foreground "LightBlue"))))
 '(jde-java-font-lock-italic-face ((t (:italic t :slant italic))))
 '(jde-java-font-lock-link-face ((t (:foreground "cyan3" :underline t))))
 '(jde-java-font-lock-modifier-face ((t (:foreground "LightBlue"))))
 '(jde-java-font-lock-number-face ((t (:foreground "RosyBrown"))))
 '(jde-java-font-lock-operator-face ((t (:foreground "cyan3"))))
 '(jde-java-font-lock-package-face ((t (:foreground "LightBlue"))))
 '(jde-java-font-lock-pre-face ((t (nil))))
 '(jde-java-font-lock-underline-face ((t (:underline t))))
 '(lazy-highlight-face ((t (:bold t :foreground "yellow" :weight bold))))
 '(left-margin ((t (nil))))
 '(linemenu-face ((t (:background "gray30"))))
 '(list-mode-item-selected ((t (:background "gray68"))))
 '(log-view-file-face ((t (:bold t :background "grey70" :weight bold))))
 '(log-view-message-face ((t (:background "grey85"))))
 '(magenta ((t (:foreground "gray85"))))
 '(makefile-space-face ((t (:background "hotpink" :foreground "white"))))
 '(man-bold ((t (:bold t :weight bold))))
 '(man-heading ((t (:bold t :weight bold))))
 '(man-italic ((t (:foreground "yellow"))))
 '(man-xref ((t (:underline t))))
 '(menu ((t (:background "wheat" :foreground "gray30"))))
 '(message-cited-text ((t (:foreground "orange"))))
 '(message-cited-text-face ((t (:foreground "medium aquamarine"))))
 '(message-header-cc-face ((t (:bold t :foreground "gray85" :weight bold))))
 '(message-header-contents ((t (:foreground "white"))))
 '(message-header-name-face ((t (:foreground "gray85"))))
 '(message-header-newsgroups-face ((t (:italic t :bold t :foreground "yellow" :slant italic :weight bold))))
 '(message-header-other-face ((t (:foreground "gray85"))))
 '(message-header-subject-face ((t (:bold t :foreground "green3" :weight bold))))
 '(message-header-to-face ((t (:bold t :foreground "green2" :weight bold))))
 '(message-header-xheader-face ((t (:foreground "blue"))))
 '(message-headers ((t (:bold t :foreground "orange" :weight bold))))
 '(message-highlighted-header-contents ((t (:bold t :weight bold))))
 '(message-mml-face ((t (:bold t :foreground "gray85" :weight bold))))
 '(message-separator-face ((t (:foreground "gray85"))))
 '(message-url ((t (:bold t :foreground "pink" :weight bold))))
 '(mmm-default-submode-face ((t (:background "#c0c0c5"))))
 '(mmm-face ((t (:background "black" :foreground "green"))))
 '(mode-line ((t (:background "#3c5473" :foreground "lightgray" :box (:line-width -1 :style released-button :family "helv")))))
 '(mode-line-buffer-id ((t (:background "white" :foreground "DeepSkyBlue3" :slant normal :weight normal :width normal :family "outline-verdana"))))
 '(mode-line-mousable ((t (:background "white" :foreground "DeepSkyBlue3"))))
 '(mode-line-mousable-minor-mode ((t (:background "white" :foreground "DeepSkyBlue3"))))
 '(my-summary-highlight-face ((t (:background "PaleTurquoise4" :foreground "White"))))
 '(my-url-face ((t (:foreground "LightBlue"))))
 '(nil ((t (nil))))
 '(paren-blink-off ((t (:foreground "gray80"))))
 '(paren-face-match ((t (:background "turquoise"))))
 '(paren-face-mismatch ((t (:background "purple" :foreground "white"))))
 '(paren-face-no-match ((t (:background "yellow" :foreground "gray30"))))
 '(paren-match ((t (:background "darkseagreen2"))))
 '(paren-mismatch ((t (:background "RosyBrown" :foreground "gray30"))))
 '(paren-mismatch-face ((t (:bold t :background "white" :foreground "red" :weight bold))))
 '(paren-no-match-face ((t (:bold t :background "white" :foreground "red" :weight bold))))
 '(pointer ((t (nil))))
 '(primary-selection ((t (:background "gray40"))))
 '(reb-match-0 ((t (:background "lightblue"))))
 '(reb-match-1 ((t (:background "aquamarine"))))
 '(reb-match-2 ((t (:background "springgreen"))))
 '(reb-match-3 ((t (:background "yellow"))))
 '(red ((t (:foreground "red"))))
 '(region ((t (:background "Cyan4"))))
 '(right-margin ((t (nil))))
 '(scroll-bar ((t (:background "grey75"))))
 '(secondary-selection ((t (:background "gray60"))))
 '(semantic-dirty-token-face ((t (:background "gray10"))))
 '(semantic-intangible-face ((t (:foreground "gray25"))))
 '(semantic-read-only-face ((t (:background "gray25"))))
 '(semantic-unmatched-syntax-face ((t (:underline "red"))))
 '(senator-intangible-face ((t (:foreground "gray75"))))
 '(senator-momentary-highlight-face ((t (:background "gray70"))))
 '(senator-read-only-face ((t (:background "#664444"))))
 '(sgml-comment-face ((t (:foreground "dark turquoise"))))
 '(sgml-doctype-face ((t (:foreground "turquoise"))))
 '(sgml-end-tag-face ((t (:foreground "aquamarine"))))
 '(sgml-entity-face ((t (:foreground "gray85"))))
 '(sgml-ignored-face ((t (:background "gray60" :foreground "gray40"))))
 '(sgml-ms-end-face ((t (:foreground "green"))))
 '(sgml-ms-start-face ((t (:foreground "yellow"))))
 '(sgml-pi-face ((t (:foreground "lime green"))))
 '(sgml-sgml-face ((t (:foreground "brown"))))
 '(sgml-short-ref-face ((t (:foreground "deep sky blue"))))
 '(sgml-start-tag-face ((t (:foreground "aquamarine"))))
 '(sh-heredoc-face ((t (:foreground "tan"))))
 '(shell-option-face ((t (:foreground "gray85"))))
 '(shell-output-2-face ((t (:foreground "gray85"))))
 '(shell-output-3-face ((t (:foreground "gray85"))))
 '(shell-output-face ((t (:bold t :weight bold))))
 '(shell-prompt-face ((t (:foreground "yellow"))))
 '(show-paren-match-face ((t (:bold t :background "turquoise" :weight bold))))
 '(show-paren-mismatch-face ((t (:bold t :background "RosyBrown" :foreground "white" :weight bold))))
 '(show-tabs-space-face ((t (:foreground "yellow"))))
 '(show-tabs-tab-face ((t (:foreground "red"))))
 '(smerge-base-face ((t (:foreground "red"))))
 '(smerge-markers-face ((t (:background "grey85"))))
 '(smerge-mine-face ((t (:foreground "Gray85"))))
 '(smerge-other-face ((t (:foreground "darkgreen"))))
 '(speedbar-button-face ((t (:bold t :weight bold))))
 '(speedbar-directory-face ((t (:bold t :weight bold))))
 '(speedbar-file-face ((t (:bold t :weight bold))))
 '(speedbar-highlight-face ((t (:background "sea green"))))
 '(speedbar-selected-face ((t (:underline t))))
 '(speedbar-tag-face ((t (:foreground "yellow"))))
 '(strokes-char-face ((t (:background "lightgray"))))
 '(swbuff-current-buffer-face ((t (:bold t :foreground "gray85" :weight bold))))
 '(template-message-face ((t (:bold t :weight bold))))
 '(term-black ((t (:foreground "black"))))
 '(term-blackbg ((t (:background "black"))))
 '(term-blue ((t (:foreground "blue"))))
 '(term-bluebg ((t (:background "blue"))))
 '(term-bold ((t (:bold t :weight bold))))
 '(term-cyan ((t (:foreground "cyan"))))
 '(term-cyanbg ((t (:background "cyan"))))
 '(term-default ((t (:background "gray80" :foreground "gray30" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :width normal :family "outline-lucida console"))))
 '(term-default-bg ((t (nil))))
 '(term-default-bg-inv ((t (nil))))
 '(term-default-fg ((t (nil))))
 '(term-default-fg-inv ((t (nil))))
 '(term-green ((t (:foreground "green"))))
 '(term-greenbg ((t (:background "green"))))
 '(term-invisible ((t (nil))))
 '(term-invisible-inv ((t (nil))))
 '(term-magenta ((t (:foreground "magenta"))))
 '(term-magentabg ((t (:background "magenta"))))
 '(term-red ((t (:foreground "red"))))
 '(term-redbg ((t (:background "red"))))
 '(term-underline ((t (:underline t))))
 '(term-white ((t (:foreground "white"))))
 '(term-whitebg ((t (:background "white"))))
 '(term-yellow ((t (:foreground "yellow"))))
 '(term-yellowbg ((t (:background "yellow"))))
 '(tex-math-face ((t (:foreground "RosyBrown"))))
 '(texinfo-heading-face ((t (:foreground "Blue"))))
 '(text-cursor ((t (:background "Red3" :foreground "gray80"))))
 '(tool-bar ((t (:background "grey75" :foreground "black"))))
 '(toolbar ((t (:background "Gray80"))))
 '(tooltip ((t (:background "lightyellow" :foreground "black"))))
 '(trailing-whitespace ((t (:background "red"))))
 '(underline ((t (:underline t))))
 '(variable-pitch ((t (:family "helv"))))
 '(vc-annotate-face-0046FF ((t (:background "black" :foreground "wheat"))))
 '(vcursor ((t (:background "cyan" :foreground "blue" :underline t))))
 '(vertical-divider ((t (:background "Gray80"))))
 '(vhdl-font-lock-attribute-face ((t (:foreground "gray85"))))
 '(vhdl-font-lock-directive-face ((t (:foreground "gray85"))))
 '(vhdl-font-lock-enumvalue-face ((t (:foreground "gray85"))))
 '(vhdl-font-lock-function-face ((t (:foreground "gray85"))))
 '(vhdl-font-lock-prompt-face ((t (:bold t :foreground "gray85" :weight bold))))
 '(vhdl-font-lock-reserved-words-face ((t (:bold t :foreground "gray85" :weight bold))))
 '(vhdl-font-lock-translate-off-face ((t (:background "LightGray"))))
 '(vhdl-speedbar-architecture-face ((t (:foreground "gray85"))))
 '(vhdl-speedbar-architecture-selected-face ((t (:foreground "gray85" :underline t))))
 '(vhdl-speedbar-configuration-face ((t (:foreground "gray85"))))
 '(vhdl-speedbar-configuration-selected-face ((t (:foreground "gray85" :underline t))))
 '(vhdl-speedbar-entity-face ((t (:foreground "gray85"))))
 '(vhdl-speedbar-entity-selected-face ((t (:foreground "gray85" :underline t))))
 '(vhdl-speedbar-instantiation-face ((t (:foreground "gray85"))))
 '(vhdl-speedbar-instantiation-selected-face ((t (:foreground "gray85" :underline t))))
 '(vhdl-speedbar-package-face ((t (:foreground "gray85"))))
 '(vhdl-speedbar-package-selected-face ((t (:foreground "gray85" :underline t))))
 '(viper-minibuffer-emacs-face ((t (:background "darkseagreen2" :foreground "Black"))))
 '(viper-minibuffer-insert-face ((t (:background "pink" :foreground "Black"))))
 '(viper-minibuffer-vi-face ((t (:background "grey" :foreground "DarkGreen"))))
 '(viper-replace-overlay-face ((t (:background "darkseagreen2" :foreground "Black"))))
 '(viper-search-face ((t (:background "khaki" :foreground "Black"))))
 '(vm-header-content-face ((t (:italic t :foreground "wheat" :slant italic))))
 '(vm-header-from-face ((t (:italic t :foreground "wheat" :slant italic))))
 '(vm-header-name-face ((t (:foreground "cyan"))))
 '(vm-header-subject-face ((t (:foreground "cyan"))))
 '(vm-header-to-face ((t (:italic t :foreground "cyan" :slant italic))))
 '(vm-message-cited-face ((t (:foreground "Gray80"))))
 '(vm-monochrome-image ((t (:background "white" :foreground "gray30"))))
 '(vm-summary-face-1 ((t (:foreground "MediumAquamarine"))))
 '(vm-summary-face-2 ((t (:foreground "MediumAquamarine"))))
 '(vm-summary-face-3 ((t (:foreground "MediumAquamarine"))))
 '(vm-summary-face-4 ((t (:foreground "MediumAquamarine"))))
 '(vm-summary-highlight-face ((t (:foreground "White"))))
 '(vm-xface ((t (:background "white" :foreground "gray30"))))
 '(vmpc-pre-sig-face ((t (:foreground "gray85"))))
 '(vmpc-sig-face ((t (:foreground "gray85"))))
 '(vvb-face ((t (:background "pink" :foreground "gray30"))))
 '(w3m-anchor-face ((t (:bold t :foreground "gray85" :weight bold))))
 '(w3m-arrived-anchor-face ((t (:bold t :foreground "gray85" :weight bold))))
 '(w3m-header-line-location-content-face ((t (:background "dark olive green" :foreground "wheat"))))
 '(w3m-header-line-location-title-face ((t (:background "dark olive green" :foreground "beige"))))
 '(white ((t (:foreground "white"))))
 '(widget ((t (nil))))
 '(widget-button-face ((t (:bold t :weight bold))))
 '(widget-button-pressed-face ((t (:foreground "gray85"))))
 '(widget-documentation-face ((t (:foreground "dark green"))))
 '(widget-field-face ((t (:background "gray85" :foreground "gray30"))))
 '(widget-inactive-face ((t (:foreground "dim gray"))))
 '(widget-single-line-field-face ((t (:background "dim gray" :foreground "white"))))
 '(woman-addition-face ((t (:foreground "orange"))))
 '(woman-bold-face ((t (:bold t :weight bold))))
 '(woman-italic-face ((t (:foreground "beige"))))
 '(woman-unknown-face ((t (:foreground "LightSalmon"))))
 '(x-face ((t (:background "white" :foreground "gray30"))))
 '(xrdb-option-name-face ((t (:foreground "gray85"))))
 '(xref-keyword-face ((t (:foreground "gray85"))))
 '(xref-list-default-face ((t (nil))))
 '(xref-list-pilot-face ((t (:foreground "gray85"))))
 '(xref-list-symbol-face ((t (:foreground "navy"))))
 '(xsl-fo-alternate-face ((t (:foreground "Yellow"))))
 '(xsl-fo-main-face ((t (:foreground "PaleGreen"))))
 '(xsl-other-element-face ((t (:foreground "Coral"))))
 '(xsl-xslt-alternate-face ((t (:foreground "LightGray"))))
 '(xsl-xslt-main-face ((t (:foreground "Wheat"))))
 '(xxml-emph-1-face ((t (:background "lightyellow"))))
 '(xxml-emph-2-face ((t (:background "lightyellow"))))
 '(xxml-header-1-face ((t (:background "seashell1" :foreground "MediumAquamarine"))))
 '(xxml-header-2-face ((t (:background "seashell1" :foreground "SkyBlue"))))
 '(xxml-header-3-face ((t (:background "seashell1"))))
 '(xxml-header-4-face ((t (:background "seashell1"))))
 '(xxml-interaction-face ((t (:background "lightcyan"))))
 '(xxml-rug-face ((t (:background "cyan"))))
 '(xxml-sparkle-face ((t (:background "yellow"))))
 '(xxml-unbreakable-space-face ((t (:foreground "grey" :underline t))))
 '(yellow ((t (:foreground "yellow"))))
 '(zmacs-region ((t (:background "Cyan4")))))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'tsimon)

;;; tsimon.el ends here
