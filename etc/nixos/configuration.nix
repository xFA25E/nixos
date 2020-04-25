# MBR
# parted /dev/sda -- mklabel msdos
# parted /dev/sda -- mkpart primary 1MiB -40GiB
# parted /dev/sda -- mkpart primary linux-swap -40GiB 100%
# mkfs.ext4 -L nixos /dev/sda1
# mkswap -L swap /dev/sda2
# mount /dev/disk/by-label/nixos /mnt
# swapon /dev/sda2
# nixos-generate-config --root /mnt

# UEFI
# parted /dev/sda -- mklabel gpt
# parted /dev/sda -- mkpart primary 512MiB -40GiB
# parted /dev/sda -- mkpart primary linux-swap -40GiB 100%
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

# nixos-install
# reboot

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = true;

  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "nixos"; # Define your hostname.
  networking.wireless.enable = true;


  console.font = "Lat2-Terminus16";
  console.keyMap = "dvorak";
  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Rome";

  # $ nix search wget
  environment.systemPackages = with pkgs; [
    checkbashisms
    conky
    dash
    emacs
    fd
    file
    fzf
    git
    htop
    leiningen
    mpd
    mpop
    mpv
    msmtp
    qutebrowser
    ripgrep
    rofi
    rxvt_unicode
    sbcl
    shellcheck
    stalonetray
    sxhkd
    twmn
    xbindkeys
    youtube-dl
    zathura
  ];

  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  security.sudo.enable = true;
  security.sudo.configFile = ''
    %wheel ALL=(ALL) ALL
  '';

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;
  services.xserver.displayManager.defaultSession = "none";
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.windowManager.bspwm.enable = true;
  services.xserver.layout = "dvorak";
  services.xserver.xkbOptions = "ctrl:nocaps";
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.val = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?

  # uefi
  # boot.loader.systemd-boot.enable = true;

  # virtualbox
  # virtualisation.virtualbox.guest.enable = true;
  # services.openssh.enable = true;
  # services.openssh.permitRootLogin = "yes";

}
