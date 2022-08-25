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
(setq mac-command-modifier 'meta)
(setq sh-shell-file "/usr/local/bin/bash")
(setq vterm-shell "/usr/local/bin/fish")
(setq projectile-project-search-path '(("~/dev" . 3)))
(setq auth-sources '("~/.authinfo"))

;; automatically update buffer from filesystem
(global-auto-revert-mode t)

;; hooks
(add-hook 'dired-mode-hook 'auto-revert-mode)
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)
(add-hook 'sh-mode-hook 'shfmt-on-save-mode)

;; ui
(setq doom-font (font-spec :family "Fira Code" :size 14)
      doom-theme 'doom-material)

(custom-set-variables
 '(initial-frame-alist (quote ((fullscreen . maximized)))))

(defun jle/indent-buffer ()
  "removes trailing whitespace, indents buffer and replaces tabs with spaces"
  (interactive)
  (save-excursion
    (delete-trailing-whitespace)
    (indent-region (point-min) (point-max) nil)
    (untabify (point-min) (point-max))))

(defun jle/mark-current-file-as-executable ()
  "marks the file associated with the current buffer as user-executable"
  (interactive)
  (shell-command (concat "chmod u+x " (buffer-file-name))))

(defun jle/new-shellscript ()
  "create a new shellscript in $HOME/bin"
  (interactive)
  (find-file(format "~/bin/%s" (read-from-minibuffer "Script name: "))))

(setq evil-vsplit-window-right t
      evil-split-window-below t)

;; keybindings
(define-key evil-normal-state-map (kbd "C-e") 'er/expand-region)
(define-key evil-visual-state-map (kbd "C-e") 'er/expand-region)
(define-key evil-insert-state-map (kbd "C-e") 'er/expand-region)
(define-key evil-normal-state-map (kbd "C-f") 'affe-find)
(define-key evil-normal-state-map (kbd "C-b") '+vertico/switch-workspace-buffer)
(define-key evil-normal-state-map (kbd "C-p") 'projectile-switch-project)

(global-set-key (kbd "M--") 'evilnc-comment-or-uncomment-lines)
(global-set-key (kbd "C-s") '+default/search-buffer)
(global-set-key (kbd "C-h") 'evil-window-left)
(global-set-key (kbd "C-l") 'evil-window-right)
(global-set-key (kbd "C-k") 'evil-window-up)
(global-set-key (kbd "C-j") 'evil-window-down)
(global-set-key (kbd "M-w") '+workspace/close-window-or-workspace)
(global-set-key (kbd "C-M-<backspace>") 'delete-other-windows)

(defalias 'sh 'shell-command)
(defalias 'ash 'async-shell-command)

(map! :leader
      (:prefix-map ("j" . "jle")
       (:prefix ("f" . "file")
        :desc "New shell script" "n" #'jle/new-shellscript
        :desc "Indent buffer" "i" #'jle/indent-buffer
        :desc "Mark as executable" "x" #'jle/mark-current-file-as-executable)
       (:prefix ("a" . "asdf")
        :desc "Update asdf plugins" "u" (cmd! (ash "asdf plugin update --all"))
        :desc "Update asdf itself" "U" (cmd! (ash "asdf update"))
        :desc "List global tools" "T" (cmd! (ash "cat ~/.tool-versions")))
       (:prefix ("d" . "chezmoi")
        :desc "Diff" "d" (cmd! (and (ash "chezmoi diff")(other-window 1)))
        :desc "Re-add" "r" (cmd! (ash "chezmoi re-add"))
        :desc "Status" "s" (cmd! (ash "chezmoi status"))
        :desc "Managed" "m" (cmd! (ash "chezmoi managed")))))

(after! reformatter
  :config
  (reformatter-define shfmt
    :program "shfmt"
    :args '("-i" "2" "-ci")
    :lighter " shfmt"))
