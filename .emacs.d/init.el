;;; init.el --- init file: -*- lexical-binding: t -*-
;;; Commentary: emacs sucks
;;; Code:
;;; configure emacs with this, since it seems people can't write packages that
;;; work without massively affecting the performance of everything.
;;; ./configure -with-nativecomp CFLAGS=" -O3 -march=native"

(defvar my-gc-cons-threshold (* 16 1024 1024)
  "Good value for `gc-cons-threshold`.")

(setq gc-cons-threshold most-positive-fixnum)

(add-to-list 'default-frame-alist '(font . "Consolas 12"))

;;; loading the theme makes emacs start faster for whatever reason
(load-theme 'srcery t)

(require 'package)

(setq-default load-prefer-newer t)
(setq package-enable-at-startup nil)

(push '("melpa" . "https://melpa.org/packages/") package-archives)
(package-initialize)

(eval-when-compile
  (package-refresh-contents)
  (let* ((my-packages
          '(
            srcery-theme
            rust-mode
            magit
            evil
            markdown-mode
            slime paredit
            haskell-mode))

         (packages-to-install (seq-filter (lambda (package)
                                            (not (package-installed-p package)))
                                          my-packages)))
    (when packages-to-install
      (message "init.el :: Instaling packages." )
      (mapc (lambda (p)
              (package-refresh-contents)
              (package-install p))
            packages-to-install)))

  ;; avoid byte compile warnings
  (mapc 'require
        '(haskell python rust-mode slime compile etags ido paredit display-line-numbers cc-mode repeat whitespace markdown-mode)))

;;; defaults
(setq-default inhibit-startup-screen t
              truncate-lines         t)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq column-number-mode          t
                  frame-resize-pixelwise      t
                  set-mark-command-repeat-pop t
                  indent-tabs-mode          nil
                  backup-by-copying         nil
                  auto-save-default         nil
                  auto-save-interval          0
                  blink-cursor-mode         nil
                  ring-bell-function    'ignore
                  backup-directory-alist '(("." . "~/.emacs.d/emacs-saves/"))
                  compile-command ""
                  custom-file "~/.emacs.d/custom.el")

            (when window-system
              (scroll-bar-mode -1)
              (menu-bar-mode   -1)
              (tool-bar-mode   -1)
              (tooltip-mode    -1))

            (set-face-bold 'bold nil)
            (ido-mode)
            (my-keybinds)
            (load custom-file)
	        (evil-mode)
            (garbage-collect)
            (setq gc-cons-threshold my-gc-cons-threshold)))

(defalias 'cmp   'compile)
(defalias 'recmp 'recompile)
(defalias 'wss   'window-swap-states)
(defalias 'dap   'dired-at-point)

;;; languages ------------------------------------------------------------------

;;; VHDL
;; (setq vhdl-basic-offset 4
;;       vhdl-indent-tabs-mode nil)

;;; rust
(with-eval-after-load 'rust-mode
  (setq indent-tabs-mode  nil))

;;; python
(with-eval-after-load 'python
  (setq python-indent-offset 4))

;;; haskell
(with-eval-after-load 'haskell
  (setq haskell-process-show-debug-tips nil
        haskell-doc-prettify-types      nil))

(defun my-haskell-mode-init ()
  "Haskell setup."
  (interactive-haskell-mode)
  (haskell-indentation-mode)
  ;; (haskell-doc-mode)
  ;; (subword-mode)
  )

;;; markdown mode
(with-eval-after-load 'markdown
  (setq markdown-command "/usr/bin/pandoc"
	indent-tabs-mode nil)

  (define-key markdown-mode-map (kbd "M-p") nil)
  (define-key markdown-mode-map (kbd "M-n") nil))

;;; cc-mode :: c/c++
(defun my-cc-mode-init ()
  "C/C++ setup."
  ;;; turn down c++ syntax madness
  (setf font-lock-maximum-decoration (quote ((c++-mode . 2) (t . t))))
  (setq tab-width          4
        c-basic-offset     4
        indent-tabs-mode nil
        c-default-style '((awk-mode . "awk")
                          (other    . "linux"))))

;;; lisp :: common lisp and scheme
(defun my-lisp-mode-init ()
  "Lisp setup."
  (paredit-mode))

;;; ElDoc
(with-eval-after-load 'eldoc
  (setq eldoc-idle-delay 0.5))

;;; slime
(with-eval-after-load 'slime
  (setq inferior-lisp-program "/usr/bin/sbcl"
        slime-contribs '(slime-fancy))
  (define-key slime-mode-map (kbd "M-p") nil)
  (define-key slime-mode-map (kbd "M-n") nil))

;;; flyspell-mode
(with-eval-after-load 'flyspell
  (setq-default flyspell-issue-message-flag nil
                ;; this needs aspell-en and aspell-pt
                ispell-program-name "aspell"))

;;; ido mode
(with-eval-after-load 'ido
  (setq ido-max-prospects 6
        ido-decorations '("\nλ " "" "  "  "  ..." "[" "]" " [?]" " [!]" "" "" " [confirm]"))
  (add-hook 'ido-minibuffer-setup-hook
            (lambda ()
              (set (make-local-variable 'truncate-lines) nil))))

;;; display line numbers
(setq display-line-numbers-type (if truncate-lines 'relative 'visual)
      display-line-numbers-width-start t)

;;; hooks for language modes and others
(mapc (lambda (p)
        (add-hook (car p)
                  (cdr p)))

      '(;; prog-mode-hooks
        (prog-mode-hook             . display-line-numbers-mode)
        ;; little hack so trailing whitespace is not enabled on non programming modes
        (prog-mode-hook             . (lambda ()
                                        (set (make-local-variable 'show-trailing-whitespace) t)))
        ;; paredit hook
        (lisp-mode-hook             . my-lisp-mode-init)
        (inferior-lisp-mode-hook    . my-lisp-mode-init)
        (lisp-interaction-mode-hook . my-lisp-mode-init)
        (emacs-lisp-mode-hook       . my-lisp-mode-init)
        (scheme-mode-hook           . my-lisp-mode-init)
        (slime-repl-mode-hook       . my-lisp-mode-init)
        (eval-expression-minibuffer-setup-hook . paredit-mode)
        ;; markdown hook
        (markdown-mode-hook-hook    . markdown-mode)
        ;; haskell hooks
        (haskell-mode-hook          . my-haskell-mode-init)
        ;; c/c++ hooks
        (c-mode-common-hook         . my-cc-mode-init)))

;;; global keybinds
(defun my-keybinds ()
  (mapc (lambda (p)
        (global-set-key (kbd (car p)) (cdr p)))

      '(("M-j"     . ido-switch-buffer)
        ("M-i"     . complete-symbol)
        ("M-<SPC>" . jump-to-char)
        ("M-p"     . previous-line)
        ("M-n"     . next-line)
        ("C-z"     . nil)
        ;; usefull on abnt keyboards
        ("C-ç"     . undo)
        ("M-ç"     . dabbrev-expand)))

  (mapc (lambda (l)
          (global-set-key (kbd (car l)) (eval (cons 'repetable (cdr l)))))
        '(("C-x ," . ((arg) (interactive "p") 'enlarge-window))
          ("C-x ." . ((arg) (interactive "p") 'enlarge-window-horizontally))
          ("C-x o" . ((arg) (interactive "p") 'other-window))))

        ;;; window manage
  (mapc (lambda (f)
          (advice-add f :after (lambda ()
                                 (interactive)
                                 (other-window 1))))
        '(split-window-below
          split-window-right)))

;; kill the *Completions* buffer after exiting the minibuffer
(add-hook 'minibuffer-exit-hook
          (lambda ()
            (let ((buffer "*Completions*"))
              (and (get-buffer buffer)
                   (kill-buffer buffer)))))

;;; custom functions
(defun repeat-command (command &rest arg)
  "Make a given COMMAND repetable.  Provide ARG if needed."
  ;; from emacs wiki: https://www.emacswiki.org/emacs/Repeatable
  (let ((repeat-previous-repeated-command command)
        (repeat-message-function 'ignore)
        (last-repeatable-command 'repeat))
    (repeat arg)))

(defun jump-to-char (arg char)
  "Jump to the next occurrence of CHAR using ARG.
Pressing CHAR repeats the search.
If ARG is a negative universal command, jump backwards."
  (interactive "p\ncJump-to-char")
  (let ((c (char-to-string char)))
    (search-forward c nil t arg)
    (set-transient-map
     (let ((key-map (make-sparse-keymap)))
       (define-key key-map (kbd c) (lambda () (interactive) (jump-to-char arg char)))
       key-map))))

(defun dict ()
  "Swith the current dictionary used by 'flyspell' 'Ispell'."
  (interactive)
  (let ((dict (ido-completing-read "New default dictionary: " '("english" "brasileiro"))))
    (ispell-change-dictionary dict)
    (message "%s set as the default dictionary" dict)))

(defmacro repetable (args interactive-form cmd)
  "Macro to generate a repetable CMD. Using ARGS and INTERACTIVE-FORM."
  `(lambda ,args
     ,interactive-form
     (repeat-command ,cmd ,@args)))

(provide 'init)
;;; init.el ends here
