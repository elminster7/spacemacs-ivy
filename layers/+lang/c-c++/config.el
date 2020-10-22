;;; config.el --- C/C++ Layer config File for Spacemacs
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;; variables

(defvar c-c++-enable-clang-support nil
  "If non nil Clang related packages and configuration are enabled.")

(spacemacs|defvar-company-backends c-mode-common)
(spacemacs|defvar-company-backends cmake-mode)

(spacemacs|define-jump-handlers c++-mode)
(spacemacs|define-jump-handlers c-mode)

(defvar c-c++-default-mode-for-headers 'c-mode
  "Default mode to open header files. Can be `c-mode' or `c++-mode'.")

;; rtags
(defvar c-c++-enable-rtags-completion t
  "If `nil', RTags completion is disabled when the RTags backend is enabled.")

;; internal

(defconst c-c++-modes '(c-mode c++-mode)
  "Primary major modes of the `c-c++' layer.")

(defconst c-c++-mode-hooks '(c-mode-hook c++-mode-hook)
  "Primary hooks of the `c-c++' layer.")

(defun spacemacs/c-c++-use-rtags (&optional useFileManager)
  "Return non-nil if rtags function should be used."
  ;; this function is used to fallback on gtags function if rtags is not
  ;; supported. So if gtags layer is not used we disable the fallback by
  ;; returning always t.
  (or (not (configuration-layer/layer-used-p 'gtags))
      (and (rtags-executable-find "rc")
           (cond ((not (gtags-get-rootpath)) t)
                 ((and (not (eq major-mode 'c++-mode))
                       (not (eq major-mode 'c-mode))) (rtags-has-filemanager))
                 (useFileManager (rtags-has-filemanager))
                 (t (rtags-is-indexed))))))

(defun spacemacs/c-c++-tags-find-symbol-at-point (&optional prefix)
  (interactive "P")
  (if (and (not (rtags-find-symbol-at-point prefix))
           rtags-last-request-not-indexed)
      (gtags-find-tag)))

(defun spacemacs/c-c++-tags-find-references-at-point (&optional prefix)
  (interactive "P")
  (if (and (not (rtags-find-references-at-point prefix))
           rtags-last-request-not-indexed)
      (gtags-find-rtag)))

(defun spacemacs/c-c++-tags-find-symbol ()
  (interactive)
  (call-interactively (if (spacemacs/c-c++-use-rtags)
                          'rtags-find-symbol 'gtags-find-symbol)))

(defun spacemacs/c-c++-tags-find-references ()
  (interactive)
  (call-interactively (if (spacemacs/c-c++-use-rtags)
                          'rtags-find-references 'gtags-find-rtag)))

(defun spacemacs/c-c++-tags-find-file ()
  (interactive)
  (call-interactively (if (spacemacs/c-c++-use-rtags t)
                          'rtags-find-file 'gtags-find-file)))

(defun spacemacs/c-c++-tags-imenu ()
  (interactive)
  (call-interactively (if (spacemacs/c-c++-use-rtags t)
                          'rtags-imenu 'idomenu)))
(defvar c-c++-enable-google-style nil
  "If non-nil `google-set-c-style' will be added as as
  `c-mode-common-hook'.")

(defvar c-c++-enable-google-newline nil
  "If non-nil `google-make-newline-indent' will be added as as
  `c-mode-common-hook'.")
