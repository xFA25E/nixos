# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# MBR
# parted /dev/sda -- mklabel msdos
# parted /dev/sda -- mkpart primary 1MiB -2GiB
# parted /dev/sda -- mkpart primary linux-swap -2GiB 100%
# mkfs.ext4 -L nixos /dev/sda1
# mkswap -L swap /dev/sda2
# mount /dev/disk/by-label/nixos /mnt
# swapon /dev/sda2
# nixos-generate-config --root /mnt

# UEFI
# parted /dev/sda -- mklabel gpt
# parted /dev/sda -- mkpart primary 512MiB -8GiB
# parted /dev/sda -- mkpart primary linux-swap -8GiB 100%
# parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
# parted /dev/sda -- set 3 boot on
# mkfs.ext4 -L nixos /dev/sda1
# mkswap -L swap /dev/sda2
# mkfs.fat -F 32 -n boot /dev/sda3
# mount /dev/disk/by-label/nixos /mnt
# mkdir -p /mnt/boot
# mount /dev/disk/by-label/boot /mnt/boot
# swapon /dev/sda2
# nixos-generate-config --root /mnt

# END
# nixos-install
# reboot

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true; # uefi
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";
  # boot.loader.systemd-boot.enable = true; # uefi

  networking.hostName = "nixos";
  networking.wireless.enable = true;
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak";
  };

  time.timeZone = "Europe/Rome";

  environment.systemPackages = with pkgs; [
    checkbashisms dash dejavu_fonts dmenu emacs fd feh file firefox git gnupg
    hack-font htop iosevka jq ledger leiningen libfixposix libreoffice-fresh
    mpc_cli mpd mpop mpv msmtp mtpfs mu p7zip pass-otp pass pcre pcre2 pinentry
    pueue pulsemixer pwgen qrencode qtox qutebrowser ripgrep rsync rustup sbcl
    sdcv shellcheck simplescreenrecorder sloccount speedtest-cli stalonetray
    stow sxiv syncthing tdesktop transmission ungoogled-chromium woof xclip xz
    youtube-dl zip
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "gnome3";
  };

  # services.openssh.enable = true;
  # services.openssh.permitRootLogin = "yes";

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver.enable = true;
  services.xserver.layout = "dvorak,ru";
  services.xserver.xkbVariant = ",ruu"
  services.xserver.xkbOptions = "ctrl:swapcaps,grp:shifts_toggle";

  services.xserver.libinput.enable = true;

  services.xserver.displayManager.startx.enable = true;
  services.xserver.displayManager.defaultSession = "none";
  # services.xserver.windowManager.stumpwm.enable = true;

  # mkpasswd --method=sha-512 --stdin
  users = let secrets = import ./secrets.nix;
          in {
            defaultUserShell = pkgs.dash;
            mutableUsers = false;
            users.root.hashedPassword = secrets.root.hashedPassword;
            users.val = {
              hashedPassword = secrets.val.hashedPassword;
              isNormalUser = true;
              uid = 1000;
              extraGroups = [ "video" "wheel" "networkmanager" "audio"];
              shell = pkgs.dash;
              openssh.authorizedKeys.keys = [];
              openssh.authorizedKeys.keyFiles = [];
            };
          };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  security.sudo.configFile = ''
    %wheel ALL=(ALL) ALL
  '';

  # virtualisation.virtualbox.guest.enable = true; # virtalbox

}
