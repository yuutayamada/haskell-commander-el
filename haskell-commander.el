;;; haskell-commander.el ---  Show result of specified function

;; Copyright (C) 2014 by Yuta Yamada

;; Author: Yuta Yamada <cokesboy"at"gmail.com>
;; URL: https://github.com/yuutayamada/haskell-commander-el
;; Version: 0.0.1
;; Package-Requires: ((haskell-mode "1.5"))
;; Keywords: keyword

;;; License:
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;; Commentary:

;;; Code:

(eval-when-compile (require 'cl))
(require 'haskell-mode-autoloads)
(require 'comint)
(require 'thingatpt)

(defvar haskell-commander-input "")
(defvar haskell-commander-directory "")
(defvar haskell-commander-tmp-file "/tmp/haskell-commander.hs")

(defun haskell-commander (&optional input)
  "Do function after load current .hs file."
  (interactive)
  (when (eq 'haskell-mode major-mode)
    (lexical-let ((origin-buffer (current-buffer)))
      (haskell-commander-move origin-buffer)
      (unless (equal default-directory haskell-commander-directory)
        (haskell-commander-send (format ":cd %s" default-directory)))
      (cond
       (input (setq haskell-commander-input input))
       ((use-region-p)
        (setq haskell-commander-input
              (buffer-substring (region-beginning) (region-end))))
       (t (lexical-let ((buf (buffer-string))
                        (real-p (string-match "\\.hs$" (buffer-name))))
            (if real-p
                (haskell-commander-send (format ":load %s" (buffer-name)))
              (with-temp-file haskell-commander-tmp-file
                (insert buf))
              (haskell-commander-send
               (format ":load %s" haskell-commander-tmp-file)))
            (haskell-commander-ask))))
      (haskell-commander-send haskell-commander-input))))

(defun haskell-commander-from-buffer ()
  (haskell-commander (buffer-string)))

(defun haskell-commander-move (origin-buffer)
  (switch-to-haskell)
  (goto-char (point-max))
  (recenter (window-height))
  (switch-to-buffer-other-window origin-buffer))

(defun haskell-commander-ask ()
  (setq haskell-commander-directory default-directory
        haskell-commander-input
        (read-string "ghci: " (or (word-at-point) haskell-commander-input))))

(defun haskell-commander-send (code)
  "Send CODE to *haskell*."
  (comint-send-string "*haskell*" (format "%s\n" code)))

(provide 'haskell-commander)

;; Local Variables:
;; coding: utf-8
;; mode: emacs-lisp
;; End:

;;; haskell-commander.el ends here
