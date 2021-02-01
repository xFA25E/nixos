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

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    checkbashisms
    dash
    dejavu-fonts
    dmenu
    emacs
    fd
    feh
    file
    firefox
    git
    gnupg
    hack-font
    htop
    iosevka
    jq
    ledger
    leiningen
    libfixposix
    libreoffice-7.0.3.1
    mpc
    mpd
    mpop
    mpv
    msmtp
    mtpfs
    mu
    p7zip
    pass-otp
    password-store
    pcre
    pcre2
    pinentry
    pueue
    pulsemixer
    pwgen
    qrencode
    qtox
    qutebrowser
    ripgrep
    rsync
    rustup
    sbcl
    sdcv
    shellcheck
    simplescreenrecorder
    sloccount
    speedtest-cli
    stalonetray
    stow
    sxiv
    syncthing
    transmission
    ungoogled-chromium
    woof
    xclip
    xz
    youtube-dl
    zip
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "gnome3";
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # services.openssh.permitRootLogin = "yes";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "dvorak,ru";
  services.xserver.xkbVariant = ",ruu"
  services.xserver.xkbOptions = "ctrl:swapcaps,grp:shifts_toggle";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.startx.enable = true;
  services.xserver.displayManager.defaultSession = "none";
  services.xserver.windowManager.stumpwm.enable = true;

  # users = let secrets = import ./secrets.nix;
  #         in {
  #           defaultUserShell = pkgs.zsh;
  #           mutableUsers = false;
  #           users.root.hashedPassword = secrets.root.hashedPassword;
  #           extraUsers.adomas = {
  #             hashedPassword = secrets.adomas.hashedPassword;
  #             isNormalUser = true;
  #             uid = 1000;
  #             extraGroups = [ "video" "wheel" ];
  #             shell = pkgs.zsh;
  #           };
  #         };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.val = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

  security.sudo.configFile = ''
    %wheel ALL=(ALL) ALL
  '';

  # virtualisation.virtualbox.guest.enable = true; # virtalbox

}
