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

  boot.loader = {
    grub = {
      enable = true;
      version = 2;
      # efiSupport = true; # uefi
      # Define on which hard drive you want to install Grub.
      device = "/dev/sda";
    };
    # systemd-boot.enable = true; # uefi
  };

  networking = {
    hostName = "nixos";
    wireless.enable = true;
    networkmanager.enable = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak";
  };

  time.timeZone = "Europe/Rome";

  environment.systemPackages = with pkgs; [];

  services = {
    xserver = {
      enable = true;
      layout = "dvorak,ru";
      xkbVariant = ",ruu";
      xkbOptions = "ctrl:swapcaps,grp:shifts_toggle";
      libinput.enable = true;
      # windowManager.stumpwm.enable = true;
      displayManager = {
        startx.enable = true;
        defaultSession = "none";
      };
    };

    # openssh = {
    #   enable = true;
    #   permitRootLogin = "yes";
    # };
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # mkpasswd -m sha-512 -s
  users = let secrets = import ./secrets.nix;
          in {
            defaultUserShell = pkgs.dash;
            mutableUsers = false;
            users = {
              root.hashedPassword = secrets.root.hashedPassword;
              val = {
                hashedPassword = secrets.val.hashedPassword;
                isNormalUser = true;
                uid = 1000;
                extraGroups = [ "video" "wheel" "networkmanager" "audio"];
                shell = pkgs.dash;
                openssh.authorizedKeys = {
                  keys = [];
                  keyFiles = [];
                };
              };
            };
          };


  security.sudo.configFile = ''
    %wheel ALL=(ALL) ALL
  '';

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  # virtualisation.virtualbox.guest.enable = true; # virtalbox

}
