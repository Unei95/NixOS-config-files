let
  # use a specific version of unstable to use features like github copilot in vscode
  unstable = import (builtins.fetchTarball{
    url = "https://github.com/NixOS/nixpkgs/tarball/36fd87baa9083f34f7f5027900b62ee6d09b1f2f";
    sha256 = "0b56iwbr9cwakzzs4n9k6nacgzk3j81vx2spc8m6w6vvv2qdw7js";
  }) {config = {allowUnfree = true;};};
in 
#testcomment
{ pkgs, ... }: {
  home.username = "unei";
  home.homeDirectory = "/home/unei";

  home.packages = with pkgs; [
    #Editor/Terminal
    neovim
    wl-clipboard #needed for helix copy/paste
    nnn
    htop
    avrdude
    ripgrep
    alacritty
    gh
 
    # stuff for zsh
    zoxide # also referenced in zsh config
    fzf

    # misc dependencies
    nil # nix lsp
    python3Full # Needed for PlatformIO in vscode
    virtualenv # Needed for PlatformIO? -> probably both unnecessary since I use PlatformIO on cli for Marlin
    xsel # needed for hx to interact with the x11 clipboard
    xclip

    #Sysadmin stuff
    man-pages
  ];

  home.stateVersion = "24.11";
  programs.home-manager.enable = true; # tbh I don't know if I need this one.

  # if used in a nixOS environment you have to set the following options:
  # programs.zsh.enable = true;
  # users.users.USERNAME.shell = pkgs.zsh;
  # otherwise zsh won't be set as the defaultShell for the user
  # side effect: 'whereis zsh' spits out two store paths
  # /etc/shells also contains multiple zsh entries
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "arrow";
      plugins = [
        "zoxide"
        "fzf"
      ];
    };

    initExtra = ''
	n ()
	{
	    # Block nesting of nnn in subshells
	    [ "''${NNNLVL:-0}" -eq 0 ] || {
		echo "nnn is already running"
		return
	    }

	    # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
	    # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
	    # see. To cd on quit only on ^G, remove the "export" and make sure not to
	    # use a custom path, i.e. set NNN_TMPFILE *exactly* as follows:
	    #      NNN_TMPFILE="''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
	    export NNN_TMPFILE="''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

	    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
	    # stty start undef
	    # stty stop undef
	    # stty lwrap undef
	    # stty lnext undef

	    # The command builtin allows one to alias nnn to n, if desired, without
	    # making an infinitely recursive alias
	    command nnn "$@"

	    [ ! -f "$NNN_TMPFILE" ] || {
		. "$NNN_TMPFILE"
		rm -f -- "$NNN_TMPFILE" > /dev/null
	    }
	}
    '';
  };

  programs.helix = {
    enable = true;
    package = unstable.helix;
    settings = {
      theme = "gruvbox_dark_hard";

      editor = {
        line-number = "relative";
        mouse = false;
      };

      editor.whitespace = {
        render = "all";
      };
    };
  };

  programs.vscode = {
    enable = true;
    package = unstable.vscode;
    extensions = with unstable.vscode-extensions; [
      vscodevim.vim
      github.copilot
      github.copilot-chat
      github.vscode-github-actions
      jnoortheen.nix-ide
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
      bradlc.vscode-tailwindcss
      vadimcn.vscode-lldb
    ];

    keybindings = [
      {
        key = "ctrl+f";
        command = "-workbench.action.terminal.focusFind";
        when = "terminalFindFocused && terminalHasBeenCreated || terminalFindFocused && terminalProcessSupported || terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
      }
    ];

    userSettings = import ./vscode-usersettings.nix;   
  };

  programs.git = {
    enable = true;
    userName = "Mattis Sievers";
    userEmail = "mattis.sievers@pm.me";
  };

  programs.gitui = {
    enable = true;
    # taken from https://github.com/extrawurst/gitui/blob/master/vim_style_key_config.ron
    keyConfig = 
''
(
  move_left: Some(( code: Char('h'), modifiers: "")),
  move_right: Some(( code: Char('l'), modifiers: "")),
  move_up: Some(( code: Char('k'), modifiers: "")),
  move_down: Some(( code: Char('j'), modifiers: "")),

  stash_open: Some(( code: Char('l'), modifiers: "")),
  open_help: Some(( code: F(1), modifiers: "")),

  status_reset_item: Some(( code: Char('U'), modifiers: "SHIFT")),
)
''; 
  };

  programs.zellij = {
    enable = true;
    enableZshIntegration = true; 
  };

  home.sessionVariables = {
    # needed, since programs.helix.defaultEditor = true;
    # is not available in home-manager 23.05
    EDITOR = "nvim";

    # needed for rust-analyzer
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };
}
