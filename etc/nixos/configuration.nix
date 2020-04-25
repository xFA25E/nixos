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
  boot.loader.grub.efiSupport = true;
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
    checkbashisms conky dash emacs fd file fzf git htop leiningen mpd mpop mpv
    msmtp qutebrowser ripgrep rofi rxvt_unicode sbcl shellcheck stalonetray
    sxhkd twmn xbindkeys youtube-dl
    # zathura                     # disabled because stem package is broken
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
  services.xserver.layout = "dvorak";
  services.xserver.xkbOptions = "ctrl:nocaps";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.startx.enable = true;
  services.xserver.displayManager.defaultSession = "none";
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.windowManager.bspwm.enable = true;

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
