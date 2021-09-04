{ config, ... }:
let
  pkgsUnstable = import <nixos-unstable> { config = config.nixpkgs.config; };
  lsp_languages = "(rust|python|go|javascript|typescript|nix)";
in{
  # nix-env -f '<nixpkgs>' -qaP -A kakounePlugins
  programs.kakoune = {
    enable = true;
    config = {
      colorScheme = "gruvbox";
      ui.enableMouse = false;
    };
    plugins = with pkgsUnstable.kakounePlugins; [ kak-lsp ];
    extraConfig = ''
      # Escape via jj
      hook global InsertChar j %{ try %{
      exec -draft hH <a-k>jj<ret> d
      exec <esc>
      }}
      # LSP 
      eval %sh{kak-lsp --kakoune -s $kak_session} 
      hook global WinSetOption filetype=${lsp_languages} %{
      lsp-enable-window 
      }

      ## Auto format files on save 
      hook global WinSetOption filetype=${lsp_languages} %{
      hook window BufWritePre .* lsp-formating-sync
      }
      map global user l %{: enter-user-mode lsp<ret>} -docstring "LSP mode"
    '';
    # home.file.".config/kak-lsp/kak-lsp.toml".text = ''
    # '';
  };
}
