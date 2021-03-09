{ pkgs ? import <nixpkgs> {} }:
let
  config = pkgs.writeText "default.el" ''
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
in pkgs.emacsWithPackages (epkgs: (with epkgs.melpaPackages; [
  (pkgs.runCommand "default.el" {} ''
    mkdir -p $out/share/emacs/site-lisp
    cp ${config} $out/share/emacs/site-lisp/default.el
'')
  nix-mode
]))
