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
      nvim-compe
      vim-vsnip
      nvim-lspconfig
      lspsaga-nvim
      hop-nvim
      vim-racket
      vim-sandwich
    ];
    extraConfig = ''
      colorscheme gruvbox
      set background=dark
      let g:gruvbox_invert_indent_guides=1
      set pastetoggle=<F2>

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

      " Compe
      set completeopt=menuone,noselect

      highlight link CompeDocumentation NormalFloat

      inoremap <silent><expr> <C-Space> compe#complete()
      inoremap <silent><expr> <CR>      compe#confirm('<CR>')
      inoremap <silent><expr> <C-e>     compe#close('<C-e>')
      inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
      inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })

      lua <<EOF
      require'compe'.setup {
        enabled = true;
        autocomplete = true;
        debug = false;
        min_length = 1;
        preselect = 'enable';
        throttle_time = 80;
        source_timeout = 200;
        resolve_timeout = 800;
        incomplete_delay = 400;
        max_abbr_width = 100;
        max_kind_width = 100;
        max_menu_width = 100;

        documentation = {
          border = { "", "" ,"", " ", "", "", "", " " }, -- the border option is the same as `|help nvim_open_win|`
          winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
          max_width = 120,
          min_width = 60,
          max_height = math.floor(vim.o.lines * 0.3),
          min_height = 1,
        };

        source = {
          path = true;
          buffer = true;
          calc = true;
          nvim_lsp = true;
          nvim_lua = true;
          vsnip = true;
          ultisnips = true;
          luasnip = true;
        };
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = {
          'documentation',
          'detail',
          'additionalTextEdits',
        }
      }

      require'lspconfig'.rust_analyzer.setup {
        capabilities = capabilities,
      }

      local t = function(str)
        return vim.api.nvim_replace_termcodes(str, true, true, true)
      end

      local check_back_space = function()
          local col = vim.fn.col('.') - 1
          return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
      end

      -- Use (s-)tab to:
      --- move to prev/next item in completion menuone
      --- jump to prev/next snippet's placeholder
      _G.tab_complete = function()
        if vim.fn.pumvisible() == 1 then
          return t "<C-n>"
        elseif vim.fn['vsnip#available'](1) == 1 then
          return t "<Plug>(vsnip-expand-or-jump)"
        elseif check_back_space() then
          return t "<Tab>"
        else
          return vim.fn['compe#complete']()
        end
      end
      _G.s_tab_complete = function()
        if vim.fn.pumvisible() == 1 then
          return t "<C-p>"
        elseif vim.fn['vsnip#jumpable'](-1) == 1 then
          return t "<Plug>(vsnip-jump-prev)"
        else
          -- If <S-Tab> is not working in your terminal, change it to <C-h>
          return t "<S-Tab>"
        end
      end

      vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
      vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
      vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
      vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
      
      vim.api.nvim_set_keymap("i", "<CR>", "compe#confirm({ 'keys': '<CR>', 'select': v:true })", { expr = true })
      EOF

      " lspsaga-nvim
      nnoremap <silent> gh <cmd>lua require'lspsaga.provider'.lsp_finder()<CR>
      nnoremap <silent><leader>ca <cmd>lua require('lspsaga.codeaction').code_action()<CR>
      vnoremap <silent><leader>ca :<C-U>lua require('lspsaga.codeaction').range_code_action()<CR>
      nnoremap <silent> K <cmd>lua require('lspsaga.hover').render_hover_doc()<CR>
      nnoremap <silent> <C-f> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>
      nnoremap <silent> <C-b> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>
      nnoremap <silent> gs <cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>
      nnoremap <silent>gr <cmd>lua require('lspsaga.rename').rename()<CR>
      nnoremap <silent> gd <cmd>lua require'lspsaga.provider'.preview_definition()<CR>
      nnoremap <silent><leader>cd <cmd>lua
      nnoremap <silent> <leader>cd :Lspsaga show_line_diagnostics<CR>
      nnoremap <silent> [e <cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<CR>
      nnoremap <silent> ]e <cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>

      lua << EOF
      local saga = require 'lspsaga'
      saga.init_lsp_saga()
      EOF

      " hop-nvim
      lua << EOF
      require'hop'.setup()
      vim.api.nvim_set_keymap('n', 'f', "<cmd>lua require'hop'.hint_words()<cr>", {})
      EOF

      " Solargraph
      lua << EOF
        require'lspconfig'.solargraph.setup{}
      EOF
    '';
  };
}
