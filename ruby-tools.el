;;; ruby-tools.el --- Collection of handy functions for ruby-mode

;; Copyright (C) 2012 Johan Andersson

;; Author: Johan Andersson <johan.rejeep@gmail.com>
;; Maintainer: Johan Andersson <johan.rejeep@gmail.com>
;; Version: 0.0.1
;; Keywords: speed, convenience, ruby
;; URL: http://github.com/rejeep/ruby-tools

;; This file is NOT part of GNU Emacs.


;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.


;;; Commentary:

;; ruby-tools is a minor mode for Emacs that can be used with
;; ruby-mode. It includes various handy functions that will improve
;; your productivity.
;;
;; To use ruby-tools-mode, make sure that this file is in Emacs load-path:
;;   (add-to-list 'load-path "/path/to/directory/or/file")
;;
;; Then require ruby-tools:
;;   (require 'ruby-tools)
;;
;; ruby-tools-mode is automatically started in ruby-mode.


;;; Code:

(require 'ruby-mode)

(defvar ruby-tools-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-'") 'ruby-tools-to-single-quote-string)
    (define-key map (kbd "C-\"") 'ruby-tools-to-double-quote-string)
    (define-key map (kbd "C-:") 'ruby-tools-to-symbol)
    (define-key map (kbd "#") 'ruby-tools-interpolate)
    map)
  "Keymap for `ruby-tools-mode'.")


(defun ruby-tools-symbol-at-point-p ()
  "Check if cursor is at a symbol or not."
  (and
   (looking-at "[A-Za-z0-9_]+")
   (looking-back ":[A-Za-z0-9_]*")))

(defun ruby-tools-string-at-point-p ()
  "Check if cursor is at a string or not."
  (and
   (looking-at "[^\"']+['\"]")
   (looking-back "['\"][^\"']*")))

(defun ruby-tools-symbol-region ()
  (list
   (save-excursion
     (search-backward ":" (line-beginning-position) t))
   (save-excursion
     (if (re-search-forward "[^A-Za-z0-9_]" (line-end-position) t)
         (1- (point))
       (line-end-position)))))

(defun ruby-tools-string-region ()
  (list
   (save-excursion
     (re-search-backward "['\"][^\"']*" (line-beginning-position) t))
   (save-excursion
     (re-search-forward "[^\"']+['\"]" (line-end-position) t))))

(defun ruby-tools-interpolate ()
  "Interpolate with #{} in some places."
  (interactive)
  (insert "#")
  (when (or
         (and
          (looking-at "[^\"]*\"")
          (looking-back "\"[^\"]*"))
         (and
          (looking-at "[^`]*`")
          (looking-back "`[^`]*"))
         (and
          (looking-at "[^)]*)")
          (looking-back "%([^(]*")))
    (insert "{}")
    (forward-char -1)))

(defun ruby-tools-to-symbol ()
  "Turn string at point to symbol."
  (interactive)
  (if (ruby-tools-string-at-point-p)
      (let* ((region (ruby-tools-string-region))
             (min (nth 0 region))
             (max (nth 1 region))
             (region (buffer-substring-no-properties min max)))
        (if (string-match-p "^['\"][a-ZA-Z_][a-ZA-Z0-9_]+['\"]$" region)
            (save-excursion
              (delete-region min (1+ min))
              (goto-char min)
              (insert ":")
              (delete-region max (1- max)))))))

(defun ruby-tools-to-single-quote-string ()
  (interactive)
  (ruby-tools-to-string "'"))

(defun ruby-tools-to-double-quote-string ()
  (interactive)
  (ruby-tools-to-string "\""))

(defun ruby-tools-to-string (string-quote)
  "Convert symbol or string at point to string."
  (let* ((at-string
          (ruby-tools-string-at-point-p))
         (at-symbol
          (and (not at-string) (ruby-tools-symbol-at-point-p))))
    (when (or at-string at-symbol)
      (let* ((region
              (or
               (and at-symbol (ruby-tools-symbol-region))
               (and at-string (ruby-tools-string-region))))
             (min (nth 0 region))
             (max (nth 1 region))
             (content
              (buffer-substring-no-properties (1+ min) (if at-symbol max (1- max)))))
        (delete-region min max)
        (insert
         (format "%s%s%s" string-quote content string-quote))))))


;;;###autoload
(define-minor-mode ruby-tools-mode
  "Collection of handy functions for ruby-mode."
  :init-value nil
  :lighter " rt"
  :keymap ruby-tools-mode-map)

(add-hook 'ruby-mode-hook 'ruby-tools-mode)

(provide 'ruby-tools)

;;; ruby-tools.el ends here
