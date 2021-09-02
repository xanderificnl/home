{ config, ... }:

let
  # https://nixos.wiki/wiki/FAQ#How_can_I_install_a_package_from_unstable_while_remaining_on_the_stable_channel.3F
  pkgsUnstable = import <nixos-unstable> { config = config.nixpkgs.config; };
in {
  programs.tmux = {
    enable = true;
    extraConfig = ''
      # Allow mouse control
      set -g mouse on 

      # Set nushell
      set-option -g default-shell "/run/current-system/sw/bin/nu"

      # Set new panes to open in current directory
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # tmux pain control 
      run-shell ~/Projects/github.com/tmux-plugins/tmux-pain-control/pain_control.tmux

      # tmux resurrect
      run-shell ~/Projects/github.com/tmux-plugins/tmux-resurrect/resurrect.tmux
    '';
  };
}
