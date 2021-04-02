{ pkgs ? import <nixos> {} }:
let
  config = pkgs.writeTextDir "share/emacs/site-lisp/default.el" ''
    (setq make-backup-files nil)

    (defun backward-kill-word-or-region (&optional count)
      (interactive "p")
      (if (use-region-p)
          (kill-region (region-beginning) (region-end))
        (backward-kill-word count)))

    (global-set-key (kbd "C-w") #'backward-kill-word-or-region)
    (global-set-key (kbd "C-h") #'backward-delete-char-untabify)
    (define-key isearch-mode-map (kbd "C-h") #'isearch-delete-char)

    (electric-pair-mode)
  '';
in (pkgs.emacsPackagesGen pkgs.emacs-nox).emacsWithPackages (epkgs: (with epkgs; [
  config nix-mode
]))
