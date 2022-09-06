;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq
 user-full-name "Joakim Lindeng Engeset"
 user-mail-address "joakim.engeset@gmail.com"

 evil-escape-key-sequence "fd"
 evil-escape-delay 0.3

 dev-dir "~/dev"

 default-directory "~/"
 display-line-numbers-type t
 compilation-scroll-output t
 which-key-idle-delay 0
 confirm-kill-emacs nil

 fill-column 120
 mac-option-modifier nil
 mac-command-modifier 'meta
 sh-shell-file "/usr/local/bin/bash"
 vterm-shell "/usr/local/bin/fish"
 projectile-project-search-path `((,dev-dir . 3))
 magit-repository-directories `((,dev-dir . 3) (user-emacs-directory . 0))
 auth-sources '("~/.authinfo")
 +zen-text-scale 0
 company-idle-delay 0

 evil-vsplit-window-right t
 evil-split-window-below t

 rmh-elfeed-org-files (list "~/.config/elfeed/elfeed.org")
 )

;; (system-name)
(defun get-font-size ()
  (pcase (system-name)
    ("Nikkos-MBP.localdomain" 17)
    (x 14)))

(setq
 doom-font (font-spec :family "Fira Code" :size (get-font-size))
 doom-theme 'doom-one)

;; by default uses wrong flags for macos-version of locate
(if IS-MAC
    (setq consult-locate-args "locate -i"))

;; automatically update buffer from filesystem
(global-auto-revert-mode t)

;; hooks
(add-hook 'dired-mode-hook 'auto-revert-mode)
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

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

(defun jle/new-script (filename)
  "create a new script in $HOME/bin"
  (interactive (list(read-file-name "Script name: " "~/bin/")))
  (find-file filename))

(defun eval-surrounding-parens ()
  "evaluate surrounding parentheses"
  (interactive)
  (save-excursion
    (up-list 1 t t)
    (eval-last-sexp nil)))

(defun jle/async-cmd-and-switch (command)
  "run COMMAND and switch to new window in special-mode"
  (async-shell-command command)
  (other-window 1)
  (use-local-map (copy-keymap evil-normal-state-local-map))
  (local-set-key "q" 'quit-window) ; make it work in evil-normal-state
  (with-current-buffer "*Async Shell Command*"
    (evil-normal-state)))

(defun jle/line ()
  "return current line"
  (buffer-substring-no-properties
   (line-beginning-position)
   (line-end-position)))

(defun jle/run-cmd-on-line (command)
  "run COMMAND with current line as args"
  (interactive "sCommand: ")
  (async-shell-command (concat command " " (shell-quote-argument (jle/line)))))

(defun jle/run-cmd-on-each-line-in-file (command file)
  "run COMMAND on each line in FILE"
  (interactive "sCommand: \nf")
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (while (not (eobp))
      (jle/run-cmd-on-line command)
      (forward-line))))

(defun shell-cmd-tmpwindow (command)
  "Run COMMAND and pass output to a read-only buffer we can close with q"
  (interactive "sCommand: ")
  (let ((cmd command)
        (temp-buf-name "*short-lived*"))
    (get-buffer-create temp-buf-name)
    (shell-command cmd temp-buf-name)
    (switch-to-buffer-other-window temp-buf-name)
    (evil-insert-state)
    (special-mode)
  (with-current-buffer temp-buf-name
    (evil-insert-state))))

;; keybindings
(define-key evil-normal-state-map (kbd "C-e") 'er/expand-region)
(define-key evil-visual-state-map (kbd "C-e") 'er/expand-region)
(define-key evil-insert-state-map (kbd "C-e") 'er/expand-region)
(define-key evil-normal-state-map (kbd "C-b") 'consult-buffer)
(define-key evil-normal-state-map (kbd "C-p") 'projectile-switch-project)

(global-set-key (kbd "M--") 'evilnc-comment-or-uncomment-lines)
(global-set-key (kbd "C-s") '+default/search-buffer)
(global-set-key (kbd "C-h") 'evil-window-left)
(global-set-key (kbd "C-l") 'evil-window-right)
(global-set-key (kbd "C-k") 'evil-window-up)
(global-set-key (kbd "C-j") 'evil-window-down)
(global-set-key (kbd "M-w") '+workspace/close-window-or-workspace)
(global-set-key (kbd "C-M-<backspace>") 'delete-other-windows)

(map! :leader
      (:prefix-map ("j" . "jle")
       (:prefix ("e" . "eval")
        :desc "Eval current parens" "e" #'eval-surrounding-parens)
       (:prefix ("o" . "open")
        :desc "Open code dir" "c" (cmd! (dired dev-dir))
        :desc "Open ~/bin dir" "b" (cmd! (dired "~/bin"))
        :desc "Open dotfiles dir" "d" (cmd! (dired "~/.local/share/chezmoi")))
       (:prefix ("f" . "file")
        :desc "New shell script" "n" #'jle/new-shellscript
        :desc "Indent buffer" "i" #'jle/indent-buffer
        :desc "Mark as executable" "x" #'jle/mark-current-file-as-executable)
       (:prefix ("r" . "rss")
        :desc "Update feed list" "u" #'elfeed-update
        :desc "Open elfeed" "r" #'elfeed)
       (:prefix ("a" . "asdf")
        :desc "Update asdf plugins" "u" (cmd! (async-shell-command "asdf plugin update --all"))
        :desc "Update asdf itself" "U" (cmd! (async-shell-command "asdf update"))
        :desc "Install desired plugins" "P" (cmd! (async-shell-command "install-asdf-plugins"))
        :desc "List global tools" "T" (cmd! (async-shell-command "cat ~/.tool-versions"))
        :desc "Edit global tools" "E" (cmd! (find-file "~/.tool-versions")))
       (:prefix ("b" . "homebrew")
        :desc "Edit global .Brewfile" "E" (cmd! (find-file "~/.Brewfile"))
        :desc "Update" "u" (cmd! (async-shell-command "brew update"))
        :desc "Install global" "I" (cmd! (async-shell-command "brew bundle --global"))
        :desc "Upgrade" "U" (cmd! (async-shell-command "brew update && brew upgrade"))
        :desc "List installed" "l" (cmd! (jle/async-cmd-and-switch "brew list")))
       (:prefix ("d" . "chezmoi")
        :desc "Add" "a" (cmd! (async-shell-command (format "chezmoi add %s" (read-file-name "chezmoi add: " "~/"))))
        :desc "Diff" "d" (cmd! (jle/async-cmd-and-switch "chezmoi diff"))
        :desc "Re-add" "r" (cmd! (async-shell-command "chezmoi re-add"))
        :desc "Status" "s" (cmd! (async-shell-command "chezmoi status"))
        :desc "Update chezmoi" "u" (cmd! (async-shell-command "chezmoi update"))
        :desc "Upgrade chezmoi" "U" (cmd! (async-shell-command "chezmoi upgrade"))
        :desc "Managed" "m" (cmd! (jle/async-cmd-and-switch "chezmoi managed")))))
