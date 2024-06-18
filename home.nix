let
  # use a specific version of unstable to use features like github copilot in vscode
  unstable = import (builtins.fetchTarball{
    url = "https://github.com/NixOS/nixpkgs/tarball/c75037bbf9093a2acb617804ee46320d6d1fea5a";
    sha256 = "1hs4rfylv0f1sbyhs1hf4f7jsq4np498fbcs5xjlmrkwhx4lpgmc";
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

  home.stateVersion = "23.05";
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
      jnoortheen.nix-ide
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
      bradlc.vscode-tailwindcss
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
        open_help: Some(( code: F(1), modifiers: ( bits: 0,),)),

        move_left: Some(( code: Char('h'), modifiers: ( bits: 0,),)),
        move_right: Some(( code: Char('l'), modifiers: ( bits: 0,),)),
        move_up: Some(( code: Char('k'), modifiers: ( bits: 0,),)),
        move_down: Some(( code: Char('j'), modifiers: ( bits: 0,),)),
    
        popup_up: Some(( code: Char('p'), modifiers: ( bits: 2,),)),
        popup_down: Some(( code: Char('n'), modifiers: ( bits: 2,),)),
        page_up: Some(( code: Char('b'), modifiers: ( bits: 2,),)),
        page_down: Some(( code: Char('f'), modifiers: ( bits: 2,),)),
        home: Some(( code: Char('g'), modifiers: ( bits: 0,),)),
        end: Some(( code: Char('G'), modifiers: ( bits: 1,),)),
        shift_up: Some(( code: Char('K'), modifiers: ( bits: 1,),)),
        shift_down: Some(( code: Char('J'), modifiers: ( bits: 1,),)),

        edit_file: Some(( code: Char('I'), modifiers: ( bits: 1,),)),

        status_reset_item: Some(( code: Char('U'), modifiers: ( bits: 1,),)),

        diff_reset_lines: Some(( code: Char('u'), modifiers: ( bits: 0,),)),
        diff_stage_lines: Some(( code: Char('s'), modifiers: ( bits: 0,),)),

        stashing_save: Some(( code: Char('w'), modifiers: ( bits: 0,),)),
        stashing_toggle_index: Some(( code: Char('m'), modifiers: ( bits: 0,),)),

        stash_open: Some(( code: Char('l'), modifiers: ( bits: 0,),)),

        abort_merge: Some(( code: Char('M'), modifiers: ( bits: 1,),)),
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
  };
}
