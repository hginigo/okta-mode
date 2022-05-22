 ;;; okta-mode.el --- Okta major mode -*- lexical-binding: t -*-

;; Copyright (C) 2021  Free Software Foundation, Inc.

;; Author: Hugo Iñigo <hginigo5@gmail.com>
;; Keywords: languages
;; URL: https://git.sr.ht/~mikelma/oktac

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

 ;;; Commentary:
;; Major Mode for editing the Okta programming language source code.

 ;;; Code:

(defvar okta-mode-hook nil)

(defvar okta-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "C-j" 'newline-and-indent)
    map)
  "Keymap for `okta-mode'.")

(defvar okta-mode-syntax-table
  (with-syntax-table (copy-syntax-table)
    (dolist (i '(?+ ?- ?* ?/ ?% ?| ?& ?! ?~ ?< ?>))
      (modify-syntax-entry i "."))
    (modify-syntax-entry ?# "<")
    (modify-syntax-entry ?\n ">")
    (syntax-table))
  "Syntax table for `okta-mode'.")

(defconst okta-keywords
    '("pub" "use" "const" "extern" "fun"
      "ret" "let" "if" "elif" "else"
      "loop" "for" "while" "break"
      "type" "struct" "enum" "macro"
      "inline" "derive" "packed" "path")
    "List of keywords for Okta.")

(defconst okta-basic-types
  '("i8" "u8"
    "i16" "u16"
    "i32" "u32"
    "i64" "u64"
    "f32" "f32"
    "f64" "f64"
    "bool"
    "c_voidptr")
  "Basic types for Okta.")

(defconst okta-bool-consts
  '("true" "false")
  "Boolean constants for Okta.")

(defconst okta-builtin-functions
  '("sizeof"
    "bitcast"
    "cstr"
    "slice"
    "len"
    "inttoptr"
    "ptrtoint")
  "List of the builtin Okta functions.")

(defun okta-re-word (inner) (concat "\\<" inner "\\>"))
(defun okta-re-symbol (inner) (concat "\\_<" inner "\\_>"))
(defun okta-re-group (inner) (concat "\\(" inner "\\)"))
(defun okta-re-shy (inner) (concat "\\(?:" inner "\\)"))

(defconst okta-re-spc "[[:space:]\\n]+")
(defconst okta-re-id "_*[[:alpha:]][[:alnum:]_]*")

(defconst okta-highlights
  (append
   `(
     ;; Language keywords
     (,(regexp-opt okta-keywords 'symbols) . font-lock-keyword-face)

     ;; Basic types (i32, f64...)
     (,(regexp-opt okta-basic-types 'symbols) . font-lock-type-face)

     ;; Builtin functions starting with `@'
     (,(concat (okta-re-group "@")
               (regexp-opt okta-builtin-functions t)
               "\\_>")
      (1 font-lock-type-face)
      (2 font-lock-builtin-face))
     ;; (,(concat "\\_<@" (regexp-opt okta-builtin-functions t) "\\_>")
     ;;  1 font-lock-type-face)

     ;; Constants and literals such as integers, floats and boolean values
     (,(regexp-opt okta-bool-consts 'symbols) . font-lock-constant-face)
     ("\\<[[:digit:]]+\\(\\.[[:digit:]]*\\)?\\>" . font-lock-constant-face)

     ;; Function definitions
     (,(concat "fun" okta-re-spc "\\([^(]+\\)(.*):") 1 font-lock-function-name-face)
     (,(concat "type" okta-re-spc (okta-re-grab (okta-re-symbol okta-re-id)))
      1 font-lock-type-face)

     ;; ("_*[[:alpha:]][[:alnum:]_]*" . font-lock-variable-name-face)
     )))

;; (defun okta-indent-line ()
;;   "Indent current line of Okta code."
;;   (interactive)
;;   (beginning-of-line)
;;   (if (bobp)
;;       (indent-line-to 0)
;;   (let ((savep (> (current-column) (current-indentation)))
;;         (indent (condition-case nil (max (okta-calculate-indentation) 0)
;;                   (error 0))))
;;     (if savep
;;         (save-excursion (indent-line-to indent))
;;       (indent-line-to indent)))))

;; (defun okta-calculate-indentation ()
;;   "Return the column to which the current line should be indented."
;;   0)

;;;###autoload
(define-derived-mode okta-mode prog-mode "Okta"
  "Major mode for editing Okta source code."
  :syntax-table okta-mode-syntax-table
  (setq-local comment-start "# ")
  (setq-local font-lock-defaults '(okta-highlights))
  ;; (setq-local open-paren-in-column-0-is-defun-start nil)
  (setq-local electric-indent-chars
              (cons ?} (and (boundp 'electric-indent-chars)
                            electric-indent-chars))))

(add-to-list 'auto-mode-alist '("\\.ok\\'" . okta-mode))

(provide 'okta-mode)

