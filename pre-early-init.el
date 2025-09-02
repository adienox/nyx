;;; pre-early-init.el --- Pre Early Init -*- no-byte-compile: t; lexical-binding: t; -*-

(setq minimal-emacs-package-initialize-and-refresh nil)

(defun display-startup-time ()
  "Display the startup time and number of garbage collections."
  (message "Init loaded in %.2f seconds (Full startup: %.2fs) with %d garbage collections."
           (float-time (time-subtract after-init-time before-init-time))
           (time-to-seconds (time-since before-init-time))
           gcs-done))

(add-hook 'elpaca-after-init-hook #'display-startup-time 100)
