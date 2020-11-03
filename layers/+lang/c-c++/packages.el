;;; packages.el --- C/C++ Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq c-c++-packages
  '(
    cc-mode
    disaster
    clang-format
    cmake-mode
    company
    (company-c-headers :toggle (configuration-layer/package-usedp 'company))
    company-ycmd
    flycheck
    gdb-mi
    ggtags
    ;google-c-style
    (helm-cscope :requires (helm))
    (helm-gtags :requires (helm))
    semantic
    srefactor
    stickyfunc-enhance
;    ycmd
    xcscope
    ;; rtags
    (ivy-rtags :requires (ivy rtags))
    rtags
    ; lsp mode
    lsp-mode
    lsp-ui
    ))

(defun c-c++/init-cc-mode ()
  (use-package cc-mode
    :defer t
    :init
    (progn
      (add-to-list 'auto-mode-alist
                   `("\\.h\\'" . ,c-c++-default-mode-for-headers)))
    :config
    (progn
      (require 'compile)
      (c-toggle-auto-newline 1)
      (spacemacs/set-leader-keys-for-major-mode 'c-mode
        "ga" 'projectile-find-other-file
        "gA" 'projectile-find-other-file-other-window)
      (spacemacs/set-leader-keys-for-major-mode 'c++-mode
        "ga" 'projectile-find-other-file
        "gA" 'projectile-find-other-file-other-window))))

(defun c-c++/init-google-c-style ()
  (use-package google-c-style
    :defer t
    :init
    (progn
      (when c-c++-enable-google-style
        (add-hook 'c-mode-common-hook 'google-set-c-style))
      (when c-c++-enable-google-newline
        (add-hook 'c-mode-common-hook 'google-make-newline-indent)))))

(defun c-c++/init-disaster ()
  (use-package disaster
    :defer t
    :commands (disaster)
    :init
    (progn
      (spacemacs/set-leader-keys-for-major-mode 'c-mode
        "D" 'disaster)
      (spacemacs/set-leader-keys-for-major-mode 'c++-mode
        "D" 'disaster))))

(defun c-c++/init-ivy-rtags ()
  (use-package ivy-rtags
    :defer t
    :bind ("M-." . rtags-find-symbol)
	         ("M-," . rtags-find-symbol-at-point)
	         ("M-[]" . rtags-location-stack-back)
	         ("M-]" . rtags-location-stack-forward)
           ("M-o" . rtags-show-target-in-other-window)
    :init (setq rtags-display-result-backend 'ivy)))

(defun c-c++/init-rtags ()
    ;; config in `funcs.el'
  (use-package rtags
    :defer t)
  )

(defun c-c++/init-clang-format ()
  (use-package clang-format
    :if c-c++-enable-clang-support))

(defun c-c++/init-cmake-mode ()
  (use-package cmake-mode
    :mode (("CMakeLists\\.txt\\'" . cmake-mode) ("\\.cmake\\'" . cmake-mode))
    :init (push 'company-cmake company-backends-cmake-mode)))

(defun c-c++/post-init-company ()
  (spacemacs|add-company-hook c-mode-common)
  (spacemacs|add-company-hook cmake-mode)

  (when c-c++-enable-clang-support
    (push 'company-clang company-backends-c-mode-common)

    (defun company-mode/more-than-prefix-guesser ()
      (c-c++/load-clang-args)
      (company-clang-guess-prefix))

    (setq company-clang-prefix-guesser 'company-mode/more-than-prefix-guesser)
    (spacemacs/add-to-hooks 'c-c++/load-clang-args '(c-mode-hook c++-mode-hook))))

(defun c-c++/init-company-c-headers ()
  (use-package company-c-headers
    :defer t
    :init (push 'company-c-headers company-backends-c-mode-common)))

(defun c-c++/post-init-flycheck ()
  (dolist (mode '(c-mode c++-mode))
    (spacemacs/add-flycheck-hook mode))
  (when c-c++-enable-clang-support
    (spacemacs/add-to-hooks 'c-c++/load-clang-args '(c-mode-hook c++-mode-hook))))

(defun c-c++/post-init-ggtags ()
  (add-hook 'c-mode-local-vars-hook #'spacemacs/ggtags-mode-enable)
  (add-hook 'c++-mode-local-vars-hook #'spacemacs/ggtags-mode-enable))

(defun c-c++/init-gdb-mi ()
  (use-package gdb-mi
    :defer t
    :init
    (setq
     ;; use gdb-many-windows by default when `M-x gdb'
     gdb-many-windows t
     ;; Non-nil means display source file containing the main routine at startup
     gdb-show-main t)))

(defun c-c++/init-linux-c-style ()
  (interactive)
  (c-mode)
  (setq c-indent-level 4)
  (setq c-brace-imaginary-offset 4)
  (setq c-brace-offset -4)
  (setq c-argdecl-indent 4)
  (setq c-label-offset -4)
  (setq c-continued-statement-offset 4)
  (setq indent-tabs-mode nil)
  (setq tab-width 4)
  (setq auto-mode-alist
	      (cons '("\\.c\\'" . c-mode) auto-mode-alist))
  (setq auto-mode-alist
	      (cons '("\\.h\\'" . c-mode) auto-mode-alist))
  )

(defun c-c++/post-init-helm-gtags ()
  (spacemacs/helm-gtags-define-keys-for-mode 'c-mode)
  (spacemacs/helm-gtags-define-keys-for-mode 'c++-mode))

(defun c-c++/post-init-semantic ()
  (spacemacs/add-to-hooks 'semantic-mode '(c-mode-hook c++-mode-hook)))

(defun c-c++/post-init-srefactor ()
  (spacemacs/set-leader-keys-for-major-mode 'c-mode "r" 'srefactor-refactor-at-point)
  (spacemacs/set-leader-keys-for-major-mode 'c++-mode "r" 'srefactor-refactor-at-point)
  (spacemacs/add-to-hooks 'spacemacs/lazy-load-srefactor '(c-mode-hook c++-mode-hook)))

(defun c-c++/post-init-stickyfunc-enhance ()
  (spacemacs/add-to-hooks 'spacemacs/lazy-load-stickyfunc-enhance '(c-mode-hook c++-mode-hook)))

(defun c-c++/post-init-ycmd ()
  (add-hook 'c++-mode-hook 'ycmd-mode)
  (add-hook 'c-mode-hook 'ycmd-mode)
  (add-to-list 'spacemacs-jump-handlers-c++-mode '(ycmd-goto :async t))
  (add-to-list 'spacemacs-jump-handlers-c-mode '(ycmd-goto :async t))
  (dolist (mode '(c++-mode c-mode))
    (spacemacs/set-leader-keys-for-major-mode mode
      "gG" 'ycmd-goto-imprecise)))

(defun c-c++/post-init-company-ycmd ()
  (push 'company-ycmd company-backends-c-mode-common))

(defun c-c++/pre-init-xcscope ()
  (spacemacs|use-package-add-hook xcscope
    :post-init
    (dolist (mode '(c-mode c++-mode))
      (spacemacs/set-leader-keys-for-major-mode mode "gi" 'cscope-index-files))))

(defun c-c++/pre-init-helm-cscope ()
  (spacemacs|use-package-add-hook xcscope
    :post-init
    (dolist (mode '(c-mode c++-mode))
      (spacemacs/setup-helm-cscope mode))))

(defun c-c++/init-lsp-mode ()
  "lsp mode"
  (use-package lsp-mode
  :commands lsp
  :ensure t
  :bind ("C-c f" . man-follow)
  :hook ((python-mode c-mode c++-mode) . lsp)
  ))

(defun c-c++/init-lsp-ui ()
  "lsp mode"
  (use-package lsp-ui
    :requires lsp-mode flycheck
    :commands lsp-ui-mode
    :ensure t
    :custom-face
    (lsp-ui-doc-background ((t (:background "blue"))))
    (lsp-ui-doc-header ((t (:inherit (font-lock-string-face italic)))))
    :bind (:map lsp-ui-mode-map
		([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
		([remap xref-find-references] . lsp-ui-peek-find-references)
		("C-c u" . lsp-ui-imenu))
    :hook (lsp-mode-hook . lsp-ui-mode)
    :custom
    ;; lsp-ui-doc
    (lsp-ui-doc-enable nil)
    (lsp-ui-doc-header t)
    (lsp-ui-doc-include-signature nil)
    (lsp-ui-doc-position 'at-point) ;; top, bottom, or at-point
    (lsp-ui-doc-max-width 120)
    (lsp-ui-doc-max-height 30)
    (lsp-ui-doc-use-childframe t)
    (lsp-ui-doc-use-webkit t)
    ;; lsp-ui-flycheck
    (lsp-ui-flycheck-enable nil)
    ;; lsp-ui-sideline
    (lsp-ui-sideline-enable nil)
    (lsp-ui-sideline-ignore-duplicate t)
    (lsp-ui-sideline-show-symbol t)
    (lsp-ui-sideline-show-hover t)
    (lsp-ui-sideline-show-diagnostics nil)
    (lsp-ui-sideline-show-code-actions t)
    (lsp-ui-sideline-code-actions-prefix "")
    ;; lsp-ui-imenu
    (lsp-ui-imenu-enable t)
    (lsp-ui-imenu-kind-position 'top)
    ;; lsp-ui-peek
    (lsp-ui-peek-enable t)
    (lsp-ui-peek-peek-height 120)
    (lsp-ui-peek-list-width 50)
    (lsp-ui-peek-fontify 'always) ;; never, on-demand, or always
    :preface
    (defun ladicle/toggle-lsp-ui-doc ()
      (interactive)
      (if lsp-ui-doc-mode
	  (progn
	    (lsp-ui-doc-mode -1)
	    (lsp-ui-doc--hide-frame))
	         (lsp-ui-doc-mode 1)))
    :config
    ;; Use lsp-ui-doc-webkit only in GUI
    (setq lsp-ui-doc-use-webkit nil)
    ;; WORKAROUND Hide mode-line of the lsp-ui-imenu buffer
    ;; emacs-lsp/lsp-ui#243
    (defadvice lsp-ui-imenu (after hide-lsp-ui-imenu-mode-line activate)
      (setq mode-line-format nil))
    :init (setq lsp-ui-sideline-toggle-symbol-info t)))

;(defun c-c++/init-lsp-mode ()
;  (use-package lsp-mode
;    :defer t
;    :config
;    (progn
;      ;(spacemacs/lsp-bind-keys)
;      (setq lsp-prefer-capf t)
;      (add-hook 'lsp-after-open-hook (lambda ()
;                                       "Setup xref jump handler and declare keybinding prefixes"
;                                       (spacemacs//setup-lsp-jump-handler)
;                                       (spacemacs//lsp-declare-prefixes-for-mode major-mode))))))

;(defun c-c++/init-lsp-ui ()
;  (use-package lsp-ui
;    :defer t
;    :config
;    :bind (:map lsp-ui-mode-map
;                ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
;                ([remap xref-find-references] . lsp-ui-peek-find-references)
;                ("C-c u" . lsp-ui-imenu))
;    :hook (lsp-mode-hook . lsp-ui-mode)))


;    (progn
;      (if lsp-remap-xref-keybindings
;          (progn (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
;                 (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)))
;
;      (spacemacs/lsp-define-key
;       lsp-ui-peek-mode-map
;       "h" #'lsp-ui-peek--select-prev-file
;       "j" #'lsp-ui-peek--select-next
;       "k" #'lsp-ui-peek--select-prev
;       "l" #'lsp-ui-peek--select-next-file
;       )
;      )))
