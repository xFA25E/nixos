# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

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

  nix.trustedUsers = [ "root" "val" ];

  # mkpasswd -m sha-512 -s
  users = let
    password = import ./secrets.nix;
  in {
    defaultUserShell = pkgs.dash;
    mutableUsers = false;
    users = {
      val = {
        hashedPassword = password;
        isNormalUser = true;
        uid = 1000;
        extraGroups = [ "video" "wheel" "networkmanager" "audio" ];
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
