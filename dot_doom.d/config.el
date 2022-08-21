;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Joakim Lindeng Engeset"
      user-mail-address "joakim.engeset@gmail.com")

(setq evil-escape-key-sequence "fd"
      evil-escape-delay 0.3)

(setq default-directory "~/")
(setq display-line-numbers-type t)
(setq compilation-scroll-output t)
(setq which-key-idle-delay 0)
(setq confirm-kill-emacs nil)
(setq mac-option-modifier nil)
(setq sh-shell-file "/usr/local/bin/bash")

;; automatically update buffer from filesystem
(global-auto-revert-mode t)
(add-hook 'dired-mode-hook 'auto-revert-mode)

(setq doom-font (font-spec :family "Fira Code" :size 14)
      doom-theme 'doom-material)

(custom-set-variables
 '(initial-frame-alist (quote ((fullscreen . maximized)))))

(defun jle/indent-buffer ()
  "removes trailing whitespace, indents buffer and replaces tabs with spaces" (interactive)
  (save-excursion
    (delete-trailing-whitespace)
    (indent-region (point-min) (point-max) nil)
    (untabify (point-min) (point-max))))

(defun jle/mark-current-file-as-executable ()
  "marks the file associated with the current buffer as user-executable"
  (interactive)
  (shell-command (concat "chmod u+x " (buffer-file-name))))

(setq evil-vsplit-window-right t
      evil-split-window-below t)

;; keybindings
(define-key evil-normal-state-map (kbd "C-e") 'er/expand-region)
(define-key evil-visual-state-map (kbd "C-e") 'er/expand-region)
(define-key evil-insert-state-map (kbd "C-e") 'er/expand-region)
(define-key evil-normal-state-map (kbd "C-l") 'jle/indent-buffer)
(define-key evil-normal-state-map (kbd "s--") 'evilnc-comment-or-uncomment-lines)
(define-key evil-normal-state-map (kbd "C-f") '+ivy/projectile-find-file)
(define-key evil-normal-state-map (kbd "C-b") '+vertico/switch-workspace-buffer)
(define-key evil-normal-state-map (kbd "C-p") 'projectile-switch-project)

(global-set-key (kbd "s-!") 'shell-command)
(global-set-key (kbd "s--") 'evilnc-comment-or-uncomment-lines)
(global-set-key (kbd "C-h") 'evil-window-left)
(global-set-key (kbd "C-l") 'evil-window-right)
(global-set-key (kbd "C-k") 'evil-window-up)
(global-set-key (kbd "C-j") 'evil-window-down)

(after! reformatter
  :config
  (reformatter-define shfmt
    :program "shfmt"
    :args '("-i" "2" "-ci")
    :lighter " shfmt"))
(add-hook 'sh-mode-hook 'shfmt-on-save-mode)

(setq projectile-project-search-path '(("~/dev" . 3)))

(setq auth-sources '("~/.authinfo"))
;; (after! forge
;;   :config
;;   (push '("github.com" "github.com/api/v3"
;;           "github.com" forge-github-repository)
;;         forge-alist))

(after! counsel
  ;; open magit status buffer as default action when switching projects
  (setcar counsel-projectile-switch-project-action 14))
