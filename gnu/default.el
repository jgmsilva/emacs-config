(load-theme 'wombat)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(set-frame-parameter (selected-frame) 'alpha '(85 85))

(add-to-list 'default-frame-alist '(alpha 85 85))

(set-face-attribute 'default nil :background "black"
  :foreground "white" :font "FiraCode NerdFont Mono" :height 180)
