{ config, pkgs, ... }:
let intero-neovim = pkgs.vimUtils.buildVimPlugin {
    name = "intero-neovim";
    src = pkgs.fetchFromGitHub {
      owner = "parsonsmatt";
      repo = "intero-neovim";
      rev = "26d340ab0d6e8d40cbafaf72dac0588ae901c117";
      sha256 = "0y4bbbj6v9jq825ffpdx03hi6ldszqh2zxasc6h1b0vkpjmdc8y3";
    };
  };
in {
  nix.binaryCaches = [
    "https://cache.nixos.org/"
    "https://build.daiseelabs.com/"
  ];
  nix.binaryCachePublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "build.daiseelabs.com-1:dcDJ5/wXMie1xvW/o5TfedvVIqKG77i3dpKfamBJg8M="
  ];
  nixpkgs.config.allowUnfree = true; 
  imports =
    [
      ./hardware-configuration.nix
    ];

  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "colemak/en-latin9";
    defaultLocale = "en_AU.UTF-8";
  };


  networking = {
    hostName = "carbon";
    wireless.enable = true;
    firewall = { 
      allowedTCPPorts = [  ];
    };
  };
  time.timeZone = "Australia/Sydney";

  environment = {
    systemPackages = with pkgs; [
    i3 i3lock compton
    git
    neovim google-chrome
    screen
    binutils
    rxvt_unicode
    acpi
    hackrf
    stack
    ghc
    stdenv
    ];
    shellAliases = { vim = "nvim"; };
  };

  sound.enable = true;

  programs.vim.defaultEditor = true;
  # programs.ssh.startAgent = true;
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;

  fonts = {
    fonts = with pkgs; [
      corefonts
      ubuntu_font_family
      terminus_font
      terminus_font_ttf
      freetype_subpixel
    ];
  };

  programs.zsh.enable = true;
  virtualization.libvirt.enable = true;

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  boot = {
    kernelParams = [ "acpi.ec_no_wakeup=1 psmouse.synaptics_intertouch=1" ];
    kernelModules = ["i2c_i801" "elan_i2c" "rmi_smbus"  "kvm_intel"];
    
    
    loader.grub = {
      enable = true;
      version = 2;
      device = "nodev";
      gfxmodeEfi = "2560x1440";
    };


    loader.systemd-boot.enable = true;

    loader.efi.canTouchEfiVariables = true;

    initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/a56d840c-e56c-4d58-b788-471c54b35ed0";
      preLVM = true;
      allowDiscards = true;
    }
    ];
  };

  services.offlineimap = {
    enable = true;
    install = true;
   };
  services.xserver = {
  	autorun = true;
	displayManager.slim = {
	  defaultUser = "christian";

	};

	# synaptics.enable = true;

	libinput = {
	  enable = true;
	  tapping = true;
          disableWhileTyping = true;
	};

	windowManager.i3.enable = true;
	windowManager.default = "i3";
	enable = true;
	layout = "us";
	xkbVariant = "colemak";
  };

  services.sshd.enable = true;
  services.dbus.enable = true;

  # services.ntp.enable = true;

  hardware.trackpoint = {
  	enable = true;
	sensitivity = 255;
	speed = 200;
	emulateWheel = true;
  };

  
  # powerManagement.cpuFreqGovernor = "ondemand";
  powerManagement.enable = true;
  services.tlp.enable = true;
  services.upower.enable = true;

    systemd.user.services.dunst = {
    enable = true;
    description = "Lightweight and customizable notification daemon";
    wantedBy = [ "default.target" ];
    path = [ pkgs.dunst ];
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.dunst}/bin/dunst";
    };
  };

#   systemd.user.services.xcape = {
#     enable = true;
#     description = "xcape to use CTRL as ESC when pressed alone";
#     wantedBy = [ "default.target" ];
#     serviceConfig.Type = "forking";
#     serviceConfig.Restart = "always";
#     serviceConfig.RestartSec = 2;
#     serviceConfig.ExecStart = "${pkgs.xcape}/bin/xcape -e 'ModKey=Shift_L|Escape;'";
#   };

  systemd.user.services.offlineimap.enable = true;

  services.redshift = {
  	enable = true;
	provider = "geoclue2";
  };

  services.postgresql.enable = true;
  hardware.enableAllFirmware = true;
  services.fprintd.enable = true;
        nixpkgs.config.packageOverrides = pkgs: {
        freetype_subpixel = pkgs.freetype.override {
          useEncumberedCode = true;
        };
        neovim = pkgs.neovim.override {
          configure = {
	  customRC = ''
	  set syntax=on
	  set autoindent
	  set autowrite
	  set smartcase
	  set showmode
	  set nowrap
	  set number
	  set nocompatible
	  set tw=80
	  set smarttab
	  set smartindent
	  set incsearch
	  set mouse=a
	  set history=10000
	  set completeopt=menuone,menu,longest
	  set wildignore+=*\\tmp\\*,*.swp,*.swo,*.git
	  set wildmode=longest,list,full
	  set wildmenu
	  set t_Co=512
	  set cmdheight=1
	  set expandtab
	  '';
          packages.neovim2 = with pkgs.vimPlugins; {

          start = [ syntastic vim-nix intero-neovim neomake ctrlp];
          opt = [ ];
        };      
      };

      };
    };
  services.logind.extraConfig = "RuntimeDirectorySize=3G";
  virtualisation.libvirtd.enable = true;
  users.extraUsers.myuser.extraGroups = [ "libvirtd" ];
  networking.firewall.checkReversePath = false;
}
