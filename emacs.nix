{ pkgs ? import <nixos> {} }:
let
  config = pkgs.writeText "default.el" ''
    (setq make-backup-files nil)
    (defun delete-orig-configuration ()
      (delete-file "/mnt/etc/nixos/orig_configuration.nix"))

    (defun backward-kill-word-or-region (&optional count)
      (interactive "p")
      (if (use-region-p)
          (kill-region (region-beginning) (region-end))
        (backward-kill-word count)))

    (global-set-key (kbd "C-w") #'backward-kill-word-or-region)
    (global-set-key (kbd "C-h") #'backward-delete-char-untabify)
    (define-key isearch-mode-map (kbd "C-h") #'isearch-delete-char)

    (electric-pair-mode)
    (add-hook 'kill-emacs-hook #'delete-orig-configuration)
  '';
in (pkgs.emacsPackagesGen pkgs.emacs-nox).emacsWithPackages (epkgs: (with epkgs.melpaPackages; [
  (pkgs.runCommand "default.el" {} ''
    mkdir -p $out/share/emacs/site-lisp
    cp ${config} $out/share/emacs/site-lisp/default.el
'')
  nix-mode
]))
