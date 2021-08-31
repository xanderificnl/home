{ config, pkgs, ... }:

let
  zig        = pkgs.vimUtils.buildVimPlugin {
    name     = "zig";
    src      = pkgs.fetchFromGitHub {
      owner  = "ziglang";
      repo   = "zig.vim";
      rev    = "fb534e7d12be7e529f79ad5ab99c08dc99f53294";
      sha256 = "17dpkkgazrzym2yqhb6r07y3hxl3hq9yzwkrb1zii94ss4d8lhw9";
      # nix-prefetch-url --unpack "https://github.com/ziglang/zig.vim/archive/fb534e7d12be7e529f79ad5ab99c08dc99f53294.tar.gz"
    };
  };
in
  {
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      rainbow_parentheses
      vim-indent-guides
      gruvbox
      vim-nix
      rust-vim
      vim-toml
      vim-json
      syntastic
      vim-markdown
      tabular
      zig
      nvim-treesitter
      (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
      lualine-nvim
      nvim-web-devicons
      emmet-vim
    ];
    extraConfig = ''
      colorscheme gruvbox
      set background=dark
      let g:gruvbox_invert_indent_guides=1

      set syntax
      filetype plugin indent on

      "set number
      set relativenumber

      " syntastic
      set statusline+=%#warningmsg#
      set statusline+=%{SyntasticStatuslineFlag()}
      set statusline+=%*

      let g:syntastic_always_populate_loc_list = 1
      let g:syntastic_auto_loc_list            = 1
      let g:syntastic_check_on_open            = 1
      let g:syntastic_check_on_wq              = 0

      " rust
      let g:rustfmt_autosave = 1

      " When reopening a file, return to the last opened line.
      if has("autocmd")
        au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
      endif

      " Markdown
      let g:vim_markdown_frontmatter      = 1
      let g:vim_markdown_toml_frontmatter = 1
      let g:vim_markdown_json_frontmatter = 1

      " lua
      lua require('lualine').setup()
      lua require'nvim-web-devicons'.get_icons()
    '';
  };
}
