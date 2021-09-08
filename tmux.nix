{ config, ... }:

{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      # Ensure we're getting full color support
      set -g default-terminal "tmux-256color" # "screen-256color"

      # Allow mouse control
      set -g mouse on 

      # Set nushell
      set-option -g default-shell "/run/current-system/sw/bin/nu"

      # Set new panes to open in current directory
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # Write to all panes
      bind -n C-x setw synchronize-panes

      # tmux pain control 
      run-shell ~/.config/nixpkgs/src/tmux/pain_control.tmux

      # gruvbox
      #set-option -as terminal-overrides ",xterm*:RGB"
      source-file ~/.config/nixpkgs/src/tmux/gruvbox.tmux

      # Update window titles
      set -g terminal-overrides "xterm*:XT:smcup@:rmcup@"

      set -g set-titles on 
      #set -g set-titles-string "#T"
      set-option -g automatic-rename on 
      set-option -g allow-rename on

      # Stop being weird tmux!
      set -ga terminal-overrides ",*col*:Tc"
      set -sg escape-time 25
    '';
  };
}
