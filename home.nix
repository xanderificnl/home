{ config, ... }:

let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);

  pkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };

  # https://nixos.wiki/wiki/FAQ#How_can_I_install_a_package_from_unstable_while_remaining_on_the_stable_channel.3F
  pkgsUnstable = import <nixos-unstable> { config = config.nixpkgs.config; };
in {
  imports = [ ./kakoune.nix ./neovim.nix ./tmux.nix ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "xander";
  home.homeDirectory = "/home/xander";

  # nixpkg config
  nixpkgs.config = {
    allowUnfree = true;
    vivaldi = { enableWideVine = true; };
  };

  # Packages
  home.packages = [
    pkgsUnstable.vivaldi
    pkgsUnstable.vivaldi-ffmpeg-codecs
    pkgsUnstable.vivaldi-widevine
    pkgs.sccache
    pkgs.fd
    pkgs.ripgrep
    pkgs.sd
    pkgs.tokei
    pkgs.hyperfine
    pkgs.tealdeer
    pkgs.bandwhich
    pkgs.grex
    pkgs.nixfmt
    pkgs.gh
    pkgs.latest.rustChannels.stable.rust
    pkgs.podman-compose
    pkgsUnstable.jetbrains-mono
    pkgsUnstable.zola
    pkgsUnstable.skim
    pkgsUnstable.rnix-lsp
    pkgsUnstable.file
  ];

  # nix-env -f '<nixpkgs>' -qaP -A kakounePlugins
  # programs.kakoune = {
  #   enable = true;
  #   config = {
  #     colorScheme = "gruvbox";
  #     ui.enableMouse = false;
  #   };
  #   plugins = with pkgsUnstable.kakounePlugins; [
  #     kak-lsp
  #   ];
  #   extraConfig = ''
  #     # LSP
  #     eval %sh{kak-lsp --kakoune -s $kak_session}
  #     hook global WinSetOption filetype=(rust|python|go|javascript|typescript) %{
  #             lsp-enable-window
  #     }

  #     ## Auto format files on save
  #     #hook global WinSetOption filetype=
      
  #   '';
  # };

  nixpkgs.overlays = [ (final: previous: { kitty = pkgsUnstable.kitty; }) ];

  programs.kitty = {
    enable = true;
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
      font_family = "JetBrains Mono";
      disable_ligatures = "cursor";
      #adjust_line_height = "92%";
      hide_window_decorations = "yes";
      font_size = "12.5";
      background = "#272727";
      color0 = "#272727";
      color10 = "#b8ba25";
      color11 = "#fabc2e";
      color12 = "#83a597";
      color13 = "#d3859a";
      color14 = "#8ec07b";
      color15 = "#ebdbb2";
      color1 = "#cc231c";
      color2 = "#989719";
      color3 = "#d79920";
      color4 = "#448488";
      color5 = "#b16185";
      color6 = "#689d69";
      color7 = "#a89983";
      color8 = "#928373";
      color9 = "#fb4833";
      foreground = "#ebdbb2";
      selection_background = "#ebdbb2";
      selection_foreground = "#655b53";
      url_color = "#d65c0d";
    };
  };

  programs.alacritty = {
    enable = false;
    settings = {
      window = {
        decorations = "none";
        startup_mode = "Maximized";
      };
      scrolling = { history = 10000; };
      colors = {
        primary = {
          background = "#1d2021";
          foreground = "#ebdbb2";
          bright_foreground = "#fbf1c7";
          dim_foreground = "#a89984";
        };
        cursor = {
          text = "CellBackground";
          cursor = "CellForeground";
        };
        vi_mode_cursor = {
          text = "CellBackground";
          cursor = "CellForeground";
        };
        selection = {
          text = "CellBackground";
          background = "CellForeground";
        };
        bright = {
          black = "#928374";
          red = "#fb4934";
          green = "#b8bb26";
          yellow = "#fabd2f";
          blue = "#83a598";
          magenta = "#d3869b";
          cyan = "#8ec07c";
          white = "#ebdbb2";
        };
        normal = {
          black = "#1d2021";
          red = "#cc241d";
          green = "#98971a";
          yellow = "#d79921";
          blue = "#458588";
          magenta = "#b16286";
          cyan = "#689d6a";
          white = "#a89984";
        };
        dim = {
          black = "#32302f";
          red = "#9d0006";
          green = "#79740e";
          yellow = "#b57614";
          blue = "#076678";
          magenta = "#8f3f71";
          cyan = "#427b58";
          white = "#928374";
        };
      };
    };
  };

  programs.bash = { enable = true; };

  programs.bat = {
    enable = true;
    config = { theme = "gruvbox-dark"; };
  };

  programs.exa = { enable = true; };

  programs.fzf = { enable = true; };

  # unsuitable due to immutability of ~/.config/gh/
  #programs.gh = {
  #  enable = true;
  #  gitProtocol = "ssh";
  #};

  programs.htop = { enable = true; };

  programs.info = { enable = true; };

  programs.man = { enable = true; };

  # TODO: https://github.com/nix-community/home-manager/blob/master/modules/programs/irssi.nix
  programs.irssi = {
    enable = true;
  };

  programs.jq = { enable = true; };

  programs.nushell = {
    enable = true;
    package = pkgsUnstable.nushell;
    settings = {
      prompt = "printf '\\033k%s\\033\\\\' (pwd | path split | last);starship_prompt";
      startup = [
        "mkdir ~/.cache/starship"
        "starship init nu | save ~/.cache/starship/init.nu"
        "source ~/.cache/starship/init.nu"

        "zoxide init nushell --hook prompt | save ~/.zoxide.nu"
        "source ~/.zoxide.nu"
      ];

      ctrlc_exit = false;
      filesize_format = "mb";
      filesize_metric = false;
      skip_welcome_message = true;
      rm_always_trash = true;
      color_mode = "enabled";

      env = {
        EDITOR = "kak";
        JQ_COLORS = "1;30:0;37:0;37:0;37:0;32:1;37:1;37";
      };


    };
  };

  programs.starship = {
    package = pkgsUnstable.starship;
    enable = true;

    settings = {
      directory = {
        truncation_length = 3;
        truncate_to_repo = false;
      };
    };
  };

  programs.topgrade = { enable = true; };

  programs.zoxide = {
    package = pkgsUnstable.zoxide;
    enable = true;
  };

  programs.lazygit = { enable = true; };

  # Git
  programs.git = {
    enable = true;
    delta.enable = true;

    extraConfig = {
      init = { defaultBranch = "main"; };
      user = {
        name = "Xander";
        email = "xander@web-refinery.com";
      };
      commit = { template = "~/.config/git/commit"; };
      pull = {
        ff = false;
        commit = false;
        rebase = true;
      };
    };
  };
  home.file.".config/git/commit".text = ''
    # vim: ft=markdown tw=72 ts=2: 
    #
    # Summarize changes in around 50 characters or less.
    #
    # Answer this question: If applied, this commit will:


    # More detailed explanatory text, if necessary. Wrap it to about 72
    # characters or so. In some contexts, the first line is treated as the
    # subject of the commit and the rest of the text as the body. The
    # blank line separating the summary from the body is critical (unless
    # you omit the body entirely); various tools like `log`, `shortlog`
    # and `rebase` can get confused if you run the two together.
    #
    # Explain the problem that this commit is solving. Focus on why you
    # are making this change as opposed to how (the code explains that).
    # Are there side effects or other unintuitive consequences of this
    # change? Here's the place to explain them.
    #
    # Further paragraphs come after blank lines.


    # - Bullet points are okay, too
    #
    # - Typically a hyphen or asterisk is used for the bullet, preceded
    #   by a single space, with blank lines in between, but conventions
    #   vary here

    # If you use an issue tracker, put references to them at the bottom,
    # like this:

    # Resolves: #123
    # See also: #456, #789

    # More information here: https://chris.beams.io/posts/git-commit/
      '';

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
