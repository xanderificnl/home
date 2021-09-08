{ config, pkgs, ... }:
let
  lsp_languages = "(html|css|json|rust|python|go|javascript|typescript|nix|dart)";
in
{
  # nix-env -f '<nixpkgs>' -qaP -A kakounePlugins
  programs.kakoune = {
    enable = true;
    config = {
      colorScheme = "gruvbox";
      ui.enableMouse = false;
    };
    plugins = with pkgs.kakounePlugins; [ kak-lsp kakoune-state-save ];
    extraConfig = ''
                                 # Escape via jj
                                 hook global InsertChar j %{ try %{
                                 	exec -draft hH <a-k>jj<ret> d
                                 	exec <esc>
                                 }}

                                 # LSP
                                 eval %sh{kak-lsp --kakoune -s $kak_session}
                                 set global lsp_cmd "kak-lsp -s %val{session} -vvv --log /tmp/kak-lsp.log"

                                 hook global WinSetOption filetype=${lsp_languages} %{
                                 	lsp-enable-window
                                 	lsp-auto-hover-enable

                                 	lsp-inlay-diagnostics-enable global
                                 	set global lsp_hover_anchor true

                                 	hook window BufWritePre .* lsp-formatting-sync 

                                 	map global user l %{: enter-user-mode lsp<ret> } -docstring "LSP mode"
                        	   	map global normal <c-l> %{: enter user-mode lsp<ret> } -docstring "LSP mode"
                                	map global lsp t %{: lsp-type-definition<ret> }
                                 }

                                 # Respect editor conf
                                 hook global BufOpenFile .* editorconfig-load
                                 hook global BufNewFile .* editorconfig-load

                                 # Auto complete mappings
                                 hook global InsertCompletionShow .* %{ map window insert <tab> <c-n>; map window insert <s-tab> <c-p> }
                                 hook global InsertCompletionHide .* %{ unmap window insert <tab> <c-n>; unmap window insert <s-tab> <c-p> }

                                 # General mappings
                                 map global normal '#' ': comment-line<ret>' -docstring "comment line"
                                 map global normal '<a-#>' ': comment-block<ret>' -docstring "comment block"

                                 # Buffers
                                 map global goto 'z' '<esc>: buffer-previous<ret>' -docstring "previous buffer"
                                 map global goto 'x' '<esc>: buffer-next<ret>' -docstring "next buffer"

                                 # Kakoune, be awesome.
                                 
                  		def ide %{
                                      # rename-client main 		# 0
                                      # new rename-client docs 	# 1
                                      # new rename-client tools 	# 2
                                      # set global docsclient docs
                                      # set global toolsclient tools
                                      # set global jumpclient main
                                      #

                                      rename-client main 		# 0
                                      new rename-client tools 		# 2
                                      new rename-client docs 		# 1
            				
                                      nop %sh{
                                          if [[ -n $TMUX ]]; then
                                              tmux select-layout tiled
                                              tmux move-pane -s 2 -t 1
                                              tmux resize-pane -t 0 -x 60%
                                              #tmux resize-pane -t 1 -y 20%
                                              #tmux resize-pane -t 2 -x 10%
                                              tmux select-pane -t 0
                                          fi
                                      }

      				hook global WinClose .* %{
          					nop %sh{
              					if [[ -n $TMUX ]]; then
              						tmux kill-window
              					fi
          					}
      				}
      				
                                      #def ide-place-tmux-shell-pane %{ %sh{
                                      #    tmux move-pane -s 3 -t 1
                                      #    tmux resize-pane -t 2 -y 20
                                      #    tmux select-pane -t 0
                                      #} }

                                      #unmap global normal wq; map global normal wq '<esc>:write; :kill' -docstring "write buffer and kill window"
                  		}

                                     
                                


    '';
  };
  home.file.".config/kak-lsp/kak-lsp.toml".text = ''
    snippet_support = false
    verbosity = 2

    # Semantic tokens support
    # See https://github.com/microsoft/vscode-languageserver-node/blob/8c8981eb4fb6adec27bf1bb5390a0f8f7df2899e/client/src/semanticTokens.proposed.ts#L288
    # for token/modifier types.

    [semantic_tokens]
    type = "type"
    variable = "variable"
    namespace = "module"
    function = "function"
    string = "string"
    keyword = "keyword"
    operator = "operator"
    comment = "comment"

    [semantic_token_modifiers]
    documentation = "documentation"
    readonly = "default+d"

    [server]
    # exit session if no requests were received during given period in seconds
    # works only in unix sockets mode (-s/--session)
    # set to 0 to disable
    timeout = 1800 # seconds = 30 minutes

    [language.bash]
    filetypes = ["sh"]
    roots = [".git", ".hg"]
    command = "bash-language-server"
    args = ["start"]

    [language.c_cpp]
    filetypes = ["c", "cpp"]
    roots = ["compile_commands.json", ".clangd"]
    command = "clangd"
    offset_encoding = "utf-8"

    [language.crystal]
    filetypes = ["crystal"]
    roots = ["shard.yml"]
    command = "scry"

    [language.css]
    filetypes = ["css"]
    roots = ["package.json", ".git"]
    command = "css-languageserver"
    args = ["--stdio"]

    [language.less]
    filetypes = ["less"]
    roots = ["package.json", ".git"]
    command = "css-languageserver"
    args = ["--stdio"]

    [language.scss]
    filetypes = ["scss"]
    roots = ["package.json", ".git"]
    command = "css-languageserver"
    args = ["--stdio"]

    [language.d]
    filetypes = ["d", "di"]
    roots = [".git", "dub.sdl", "dub.json"]
    command = "dls"

    [language.dart]
    # start shell to find path to dart analysis server source
    filetypes = ["dart"]
    roots = ["pubspec.yaml", ".git"]
    command = "sh"
    args = ["-c", "dart $(dirname $(command -v dart))/snapshots/analysis_server.dart.snapshot --lsp"]

    [language.elixir]
    filetypes = ["elixir"]
    roots = ["mix.exs"]
    command = "elixir-ls"
    settings_section = "elixirLS"
    [language.elixir.settings.elixirLS]
    # See https://github.com/elixir-lsp/elixir-ls/blob/master/apps/language_server/lib/language_server/server.ex
    # dialyzerEnable = true

    [language.elm]
    filetypes = ["elm"]
    roots = ["elm.json"]
    command = "elm-language-server"
    args = ["--stdio"]
    settings_section = "elmLS"
    [language.elm.settings.elmLS]
    # See https://github.com/elm-tooling/elm-language-server#server-settings
    runtime = "node"
    elmPath = "elm"
    elmFormatPath = "elm-format"
    elmTestPath = "elm-test"

    [language.go]
    filetypes = ["go"]
    roots = ["Gopkg.toml", "go.mod", ".git", ".hg"]
    command = "gopls"
    offset_encoding = "utf-8"
    settings_section = "gopls"
    [language.go.settings.gopls]
    # See https://github.com/golang/tools/blob/master/gopls/doc/settings.md
    # "build.buildFlags" = []

    [language.haskell]
    filetypes = ["haskell"]
    roots = ["Setup.hs", "stack.yaml", "*.cabal"]
    command = "haskell-language-server-wrapper"
    args = ["--lsp"]
    settings_section = "haskell"
    [language.haskell.settings.haskell]
    # See https://github.com/latex-lsp/texlab/blob/e1ee8495b0f54b4411a1ffacf787efa621d8f826/src/options.rs
    # formattingProvider = "ormolu"

    [language.html]
    filetypes = ["html"]
    roots = ["package.json"]
    command = "html-languageserver"
    args = ["--stdio"]

    # # Commented out by default because you still need to set the paths in the JDT
    # # Language Server arguments below before this can become a valid configuration.
    # [language.java]
    # filetypes = ["java"]
    # roots = [".git", "mvnw", "gradlew"]
    # command = "java"
    # args = [
    #     "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    #     "-Dosgi.bundles.defaultStartLevel=4",
    #     "-Declipse.product=org.eclipse.jdt.ls.core.product",
    #     "-Dlog.level=ALL",
    #     "-Dfile.encoding=utf-8",
    #     "--add-modules=ALL-SYSTEM",
    #     "--add-opens",
    #     "java.base/java.util=ALL-UNNAMED",
    #     "--add-opens",
    #     "java.base/java.lang=ALL-UNNAMED",
    #     "-noverify",
    #     "-Xmx1G",
    #     "-jar",
    #     "/path/to/eclipse.jdt.ls/repository/plugins/org.eclipse.equinox.launcher_1.6.100.v20201223-0822.jar",
    #     "-configuration",
    #     "/path/to/eclipse.jdt.ls/repository/config_linux",
    #     "-data",
    #     "/path/to/eclipse-workspace",
    # ]
    # [language.java.settings]
    # # See https://github.dev/eclipse/eclipse.jdt.ls
    # # "java.format.insertSpaces" = true

    #[language.javascript]
    #filetypes = ["javascript"]
    #roots = [".flowconfig"]
    #command = "flow"
    #args = ["lsp"]

    [language.json]
    filetypes = ["json"]
    roots = ["package.json"]
    command = "json-languageserver"
    args = ["--stdio"]

    # Requires Julia packages "LanguageServer", "StaticLint" and "SymbolServer"
    [language.julia]
    filetypes = ["julia"]
    roots = ["Project.toml", ".git"]
    command = "julia"
    args = [
        "--startup-file=no",
        "--history-file=no",
        "-e",
        """
            using LanguageServer;
            using Pkg;
            import StaticLint;
            import SymbolServer;
            import REPL;
            env_path = dirname(Pkg.Types.Context().env.project_file);
            server = LanguageServer.LanguageServerInstance(stdin, stdout, env_path, "");
            server.runlinter = true;
            run(server);
        """,
    ]
    [language.julia.settings]
    # See https://github.com/julia-vscode/LanguageServer.jl/blob/master/src/requests/workspace.jl
    # Format options. See https://github.com/julia-vscode/DocumentFormat.jl/blob/master/src/DocumentFormat.jl
    # "julia.format.indent" = 4
    # Lint options. See https://github.com/julia-vscode/StaticLint.jl/blob/master/src/linting/checks.jl
    # "julia.lint.call" = true
    # Other options, see https://github.com/julia-vscode/LanguageServer.jl/blob/master/src/requests/workspace.jl
    # "julia.lint.run" = "true"

    [language.latex]
    filetypes = ["latex"]
    roots = [".git"]
    command = "texlab"
    settings_section = "texlab"
    [language.latex.settings.texlab]
    # See https://github.com/latex-lsp/texlab/blob/master/src/options.rs
    # bibtexFormatter = "texlab"

    [language.lua]
    filetypes = ["lua"]
    roots = [".git"]
    command = "lua-language-server"
    [language.lua.settings]
    # See https://github.com/sumneko/vscode-lua/blob/master/setting/schema.json
    # "Lua.diagnostics.enable" = true

    [language.nim]
    filetypes = ["nim"]
    roots = ["*.nimble", ".git"]
    command = "nimlsp"

    [language.nix]
    filetypes = ["nix"]
    roots = ["flake.nix", "shell.nix", ".git"]
    command = "rnix-lsp"

    [language.ocaml]
    filetypes = ["ocaml"]
    roots = ["Makefile", "opam", "*.opam", "dune"]
    command = "ocamllsp"

    [language.php]
    filetypes = ["php"]
    roots = [".htaccess", "composer.json"]
    command = "intelephense"
    args = ["--stdio"]
    settings_section = "intelephense"
    [language.php.settings]
    intelephense.storagePath = "/tmp/intelephense"

    [language.python]
    filetypes = ["python"]
    roots = ["requirements.txt", "setup.py", ".git", ".hg"]
    command = "pyls"
    offset_encoding = "utf-8"
    [language.python.settings]
    # See https://github.com/palantir/python-language-server#configuration
    # and https://github.com/palantir/python-language-server/blob/develop/vscode-client/package.json
    # "pyls.configurationSources" = ["flake8"]

    [language.reason]
    filetypes = ["reason"]
    roots = ["package.json", "Makefile", ".git", ".hg"]
    command = "ocamllsp"

    [language.ruby]
    filetypes = ["ruby"]
    roots = ["Gemfile"]
    command = "solargraph"
    args = ["stdio"]
    [language.ruby.settings]
    # See https://github.com/castwide/solargraph/blob/master/lib/solargraph/language_server/host.rb
    # "solargraph.completion" = true

    [language.rust]
    filetypes = ["rust"]
    roots = ["Cargo.toml"]
    command = "sh"
    args = [
        "-c",
        """
            if path=$(rustup which rls 2>/dev/null); then
                "$path"
            else
                rls
            fi
        """,
    ]
    [language.rust.settings.rust]
    # See https://github.com/rust-lang/rls#configuration
    # features = []

    # [language.rust]
    # filetypes = ["rust"]
    # roots = ["Cargo.toml"]
    # command = "sh"
    # args = [
    #     "-c",
    #     """
    #         if path=$(rustup which rust-analyzer 2>/dev/null); then
    #             "$path"
    #         else
    #             rust-analyzer
    #         fi
    #     """,
    # ]
    # settings_section = "rust-analyzer"
    # [language.rust.settings.rust-analyzer]
    # hoverActions.enable = false # kak-lsp doesn't support this at the moment
    # # cargo.features = []
    # # See https://rust-analyzer.github.io/manual.html#configuration
    # # If you get 'unresolved proc macro' warnings, you have two options
    # # 1. The safe choice is two disable the warning:
    # diagnostics.disabled = ["unresolved-proc-macro"]
    # # 2. Or you can opt-in for proc macro support
    # procMacro.enable = true
    # cargo.loadOutDirsFromCheck = true
    # # See https://github.com/rust-analyzer/rust-analyzer/issues/6448

    [language.terraform]
    filetypes = ["terraform"]
    roots = ["*.tf"]
    command = "terraform-ls"
    args = ["serve"]
    [language.terraform.settings.terraform-ls]
    # See https://github.com/hashicorp/terraform-ls/blob/main/docs/SETTINGS.md
    # rootModulePaths = []

    [language.yaml]
    filetypes = ["yaml"]
    roots = [".git"]
    command = "yaml-language-server"
    args = ["--stdio"]
    [language.yaml.settings]
    # See https://github.com/redhat-developer/yaml-language-server#language-server-settings
    # Defaults are at https://github.com/redhat-developer/yaml-language-server/blob/master/src/yamlSettings.ts
    # yaml.format.enable = true

    [language.zig]
    filetypes = ["zig"]
    roots = ["build.zig"]
    command = "zls"

    #[language.deno]
    #filetypes = ["typescript", "js", "javascript"]
    #roots = ["*.js", "*.ts"]
    #command = "deno"
    #args = ["lsp"]
    #[language.deno.initialization_options]
    #enable = true
    #lint = true
    #unstable = true

    [language.javascript]
    filetypes = ["js", "javascript"]
    roots = ["*.js"]
    command = "deno"
    args = ["lsp"]
    [language.javascript.initialization_options]
    enable = true
    lint = true
    unstable = true
  '';
}
