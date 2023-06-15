;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; fix to show doom-dashboard on wsl
;; (add-hook! 'emacs-startup-hook #'doom-init-ui-h)
;; (setq inhibit-splash-screen t)
;; (setq inhibit-startup-message t)
;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
(setq org-agenda-files (directory-files-recursively org-directory "\.org$"))

(setq org-roam-capture-templates
      '(("d" "default" plain "%?"
        :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                        "#+title: ${title}\n")
        :unnarrowed t)
        ("l" "log" plain "%?"
        :target (file+head "log/%<%Y%m%d%H%M%S>-${slug}.org.gpg"
                        "#+title: ${title} - %<%Y-%m-%d>\n")
        :unnarrowed t)))



(after! lsp-haskell
  (setq lsp-haskell-formatting-provider "stylish-haskell"))

(custom-set-variables
 '(haskell-stylish-on-save t))

(add-hook 'elfeed-search-mode-hook #'elfeed-update)


(after! evil-escape
  (setq evil-escape-key-sequence "jj")
  (setq evil-escape-delay 0.4))
(map! :leader "o c" #'=calendar :desc "Calendar")
(defun org-roam-node-visit-by-name (name)
  (if-let ((id (caar (org-roam-db-query [:select id :from nodes :where (= title $s1) :limit 1] name))))
      (org-roam-node-visit (org-roam-populate (org-roam-node-create :id id)))
    (error "No node with this title")))
(defun org-roam-node-id-by-title (title)
  "Get a node ID by its title, whether original title or alias"
  (caar (org-roam-db-query [:select id
                            :from [:select [(as node_id id)
                                            (as alias title)]
                                   :from aliases
                                   :union-all
                                   :select [id title]
                                   :from nodes]
                            :where (= title $s1)
                            :limit 1] title)))
(defun get-roam-index ()
  (interactive)
  (org-roam-node-visit-by-name "Index"))
(map! :leader "n r SPC" #'get-roam-index :desc "Roam Index File")


(use-package! nov
  :mode ("\\.epub\\'" . nov-mode)
  :config
  (setq nov-save-place-file (concat doom-cache-dir "nov-places")))

(after! org-noter
  (setq org-noter-always-create-frame nil))
(after! flyspell
  (setq ispell-dictionary "pt_BR"))

(after! org
  (setq org-log-done 'time)
  (setq org-todo-keywords
      '((sequence
         "WAIT(w)"  ; Something external is holding up this task
         "HOLD(h)"  ; This task is paused/on hold because of me
         "TODO(t)"  ; A task that needs doing & is ready to do
         "NEXT(n)"  ; A task that is in progress
         "OPEN(o)"  ; An open or ongoing loop
         "PROJ(p)"  ; A project, which usually contains other tasks
         "|"
         "DONE(d)"  ; Task successfully completed
         "KILL(K)") ; Task was cancelled, aborted or is no longer applicable
        (sequence
         "[ ](T)"   ; A task that needs doing
         "[-](S)"   ; Task is in progress
         "[?](W)"   ; Task is being held up or paused
         "|"
         "[X](D)")  ; Task was completed
        (sequence   ; adapted from Tony Ballantyne's writing methodology
         "IDEA(i!)"
         "WRITE(w!)"
         "EDIT(e!)"
         "WORKING(k!)"
         "|"
         "USED(u!/@)"))))

(defvar org-project "TODO={ PROJ }")
(after! org-agenda
  (setq org-stuck-projects
        `(,org-project ("NEXT" "WORKING") nil ""))
  (setq org-agenda-custom-commands
      '(("p" . "Priorities")
        ("pa" "A items" tags-todo "+PRIORITY=\"A\"")
        ("pb" "B items" tags-todo "+PRIORITY=\"B\"")
        ("pc" "C items" tags-todo "+PRIORITY=\"C\"")
        ;; ...other commands here
        ))
  (setq org-agenda-skip-deadline-if-done t)
  (setq org-agenda-skip-scheduled-if-done t)
  (setq org-agenda-skip-timestamp-if-done t)
  (setq org-agenda-skip-deadline-prewarning-if-scheduled t))
(setq browse-url-generic-program
      (executable-find (getenv "BROWSER"))
       browse-url-browser-function 'browse-url-generic)

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
