# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot = {
    loader = {
      grub = {
        efiSupport = true; # uefi
        # Define on which hard drive you want to install Grub.
        device = "nodev"; # uefi
      };
      systemd-boot.enable = true; # uefi
      efi.canTouchEfiVariables = true; # uefi
    };
    cleanTmpDir = true;
  };

  networking = {
    firewall.allowedTCPPorts = [ 8080 8000 ];
    hosts = {
      "0.0.0.0" = [
        "rewards.brave.com"
        "api.rewards.brave.com"
        "grant.rewards.brave.com"
        "variations.brave.com"
        "laptop-updates.brave.com"
        "static1.brave.com"
        "brave-core-ext.s3.brave.com"
      ];
    };
    hostFiles = let
      stevenblank = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/StevenBlack/hosts/70884b069ed818c385382f7608e1e28f777cc5f3/alternates/gambling-porn/hosts";
        sha256 = "193wr6grgfz3jwhn2i597k98nmd6chdky1aw64qnlp3ixv5fyvb2";
      };
    in [ "${stevenblank}" ];
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

  # mkpasswd -m sha-512 -s
  users = {
    mutableUsers = false;
    users = {
      val = {
        hashedPassword = import ./secrets.nix;
        isNormalUser = true;
        uid = 1000;
        extraGroups = [ "video" "wheel" "networkmanager" "audio" ];
        openssh.authorizedKeys = {
          keys = [];
          keyFiles = [];
        };
      };
    };

    # extraUsers = let
    #   buildUser = (i: {
    #     "guixbuilder${i}" = {                   # guixbuilder$i
    #       group = "guixbuild";                  # -g guixbuild
    #       extraGroups = ["guixbuild"];          # -G guixbuild
    #       home = "/var/empty";                  # -d /var/empty
    #       shell = pkgs.nologin;                 # -s `which nologin`
    #       description = "Guix build user ${i}"; # -c "Guix buid user $i"
    #       isSystemUser = true;                  # --system
    #     };
    #   }); in
    #   pkgs.lib.fold (str: acc: acc // buildUser str)
    #     {}
    #     (map (pkgs.lib.fixedWidthNumber 2) (builtins.genList (n: n+1) 10));

    # extraGroups.guixbuild = {
    #   name = "guixbuild";
    # };
  };

  security.sudo.configFile = ''
    %wheel ALL=(ALL) ALL
  '';

  systemd.services = {
    "loadkeys" = {
      enable = true;
      description = "Change caps to ctrl";
      wantedBy = [ "default.target" ];
      unitConfig = {
        Type = "oneshot";
      };
      serviceConfig = {
        ExecStart = "${pkgs.kbd}/bin/loadkeys ${./ctrl2caps.map}";
      };
    };

    "guix-daemon" = {
      enable = false;
      description = "Build daemon for GNU Guix";
      serviceConfig = {
        ExecStart = "/var/guix/profiles/per-user/root/current-guix/bin/guix-daemon --build-users-group=guixbuild";
        Environment="GUIX_LOCPATH=/root/.guix-profile/lib/locale";
        RemainAfterExit="yes";
        StandardOutput="syslog";
        StandardError="syslog";
        TaskMax= "8192";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };

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
  # virtualisation.docker.enable = true; # add docker to users
  # virtualisation.docker.enableOnBoot = false;
  # programs.adb.enable = true; # add adbusers to users
}
