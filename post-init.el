;;; post-init.el --- Post Init -*- no-byte-compile: t; lexical-binding: t; -*-

(defvar nox/emacs-directory (concat (getenv "HOME") "/.config/nyx")
  "Base Emacs directory.")
(defvar nox/notes-directory (concat (getenv "HOME") "/Documents/org")
  "Base notes directory.")

(add-to-list 'load-path (concat nox/emacs-directory "/libs/"))

;; Specify the custom file path and load the custom file quietly
(setq custom-file (concat nox/emacs-directory "/custom-vars.el"))
(load custom-file 'noerror 'nomessage)

(require 'on)          ;; Doom Style Hooks
(require 'doom-macros) ;; Doom Style Macros

(use-package compile-angel
  :demand t
  :custom
  (compile-angel-verbose nil)
  :config
  (compile-angel-on-load-mode)
  (add-hook! emacs-lisp-mode #'compile-angel-on-save-local-mode))

(use-package emacs
  :ensure nil
  :bind*
  (("C-?" . dictionary-lookup-definition))
  :hook
  (on-init-ui . global-hl-line-mode)
  (prog-mode . display-line-numbers-mode)
  :init
  (electric-indent-mode -1)    ;; Disable weird emacs indenting.
  (indent-tabs-mode -1)        ;; Disable the use of tabs for indentation.
  (xterm-mouse-mode 1)         ;; Enable mouse support in terminal mode.
  (file-name-shadow-mode 1)    ;; Enable shadowing of filenames for clarity.
  (electric-pair-mode 1)       ;; Enable pair parens.
  (display-battery-mode 1)     ;; Enable displaying battery info in modline.
  (winner-mode 1)              ;; Easily undo window configuration changes.
  :custom
  (dictionary-server "dict.org")        ;; set dictionary server.
  (delete-selection-mode 1)             ;; Replacing selected text with typed text.
  (global-visual-line-mode 1)           ;; Better text wrapping.
  (display-line-numbers-type 'relative) ;; Use relative line numbering.
  (history-length 25)                   ;; Set the length of the command history.
  (ispell-dictionary "en_US")           ;; Default dictionary for spell checking.
  (ring-bell-function 'ignore)          ;; Disable the audible bell.
  (tab-width 4)                         ;; Set the tab width to 4 spaces.
  (use-dialog-box nil)                  ;; Disable dialog boxes.
  (warning-minimum-level :error)        ;; Set the minimum level of warnings.
  (show-paren-context-when-offscreen t) ;; Show context of parens when offscreen.

  ;; TAB key complete, instead of just indenting.
  (tab-always-indent 'complete)
  ;; Use advanced font locking for Treesit mode.
  (treesit-font-lock-level 4)
  ;; Offer to delete any autosave file when killing a buffer.
  (kill-buffer-delete-auto-save-files t)
  ;; Prevent automatic window splitting if the window width exceeds 300 pixels.
  (split-width-threshold 300)
  :config
  (add-hook! before-save #'delete-trailing-whitespace)
  (setq-default indent-tabs-mode nil))

(use-package woman
  :ensure nil
  :hook
  (woman-mode . olivetti-mode)
  :custom
  (woman-fill-frame t))

(use-package server
  :ensure nil
  :commands server-start
  :hook (on-init-ui . server-start))

(use-package evil
  :commands (evil-mode evil-define-key)
  :hook (on-init-ui . evil-mode)
  :init
  ;; It has to be defined before evil
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :custom
  (evil-undo-system 'undo-fu)
  ;; C-u behaves like it does in vim
  (evil-want-C-u-scroll t)
  ;; Make :s in visual mode operate only on the actual visual selection
  ;; (character or block), instead of the full lines covered by the selection
  (evil-ex-visual-char-range t)
  ;; Use Vim-style regular expressions in search and substitute commands,
  ;; allowing features like \v (very magic), \zs, and \ze for precise matches
  (evil-ex-search-vim-style-regexp t)
  ;; Enable automatic vertical split to the right
  (evil-vsplit-window-right t)
  ;; Disable echoing Evil state to avoid replacing eldoc
  (evil-echo-state nil)
  ;; Do not move cursor back when exiting insert state
  (evil-move-cursor-back nil)
  ;; Make `v$` exclude the final newline
  (evil-v$-excludes-newline t)
  ;; Allow C-h to delete in insert state
  (evil-want-C-h-delete t)
  ;; Enable C-u to delete back to indentation in insert state
  (evil-want-C-u-delete t)
  ;; Enable fine-grained undo behavior
  (evil-want-fine-undo t)
  ;; Whether Y yanks to the end of the line
  (evil-want-Y-yank-to-eol t)
  :config

  (evil-define-key 'normal 'global
    (kbd "C-S-v") 'cua-set-mark
    "s" 'evil-avy-goto-char-timer)

  (evil-define-key '(normal visual) 'global
    "P" 'consult-yank-from-kill-ring
    "H" 'evil-first-non-blank
    "?" 'gptel-quick
    "L" 'evil-end-of-line))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init)
  :custom
  (evil-collection-calendar-want-org-bindings t)
  (evil-collection-want-find-usages-bindings t))

(use-package evil-org
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package general
  :after evil
  :config
  (general-evil-setup)
  (general-create-definer nox/leader-keys
    :states  '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")

(nox/leader-keys
  "a"   '(:ignore t :wk "[A]pplications")
  "a c" '(calendar :wk "[C]alendar")
  "a e" '(elfeed :wk "[E]lfeed")
  "a g" '(gptel :wk "[G]ptel")
  "a m" '(mu4e :wk "[M]ail"))

(nox/leader-keys
  "b"   '(:ignore t :wk "[B]uffer")
  "b b" '(consult-buffer :wk "[B]uffer Switch")
  "b i" '(persp-ibuffer :wk "[I]buffer")
  "b k" '(kill-current-buffer :wk "[K]ill Buffer")
  "b n" '(next-buffer :wk "[N]ext Buffer")
  "b p" '(previous-buffer :wk "[P]revious Buffer")
  "b r" '(revert-buffer :wk "[R]eload Buffer"))

(nox/leader-keys
  "d"   '(:ignore t :wk "[D]ired")
  "d ." '(dired-omit-mode :wk "Toggle dot files")
  "d d" '(dirvish :wk "[D]irvish")
  "d h" '(dired-hide-details-mode :wk "[D]ired"))

(nox/leader-keys
  "e"   '(:ignore t :wk "[E]val")
  "e b" '(eval-buffer :wk "[B]uffer Eval")
  "e d" '(eval-defun :wk "[D]efun Eval")
  "e e" '(eval-expression :wk "[E]xpression Eval")
  "e l" '(eval-last-sexp :wk "[E]xpression Before Eval")
  "e r" '(eval-region :wk "[R]egion Eval"))

(nox/leader-keys
  "f"   '(:ignore t :wk "[F]ile")
  "f c" `((lambda () (interactive) (find-file ,(concat nox/emacs-directory "/config.org"))) :wk "[C]onfig File")
  "f s" '(save-buffer :wk "[S]ave Buffer")
  "f d" '(bufferfile-delete :wk "[D]elete File")
  "f r" '(bufferfile-rename :wk "[R]ename File")
  "f u" '(sudo-edit-find-file :wk "S[U]do Find File")
  "f U" '(sudo-edit :wk "S[U]do Edit File"))

(nox/leader-keys
  "g"   '(:ignore t :wk "[G]it")
  "g g" '(magit-status :wk "[G]it Status")
  "g c" '(magit-commit-create :wk "[G]it Commit")
  "g n" '(diff-hl-next-hunk :wk "[N]ext hunk")
  "g p" '(diff-hl-previous-hunk :wk "[P]revious hunk")
  "g s" '(diff-hl-stage-dwim :wk "[G]it Stage Hunk"))

(nox/leader-keys
  "o"   '(:ignore t :wk "[O]rg")
  "o a" '(org-agenda :wk "[A]genda")
  "o c" '(org-capture :wk "[C]apture")
  "o x" '(org-toggle-checkbox :wk "[C]heckbox")
  "o L" '(org-store-link :wk "[L]ink Store")
  "o b" '(:ignore t :wk "[B]abel")
  "o b t" '(org-babel-tangle :wk "[T]angle")
  "o b d" '(org-babel-demarcate-block :wk "[D]emarcate Block"))

(nox/leader-keys
  "o r"   '(:ignore t :wk "Org Roam")
  "o r f" '(org-roam-node-find :wk "Find node")
  "o r r" '(org-roam-node-random :wk "Random node")
  "o r b" '(org-roam-buffer-toggle :wk "Backlinks buffer")
  "o r s" '(org-roam-db-sync :wk "Sync database"))

(nox/leader-keys
  "o r d"   '(:ignore t :wk "by date")
  "o r d t" '(org-roam-dailies-goto-today :wk "Goto today")
  "o r d T" '(org-roam-dailies-goto-tomorrow :wk "Goto tomorrow")
  "o r d d" '(org-roam-dailies-goto-date :wk "Goto date")
  "o r d y" '(org-roam-dailies-goto-yesterday :wk "Goto yesterday"))

(nox/leader-keys
  "q"   '(:ignore t :wk "[Q]uit")
  "q f" '(delete-frame :wk "[F]rame delete")
  "q r" '(nox/restore-perspectives :wk "[R]estore perspectives")
  "q K" '(kill-emacs :wk "[K]ill emacs"))

(nox/leader-keys
  "p"   '(:ignore t :wk "[P]roject")
  "SPC" '(projectile-find-file :wk "Find file in project")
  "p p" '(projectile-switch-project :wk "Switch Project"))

(nox/leader-keys
  "s"   '(:ignore t :wk "[S]earch")
  "s g" '(consult-ripgrep :wk "[G]rep in dir")
  "s i" '(consult-imenu :wk "[I]menu")
  "s f" '(consult-fd :wk "[F]d Consult")
  "s r" '(consult-recent-file :wk "[R]recent File")
  "s m" '(bookmark-jump :wk "[M]arks")
  "s c" '(consult-mode-command :wk "[C]ommands for mode"))

(nox/leader-keys
  "t"   '(:ignore t :wk "[T]oggle")
  "t e" '(eshell :wk "[E]shell")
  "t l" '(nox/split-and-open-elpaca-log :wk "[L]og Elpaca")
  "t c" '(olivetti-mode :wk "[C]olumn Fill Mode")
  "t d" '(toggle-window-dedicated :wk "[D]edicated Mode")
  "t v" '(vterm :wk "[V]term")
  "t n" '(display-line-numbers-mode :wk "[N]umbered Lines"))

(nox/leader-keys
  "TAB"   '(:ignore t :wk "Workspaces")
  "TAB TAB" '(nox/list-workspaces :wk "Next Workspace")
  "TAB [" '(persp-prev :wk "Previous Workspace")
  "TAB ]" '(persp-next :wk "Next Workspace")
  "TAB d" '((lambda () (interactive) (persp-kill (persp-name (persp-curr)))) :wk "Delete workspace")
  "TAB n" '(persp-switch :wk "New Workspace"))

(nox/leader-keys
  "RET" '(consult-bookmark :wk "Jump to Bookmark")
  "'" '(vertico-repeat :wk "Resume last search")
  "," '(consult-buffer :wk "Switch buffer")
  "." '(find-file :wk "Find File")))

(use-package which-key
  :ensure nil
  :hook (on-first-input . which-key-mode)
  :custom
  (which-key-side-window-location 'bottom)
  (which-key-sort-order #'which-key-key-order-alpha)
  (which-key-sort-uppercase-first nil)
  (which-key-add-column-padding 1)
  (which-key-max-display-columns nil)
  (which-key-min-display-lines 5)
  (which-key-side-window-slot -10)
  (which-key-side-window-max-height 0.25)
  (which-key-idle-delay 0.3)
  (which-key-max-description-length 25)
  (which-key-allow-imprecise-window-fit nil)
  (which-key-separator " → " ))

(setq auto-save-default t     ; auto-save every buffer that visits a file
      auto-save-timeout 20    ; number of seconds idle time before auto-save
      auto-save-interval 200) ; number of keystrokes between auto-saves

(setq auto-save-list-file-prefix
      (expand-file-name "autosave/" user-emacs-directory))
(setq tramp-auto-save-directory
      (expand-file-name "tramp-autosave/" user-emacs-directory))

(setq auto-save-visited-interval 5) ; Save after 5 seconds if inactivity
(auto-save-visited-mode 1)

(use-package autorevert
  :ensure nil
  :commands (auto-revert-mode global-auto-revert-mode)
  :hook
  (elpaca-after-init . global-auto-revert-mode)
  :custom
  (auto-revert-interval 3)
  (auto-revert-remote-files nil)
  (auto-revert-use-notify t)
  (auto-revert-avoid-polling nil)
  (auto-revert-verbose t))

;; setting the backup dir to trash.
(let ((trash-dir (getenv "XDG_DATA_HOME")))
  (unless (and trash-dir (file-directory-p trash-dir))
    (setq trash-dir (expand-file-name "~/.local/share"))) ;; default fallback
  (setq backup-directory-alist `(("." . ,(concat trash-dir "/Trash/files")))))

(setq make-backup-files t     ; backup of a file the first time it is saved.
      backup-by-copying t     ; don't clobber symlinks
      version-control   t     ; version numbers for backup files
      delete-old-versions t   ; delete excess backup files silently
      kept-old-versions 6     ; oldest versions to keep when a new numbered
      kept-new-versions 9)    ; newest versions to keep when a new numbered

(use-package recentf
  :ensure nil
  :commands (recentf-mode recentf-cleanup)
  :hook
  (elpaca-after-init . recentf-mode)
  :custom
  (recentf-max-menu-items 25)
  (recentf-max-saved-items 300) ; default is 20
  (recentf-auto-cleanup (if (daemonp) 300 'never))
  (recentf-exclude
   (list "\\.tar$" "\\.tbz2$" "\\.tbz$" "\\.tgz$" "\\.bz2$"
         "\\.bz$" "\\.gz$" "\\.gzip$" "\\.xz$" "\\.zip$"
         "\\.7z$" "\\.rar$"
         "COMMIT_EDITMSG\\'"
         "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
         "-autoloads\\.el$" "autoload\\.el$"))
  :config
  (run-with-timer 60 (* 30 60) 'recentf-save-list)
  ;; A cleanup depth of -90 ensures that `recentf-cleanup' runs before
  ;; `recentf-save-list', allowing stale entries to be removed before the list
  ;; is saved by `recentf-save-list', which is automatically added to
  ;; `kill-emacs-hook' by `recentf-mode'.
  (add-hook! kill-emacs :depth -90 #'recentf-cleanup))

(use-package savehist
  :ensure nil
  :commands (savehist-mode savehist-save)
  :hook
  (elpaca-after-init . savehist-mode)
  :custom
  (savehist-autosave-interval 600)
  (savehist-additional-variables
   '(kill-ring                     ; clipboard
     register-alist                   ; macros
     mark-ring global-mark-ring       ; marks
     search-ring
     regexp-search-ring
     command-history
     set-variable-value-history
     custom-variable-history
     query-replace-history
     read-expression-history
     minibuffer-history
     read-char-history
     face-name-history
     bookmark-history
    file-name-history)))

(defun unpropertize-kill-ring ()
  (setq kill-ring (mapcar 'substring-no-properties kill-ring)))
(add-hook! kill-emacs #'unpropertize-kill-ring)

(use-package saveplace
  :ensure nil
  :commands (save-place-mode save-place-local-mode)
  :hook
  (elpaca-after-init . save-place-mode)
  :custom
  (save-place-limit 400))

(let ((theme-file (expand-file-name "~/.cache/theme-status")))
  (setq doom-theme
        (if (and (file-exists-p theme-file)
                 (with-temp-buffer
                   (insert-file-contents theme-file)
                   (string-match-p "light" (buffer-string))))
            'doom-gruvbox-light ;; light theme
          'doom-gruvbox)))      ;; fallback theme or dark theme

(use-package doom-themes
  :defer t
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :hook
  (on-init-ui . (lambda ()
                  (load-theme doom-theme t)
                  (doom-themes-org-config))))

(use-package spacious-padding
  :hook (on-init-ui . spacious-padding-mode))

(use-package doom-modeline
  :hook
  (on-init-ui . doom-modeline-mode)
  :config
  (setq doom-modeline-major-mode-icon nil)
  (setq line-number-mode nil)
  (setq column-number-mode nil)
  (setq find-file-visit-truename t)
  (setq doom-modeline-icon t)
  (setq doom-modeline-buffer-encoding nil)
  (setq doom-modeline-percent-position nil)
  (setq doom-modeline-height 36))

(use-package hide-mode-line :commands hide-mode-line-mode)

(set-face-attribute 'variable-pitch nil
                    :family "Inter"
                    :height 140
                    :weight 'regular)

(set-face-attribute 'fixed-pitch nil
                    :family "CaskaydiaCove Nerd Font"
                    :height 140
                    :weight 'regular)

(set-face-attribute 'default nil :inherit 'fixed-pitch)

(set-face-attribute 'fixed-pitch-serif nil
                    :inherit 'fixed-pitch
                    :family 'unspecified)

(add-to-list 'default-frame-alist '(font . "CaskaydiaCove Nerd Font-14"))

(defun nox/set-fonts ()
  "Set fonts and face attributes."
  ;; setting the emoji font family
  ;; https://emacs.stackexchange.com/a/80186
  (set-fontset-font t 'emoji
                    '("Apple Color Emoji" . "iso10646-1") nil 'prepend)

  ;; italic comments and keywords
  (set-face-attribute 'font-lock-comment-face nil :italic t)

  ;; setting the line spacing
  (setq-default line-spacing 0.16))

(add-hook! on-init-ui #'nox/set-fonts)

(use-package mixed-pitch
  :hook (text-mode . mixed-pitch-mode))

(use-package olivetti
  :hook (org-mode . olivetti-mode)
  :custom
  (olivetti-body-width 110))

(use-package ultra-scroll
  :hook (on-first-input . ultra-scroll-mode)
  :init
  (setq scroll-conservatively 3 ; or whatever value you prefer, since v0.4
        scroll-margin 0)        ; important: scroll-margin more than 0 not yet supported
  :config
  (add-hook 'ultra-scroll-hide-functions #'hl-todo-mode)
  (add-hook 'ultra-scroll-hide-functions #'diff-hl-flydiff-mode)
  (add-hook 'ultra-scroll-hide-functions #'jit-lock-mode)
  (add-hook 'ultra-scroll-hide-functions #'good-scroll-mode))

(use-package good-scroll
  :hook (on-init-ui . good-scroll-mode)
  :bind
  ([remap evil-scroll-up] . good-scroll-down-half-screen)
  ([remap evil-scroll-line-to-center] . good-scroll-center-cursor)
  ([remap evil-scroll-down] . good-scroll-up-half-screen)
  :config
  (defun good-scroll-center-cursor ()
    "Scroll cursor to center."
    (interactive)
    (let* ((pixel-y (cdr (posn-x-y (posn-at-point))))               ; cursor vertical position
           (half-window (/ (good-scroll--window-usable-height) 2))  ; half of usable window height
           (delta (- pixel-y half-window)))                         ; difference from center
      (good-scroll-move delta)))

  (defun good-scroll-up-half-screen ()
    "Scroll up by half screen."
    (interactive)
    (good-scroll-move (/ (good-scroll--window-usable-height) 2)))

  (defun good-scroll-down-half-screen ()
    "Scroll down by half screen."
    (interactive)
    (good-scroll-move (- (/ (good-scroll--window-usable-height) 2)))))

(use-package evil-goggles
  :hook (on-first-input . evil-goggles-mode)
  :init
  (setq evil-goggles-duration 0.1
        evil-goggles-pulse nil ; too slow
        ;; evil-goggles provides a good indicator of what has been affected.
        ;; delete/change is obvious, so I'd rather disable it for these.
        evil-goggles-enable-delete nil
        evil-goggles-enable-change nil)
  :config
  ;; optionally use diff-mode's faces; as a result, deleted text
  ;; will be highlighed with `diff-removed` face which is typically
  ;; some red color (as defined by the color theme)
  ;; other faces such as `diff-added` will be used for other actions
  (evil-goggles-use-diff-faces))

(defun nox/split-and-open-elpaca-log ()
  "Split window vertically, run `elpaca-log`, and make the right window dedicated."
  (interactive)
  ;; Ensure the elpaca log buffer exists
  (elpaca-log)
  (let* ((buf (get-buffer "*elpaca-log*"))
         (right-window (split-window-right)))
    (when buf
      ;; Display the buffer in the right window
      (set-window-buffer right-window buf)
      ;; Make the window dedicated
      (set-window-dedicated-p right-window t)
      ;; Focus the right window
      (select-window right-window))))

(defun nox/get-secret (path)
  "Retrieve a specific secret using yq from the decrypted SOPS file."
  (string-trim
   (shell-command-to-string
    (format "sops -d %s | yq -r '%s'"
            (shell-quote-argument
             (expand-file-name "~/Documents/ember/secrets/secrets.sops.yaml"))
            path))))

(use-package avy
  :commands
  (evil-avy-goto-char-timer
   nox/avy-jump-org-block
   nox/avy-jump-to-link)
  :custom
  (avy-background t)
  :config
  (set-face-attribute 'avy-background-face nil
                      :foreground 'unspecified
                      :background 'unspecified
                      :inherit    'shadow))

(defun nox/avy-jump-org-block ()
  "Jump to org block using Avy subsystem."
  (interactive)
  (avy-jump (rx line-start (zero-or-more blank) "#+begin_src")
            :action 'goto-char)
  ;; Jump _into_ the block:
  (forward-line))

(defun nox/avy-jump-to-link ()
  "Jump to links using Avy subsystem."
  (interactive)
  (avy-jump (rx (or "http://" "https://")) :action 'goto-char))

(defun nox/open-in-reddigg (url &optional new-window)
  "Open the provided url in reddigg"
  (reddigg-view-comments url))

(defun nox/parse-readwise (url &optional new-window)
  "Extract, decode and open the save URL part from a given Readwise URL."
  (if (string-match "https://wise\\.readwise\\.io/save\\?url=\\(.*\\)" url)
      (browse-url (url-unhex-string (match-string 1 url)))
    (error "Invalid URL format")))

(setq browse-url-handlers
      '(("^https?://www\\.reddit\\.com" . nox/open-in-reddigg)
        ("^https?://arstechnica\\.com" . eww)
        ("^https?://wise\\.readwise\\.io/save\\?url=" . nox/parse-readwise)
        ("." . nox/browse-url-maybe-privately)))

(setq browse-url-generic-program "firefox")

(use-package bufferfile
  :custom (bufferfile-use-vc t)
  :commands (bufferfile-rename bufferfile-delete))

(use-package sudo-edit
  :commands (sudo-edit-find-file sudo-edit))

(defun nox/run-commands-for-buffer-names ()
  "Run specific commands for certain buffer names."
  (let ((buffer-name (buffer-name)))
    (cond
     ((string-prefix-p "*ChatGPT" buffer-name)
      ;; make the window dedicated
      (set-window-dedicated-p (selected-window) t))

     ((string= buffer-name "*elfeed-entry*")
      ;; cleanup lines and make olivetti-mode work better
      (visually-cleanup-lines))

     ((string= buffer-name "*reddigg-comments*")
      (org-appear-mode -1)
      (evil-goto-first-line)
      ;; convert all md links to org links
      (nox/md-to-org-links)
      (nox/md-code-blocks-to-org)
      (nox/md-blockquotes-to-org)
      ;; make the window dedicated
      (set-window-dedicated-p (selected-window) t)
      ;; easier quitting of the window
      (evil-local-set-key 'normal "q" 'kill-current-buffer)
      ;; open all folds
      (org-fold-show-all)
      (read-only-mode)))))

;; Add the function to hooks
(add-hook! buffer-list-update #'nox/run-commands-for-buffer-names)

(use-package calendar
  :ensure nil
  :commands (calendar)
  :hook
  (calendar-mode . olivetti-mode)
  (calendar-mode . (lambda () (setq-local global-hl-line-mode nil)))
  (calendar-today-visible . calendar-mark-today)
  :custom
  (calendar-mark-holidays-flag t) ;; Show holidays
  ;; disable unwanted calendar holidays
  (holiday-christian-holidays nil)
  (holiday-hebrew-holidays nil)
  (holiday-islamic-holidays nil)
  (holiday-bahai-holidays nil)
  (holiday-solar-holidays nil)
  :config
  (evil-define-key 'normal calendar-mode-map (kbd "RET") #'nox/calendar-open-daily-file)
  (set-face-attribute 'holiday nil
                      :background 'unspecified
                      :foreground (doom-color 'red)
                      :underline  'unspecified)
  (set-face-attribute 'calendar-today nil
                      :foreground (doom-color 'green)
                      :underline  'unspecified))

(defun nox/calendar-open-daily-file ()
  "Open the Org-roam daily note file for the date under cursor in calendar.
  If the file does not exist, show a message instead of creating it.
  Closes the calendar buffer before opening the daily note."
  (interactive)
  (if (eq major-mode 'calendar-mode)
      (let* ((date (calendar-cursor-to-date))
             (month (nth 0 date))
             (day (nth 1 date))
             (year (nth 2 date))
             (filename (expand-file-name
                        (format "%04d-%02d-%02d.org" year month day)
                        (concat org-roam-directory "/" org-roam-dailies-directory))))
        (if (file-exists-p filename)
            (progn
              (kill-buffer)
              (find-file filename))
          (message "Daily note for %04d-%02d-%02d does not exist!" year month day)))
    (message "Not in a calendar buffer.")))

(use-package helpful
  :commands
  (helpful-callable helpful-variable helpful-key helpful-command helpful-at-point)
  :hook
  (helpful-mode . hide-mode-line-mode)
  (helpful-mode . (lambda ()
                    (set-window-dedicated-p (selected-window) t)))
  :custom
  (helpful-max-buffers 1)
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-command]  . helpful-command)
  ([remap describe-key]      . helpful-key)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-symbol]   . helpful-symbol)
  ([remap view-hello-file]   . helpful-at-point))

(use-package transient :defer t)

(use-package gptel
  :commands gptel
  :hook
  (gptel-mode . evil-insert-state)
  (gptel-post-stream . gptel-auto-scroll)
  (gptel-post-response-functions . gptel-end-of-response)
  :bind* (("C-c RET" . gptel-send))
  :custom
  (gptel-default-mode 'org-mode)
  (gptel-api-key (nox/get-secret ".api.openai"))
  :config
  (gptel-make-perplexity "Perplexity"
                         :key (nox/get-secret ".api.perplexity")
                         :stream t)
  (gptel-make-gemini "Gemini"
                     :key (nox/get-secret ".api.gemini")
                     :stream t))

(use-package posframe :defer t)

(use-package gptel-quick
  :ensure (:host github :repo "karthink/gptel-quick")
  :commands gptel-quick
  :custom
  (gptel-quick-display 'posframe))

(use-package jinx
  :hook
  (on-first-input . global-jinx-mode)
  :bind* (("C-/" . jinx-correct)))

;; (use-package pdf-tools
;;   :hook
;;   (pdf-view-mode . (lambda ()
;;                      (pdf-view-themed-minor-mode)
;;                      (set (make-local-variable 'evil-normal-state-cursor) (list nil))))
;;   :mode "\\.pdf\\'"
;;   :bind (:map pdf-view-mode-map
;;               ("j" . pdf-view-next-line-or-next-page)
;;               ("k" . pdf-view-previous-line-or-previous-page)
;;               ("C-=" . pdf-view-enlarge)
;;               ("C--" . pdf-view-shrink))
;;   :config
;;   (package-initialize)
;;   (pdf-tools-install)
;;   (add-to-list 'revert-without-query ".pdf"))
;;
;; (use-package org-pdftools
;;   :hook (org-mode . org-pdftools-setup-link))

(use-package popper
  :hook
  (persp-mode  . popper-mode)
  (popper-mode . popper-echo-mode)
  (popper-open-popup . hide-mode-line-mode)
  :bind* (("C-\\"   . popper-toggle)
          ("C-|"    . popper-cycle)
          ("C-M-\\" . popper-toggle-type))
  :custom
  (popper-group-function #'popper-group-by-perspective)
  (popper-mode-line "")
  (popper-window-height 20)
  (popper-reference-buffers
   '("\\*Messages\\*"
     "\\*Async Shell Command\\*"
     "^\\*eshell.*\\*$" eshell-mode
     "^\\*shell.*\\*$"  shell-mode
     "^\\*term.*\\*$"   term-mode
     "^\\*vterm.*\\*$"  vterm-mode
     "schedule.org"
     calendar-mode
     help-mode
     inferior-python-mode
     helpful-mode
     use-package-statistics-mode
     dictionary-mode
     compilation-mode))
  (popper-echo-transform-function #'nox/popper-truncate-string)
  :config
  (defun nox/popper-truncate-string (str)
    "Truncate STR to 12 characters."
    (if (> (length str) 12)
        (substring str 0 12)
      str)))

(use-package vertico
  :hook
  (on-first-input . vertico-mode)
  :custom
  (vertico-count 13)
  (vertico-resize t)
  (vertico-cycle t)
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-M-j" . vertico-next-group)
              ("C-k" . vertico-previous)
              ("C-M-k" . vertico-previous-group)
              ("M-RET" . vertico-exit-input)
              ("<escape>" . vertico-exit))
  :config
  ;; Add » before the selected completion.
  (advice-add #'vertico--format-candidate :around
              (lambda (orig cand prefix suffix index _start)
                (setq cand (funcall orig cand prefix suffix index _start))
                (concat
                 (if (= vertico--index index)
                     (propertize "» " 'face 'vertico-current)
                   "  ")
                 cand))))

(use-package vertico-directory
  :after vertico
  :ensure nil
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
	          ("DEL" . vertico-directory-delete-char))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package vertico-multiform
  :ensure nil
  :hook (vertico-mode . vertico-multiform-mode)
  :config
  (defvar +vertico-transform-functions nil)

  (cl-defmethod vertico--format-candidate :around
    (cand prefix suffix index start &context ((not +vertico-transform-functions) null))
    (dolist (fun (ensure-list +vertico-transform-functions))
      (setq cand (funcall fun cand)))
    (cl-call-next-method cand prefix suffix index start))

  (defun +vertico-highlight-directory (file)
    "If FILE ends with a slash, highlight it as a directory."
    (when (string-suffix-p "/" file)
      (add-face-text-property 0 (length file) 'marginalia-file-priv-dir 'append file))
    file)

  (defun +vertico-highlight-enabled-mode (cmd)
    "If MODE is enabled, highlight it as font-lock-constant-face."
    (let ((sym (intern cmd)))
      (with-current-buffer (nth 1 (buffer-list))
        (if (or (eq sym major-mode)
                (and
                 (memq sym minor-mode-list)
                 (boundp sym)
                 (symbol-value sym)))
            (add-face-text-property 0 (length cmd) 'font-lock-constant-face 'append cmd)))
      cmd))

  (add-to-list 'vertico-multiform-categories
               '(file
                 (+vertico-transform-functions . +vertico-highlight-directory)))
  (add-to-list 'vertico-multiform-commands
               '(execute-extended-command
                 (+vertico-transform-functions . +vertico-highlight-enabled-mode))))

(use-package orderless
  :after vertico
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :commands (marginalia-mode marginalia-cycle)
  :hook (on-first-input . marginalia-mode))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (add-hook! marginalia-mode #'nerd-icons-completion-marginalia-setup))

(use-package embark
  ;; Embark is an Emacs package that acts like a context menu, allowing
  ;; users to perform context-sensitive actions on selected items
  ;; directly from the completion interface.
  :commands (embark-act
             embark-dwim
             embark-export
             embark-collect
             embark-bindings
             embark-prefix-help-command)
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init
  (setq prefix-help-command #'embark-prefix-help-command)

  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package consult
  ;; Enable automatic preview at point in the *Completions* buffer.
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :bind
  ([remap bookmark-jump] . consult-bookmark)
  ([remap evil-show-marks] . consult-mark)
  ([remap evil-show-registers] . consult-register)
  ([remap goto-line] . consult-goto-line)
  ([remap imenu] . consult-imenu)
  ([remap Info-search] . consult-info)
  ([remap locate] . consult-locate)
  ([remap load-theme] . consult-theme)
  ([remap recentf-open-files] . consult-recent-file)
  ([remap switch-to-buffer] . consult-buffer)
  ([remap switch-to-buffer-other-window] . consult-buffer-other-window)
  ([remap switch-to-buffer-other-frame] . consult-buffer-other-frame)
  ([remap yank-pop] . consult-yank-pop)
  :init
  ;; Optionally configure the register formatting. This improves the register
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Aggressive asynchronous that yield instantaneous results. (suitable for
  ;; high-performance systems.) Note: Minad, the author of Consult, does not
  ;; recommend aggressive values.
  ;; Read: https://github.com/minad/consult/discussions/951
  ;;
  ;; However, the author of minimal-emacs.d uses these parameters to achieve
  ;; immediate feedback from Consult.
  (setq consult-async-input-debounce 0.02
        consult-async-input-throttle 0.05
        consult-async-refresh-delay 0.02)

  :config
  ;; persp with consult
  (with-eval-after-load 'perspective
    (consult-customize consult--source-buffer :hidden t :default nil)
    (add-to-list 'consult-buffer-sources 'persp-consult-source))

  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))
  (setq consult-narrow-key "<"))

(use-package emacs
  :ensure nil
  :custom
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook! minibuffer-setup #'cursor-intangible-mode))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :hook
  ;; To hide dot-files by default
  (dired-mode . dired-omit-mode)
  :custom
  ;; hide files/directories starting with "." in dired-omit-mode
  (dired-omit-files (rx (seq bol ".")))
  ;; Enable "do what I mean" for target directories
  (dired-dwim-target t)

  ;; Close the previous buffer when opening a new `dired' instance
  (dired-kill-when-opening-new-dired-buffer t)
  :config
  (setq dired-free-space nil
        dired-deletion-confirmer 'y-or-n-p
        dired-clean-confirm-killing-deleted-buffers nil
        dired-recursive-deletes 'top
        dired-recursive-copies  'always
        dired-create-destination-dirs 'ask))

(use-package diredfl
  :hook
  ;;(dired-mode . diredfl-mode)
  ;; highlight parent and directory preview as well
  (dirvish-directory-view-mode . diredfl-mode)
  :config
  (set-face-attribute 'diredfl-dir-name nil :bold t))

(use-package dirvish
  :defer t
  :hook
  (on-first-input . dirvish-override-dired-mode)
  (dired-mode . (lambda () (visual-line-mode -1)))
  :custom
  (dirvish-quick-access-entries
   '(("h" "~/"                          "Home")
     ("D" "~/Documents/"                "Documents")
     ("n" "~/Documents/notes/"          "Notes")
     ("d" "~/Downloads/"                "Downloads")
     ("t" "~/.local/share/Trash/files/" "Trash")))
  (dired-listing-switches
   "-l --almost-all --human-readable --group-directories-first --no-group")
  (delete-by-moving-to-trash t)
  (dirvish-mode-line-format
   '(:left (sort symlink) :right (omit yank index)))
  (dirvish-attributes
   '(nerd-icons file-time file-size collapse subtree-state vc-state git-msg))
  (dirvish-side-attributes
   '(vc-state file-size nerd-icons collapse))
  (dirvish-use-header-line 'global)     ; make header line span all panes
  (dirvish-mode-line-bar-image-width 0) ; hide the leading bar image
  (dirvish-reuse-session 'open)
  :config
  (evil-define-key 'normal dired-mode-map
    (kbd "h") 'dired-up-directory
    (kbd "l") 'dired-open-file)

  (evil-define-key 'normal dirvish-mode-map
    (kbd "?") 'dirvish-dispatch
    (kbd "a") 'dirvish-quick-access
    (kbd "TAB") 'dirvish-subtree-toggle
    (kbd "q") 'dirvish-quit)

  (dirvish-side-follow-mode))     ; similar to `treemacs-follow-mode'

(use-package dirvish-emerge
  :commands (dirvish-emerge-mode)
  :ensure nil
  :config
  (setq dirvish-emerge-groups
        ;; Header string |    Type    |    Criterias
        '(("Recent files"  (predicate . recent-files-2h))
          ("Documents"     (extensions "pdf" "tex" "bib" "epub"))
          ("Text"          (extensions "md" "org" "txt"))
          ("Video"         (extensions "mp4" "mkv" "webm"))
          ("Pictures"      (extensions "jpg" "png" "svg" "gif"))
          ("Audio"         (extensions "mp3" "flac" "wav" "ape" "aac"))
          ("Archives"      (extensions "gz" "rar" "zip")))))

(use-package dired-open
  :after dirvish
  :config
  (setq dired-open-extensions '(("gif" . "imv")
                                ("jpg" . "imv")
                                ("webp" . "imv")
                                ("png" . "imv")
                                ("mkv" . "mpv")
                                ("mp4" . "mpv"))))

;; Using RETURN to follow links in Org/Evil
;; Unmap keys in 'evil-maps if not done, (setq org-return-follows-link t) will not work
(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "RET") nil)
  (define-key evil-motion-state-map (kbd "TAB") nil))

;; Setting RETURN key in org-mode to follow links
(setq org-return-follows-link  t)
(use-package org
  :ensure nil
  :defer t
  :hook
  (org-mode . org-indent-mode)
  (org-mode . prettify-symbols-mode)
  (org-mode . (lambda () (display-line-numbers-mode -1)))
  (org-mode . visual-line-mode)
  (org-mode . variable-pitch-mode)
  ;; (org-num-mode . nox/org-mode-hide-stars)
  (org-capture-mode . evil-insert-state)
  :custom
  (org-ellipsis " [...] ")
  (org-confirm-babel-evaluate nil)
  (org-M-RET-may-split-line nil)
  (org-startup-with-latex-preview t)
  (org-attach-id-dir "attachments/")
  (org-attach-use-inheritance t)
  (org-attach-method 'mv)
  (org-startup-with-link-previews t)
  (org-hide-drawer-startup t)
  (org-image-align 'center)
  (org-image-actual-width nil)
  (org-fontify-quote-and-verse-blocks t)
  (org-support-shift-select t)
  (org-hide-emphasis-markers t)
  (org-hide-leading-stars t))

(use-package org-roam
  :hook (org-mode . org-roam-db-autosync-mode)
  :custom
  (org-roam-directory (file-truename "~/Documents/org"))
  :config
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag))))

(defun nox/transclusion-on-insert ()
  "Notify if point is inside a transclusion block when entering insert mode."
  (when (org-transclusion-at-point)
    (org-transclusion-live-sync-start)))

(defun nox/transclusion-on-normal ()
  "Notify if point is inside a transclusion block when entering insert mode."
  (when (org-transclusion-at-point)
    (org-transclusion-live-sync-exit)))

(use-package org-transclusion
  :hook
  (org-mode . org-transclusion-mode)
  (org-mode . (lambda ()
                (add-hook! evil-insert-state-exit  :local #'nox/transclusion-on-normal)
                (add-hook! evil-insert-state-entry :local #'nox/transclusion-on-insert)))
  :config
  (set-face-attribute 'org-transclusion-edit nil
                      :background (doom-color 'bg-alt))

  (setq org-transclusion-exclude-elements '(property-drawer keyword)))

(use-package org-fragtog
  :after org
  :hook
  (org-mode . (lambda ()
                (add-hook! evil-insert-state-entry :local #'org-fragtog-mode)
                (add-hook! evil-insert-state-exit  :local #'org-latex-preview)
                (add-hook! evil-insert-state-exit  :local (org-fragtog-mode -1)))))

(setq-default prettify-symbols-alist
              '(("#+begin_src emacs-lisp" . "")
                ("#+begin_src elisp" . "")
                ("#+begin_src nix" . "")
                ("#+begin_src shell" . "")
                (":ATTACH:" . "🔗")
                ("#+attr_org:" . "")
                ;; better start and end
                ("#+begin_src" . "»")
                ("#+end_src" . "«")
                ("#+BEGIN:" . "»")
                ("#+END:" . "«")
                ("#+begin_example" . "»")
                ("#+end_example" . "«")
                ("#+begin_quote" . "")
                ("#+end_quote" . "")
                ;; quote
                ("#+begin_quote" . "")
                ("#+end_quote" . "")
                ;; babel
                ("#+RESULTS:" . "󰥤")
                (":tangle" . "󰯊")
                (":mkdirp yes" . "")
                ;; elisp
                ("lambda" . "󰘧")
                ("(interactive)" . "")))

  (setq prettify-symbols-unprettify-at-point 'right-edge)

(use-package org-superstar
  :hook
  (org-mode . org-superstar-mode)
  :custom
  (org-superstar-headline-bullets-list
   '("◉" "◈" "○" "▷"))
  ;; Stop cycling bullets to emphasize hierarchy of headlines.
  (org-superstar-cycle-headline-bullets nil)
  ;; Hide away leading stars on terminal.
  (org-superstar-leading-bullet nil)
  ;; 42 = *
  ;; 43 = +
  ;; 45 = -
  (org-superstar-item-bullet-alist '((42 . 8226) (43 . 10148) (45 . 8226)))
  :config
  (set-face-attribute 'org-superstar-leading nil :height 1.3)
  (set-face-attribute 'org-superstar-header-bullet nil
                      :height 1.2
                      :inherit 'fixed-pitch)
  (set-face-attribute 'org-superstar-item nil :height 1.2))

(use-package toc-org
  :hook (org-mode . toc-org-enable))

(use-package org-auto-tangle
  :hook (org-mode . org-auto-tangle-mode))

(use-package org-appear
  :defer t
  :hook
  (org-mode . (lambda ()
                (org-appear-mode)
                (add-hook! evil-insert-state-entry :local #'org-appear-manual-start)
                (add-hook! evil-insert-state-exit  :local #'org-appear-manual-stop)))
  :custom
  (org-appear-autolinks t)
  (org-appear-trigger 'manual))

(with-eval-after-load 'org
  (require 'org-tempo)
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("go" . "src go"))
  (add-to-list 'org-structure-template-alist '("nix" . "src nix"))
  (add-to-list 'org-structure-template-alist '("py" . "src python")))

(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package ibuffer
  :ensure nil
  :commands (ibuffer persp-ibuffer)
  :hook
  (ibuffer-mode . (lambda () (display-line-numbers-mode -1)))
  (ibuffer-mode . (lambda () (visual-line-mode -1))))

(use-package buffer-terminator
  :hook (on-first-input . buffer-terminator-mode))

(use-package perspective
  :hook
  (on-init-ui . persp-mode)
  :commands
  (nox/list-perspectives persp-state-load)
  :custom
  (persp-state-default-file "~/.local/share/persp-state")
  (persp-mode-prefix-key (kbd "C-c b"))
  (persp-modestring-short t)
  (persp-initial-frame-name "main")
  (persp-modestring-dividers '("" "" ""))
  :config
  ;; auto save state every 2 mins
  (run-with-timer 120 (* 15 60) 'persp-state-save)
  (add-hook 'kill-emacs-hook #'persp-state-save))

(defun nox/list-workspaces ()
  "List all workspaces, numbering them and highlighting the current one."
  (interactive)
  (let* ((all-persp (persp-names))            ; all perspective names
         (current (persp-name (persp-curr)))  ; active perspective
         (msg (mapconcat
               (lambda (p)
                 (let* ((i (1+ (cl-position p all-persp :test #'equal)))
                        (label (format "[%d] %s" i p)))
                   (if (equal p current)
                       (propertize label 'face `(:weight bold :foreground ,(doom-color 'orange)))
                     label)))
               all-persp
               " ")))  ; <-- just space between items
    (message "Workspaces: %s" msg)))

;; Advice persp-switch
(advice-add 'persp-switch :after (lambda (&rest _) (nox/list-workspaces)))

(defun nox/restore-perspectives ()
  "Restores the last saved perspective-state and deletes all other frames"
  (interactive)
  (persp-state-load persp-state-default-file)
  (delete-other-frames))

;; auto load state when opening the first client frame
(when (daemonp)
  (add-hook 'server-after-make-frame-hook
            (lambda ()
              (unless (bound-and-true-p persp-mode)
                (nox/restore-perspectives)))))

(with-eval-after-load 'evil
  (evil-define-key '(normal insert) 'global
    (kbd "C-S-h") '(lambda () (interactive) (persp-switch-by-number 1))
    (kbd "C-S-j") '(lambda () (interactive) (persp-switch-by-number 2))
    (kbd "C-S-k") '(lambda () (interactive) (persp-switch-by-number 3))
    (kbd "C-S-l") '(lambda () (interactive) (persp-switch-by-number 4))))

(use-package diff-hl
  :hook (on-first-file . global-diff-hl-mode))

(use-package magit
  :commands (magit))

(use-package projectile
  :hook
  (on-first-input . projectile-mode))

(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 'prompt)
  :hook (on-first-input . global-treesit-auto-mode)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all))

(use-package apheleia
  :ensure t
  :commands (apheleia-mode
             apheleia-global-mode)
  :hook ((prog-mode . apheleia-mode)))

(use-package ligature
  :hook (on-first-input . global-ligature-mode)
  :config
  ;; Enable the "www" ligature in every possible major mode
  (ligature-set-ligatures 't '("www"))
  ;; Enable traditional ligature support in eww-mode, if the
  ;; `variable-pit�h' face supports it
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
  ;; Enable all Cascadia Code ligatures in programming modes
  (ligature-set-ligatures '(prog-mode org-mode)
                          '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                            ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                            "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                            "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                            "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@"
                            "~=" "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "=>" "!="
                            "!!" ">:" "\\\\" "://" "..<" "</>" "###" "#_(" "<<<" "<+>"
                            ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                            "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                            "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                            "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                            "<--" "<-<" "<<=" "<<-")))

(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode)
  :config
  (setq rainbow-delimiters-max-face-count 5))

(use-package rainbow-mode
  :hook
  (prog-mode . rainbow-mode))

(use-package eshell
  :commands eshell
  :ensure nil
  :config
  (setq eshell-rc-script (concat nox/emacs-directory "eshell/profile")
        eshell-aliases-file (concat nox/emacs-directory "eshell/aliases")
        eshell-history-size 5000
        eshell-buffer-maximum-lines 5000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t
        eshell-destroy-buffer-when-process-dies t
        eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))

  (add-hook! eshell-mode  #'hide-mode-line-mode))

(use-package vterm
  :commands vterm
  :hook
  (vterm-mode . (lambda () (display-line-numbers-mode -1)))
  (vterm-mode . hide-mode-line-mode))

(use-package undo-fu
  :after evil
  :commands (undo-fu-only-undo
             undo-fu-only-redo
             undo-fu-only-redo-all
             undo-fu-disable-checkpoint)
  :config
  (setq undo-limit 67108864)          ; 64mb.
  (setq undo-strong-limit 100663296)  ; 96mb.
  (setq undo-outer-limit 1006632960)) ; 960mb.

(use-package undo-fu-session
  :hook (elpaca-after-init . undo-fu-session-global-mode)
  :config
  (setq undo-fu-session-incompatible-files
        '("/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'")))

(use-package vundo
  :commands vundo
  :custom
  (vundo-glyph-alist vundo-unicode-symbols)
  :config
  ;; Take less on-screen space.
  (setq vundo-compact-display t))

(with-eval-after-load 'evil (evil-define-key 'normal 'global (kbd "C-M-u") 'vundo))
