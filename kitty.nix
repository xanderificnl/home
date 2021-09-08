{ ... }: let
  leader = "ctrl";
in
{
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
      active_border_color = "#665c54";
      inactive_border_color = "#3c3836";
      active_tab_background = "#504945";
      active_tab_foreground = "#d4be98";
      inactive_tab_background = "#282828";
      inactive_tab_foreground = "#a89984";
      tab_bar_background = "none";
      tab_bar_style = "powerline";
      tab_title_template = "{index}: {title}";
      #wheel_scroll_multiplier = "10.0";
      touch_scroll_multiplier = "10.0";
    };

    extraConfig = ''                                                                                                                                                                           
       enabled_layouts splits:split_axis=horizontal

       map ${leader}+\ launch --location=hsplit
       map ${leader}+' launch --location=vsplit
       map F7 layout_action rotate
                                                                                                                                                                                                
       map ${leader}+shift+up move_window up
       map ${leader}+shift+left move_window left
       map ${leader}+shift+right move_window right
       map ${leader}+shift+down move_window down
                                                                                                                                                                                                
       map ${leader}+left neighboring_window left
       map ${leader}+right neighboring_window right
       map ${leader}+up neighboring_window up
       map ${leader}+down neighboring_window down

       map ctrl+0 goto_tab 10
       map ctrl+1 goto_tab 1
       map ctrl+2 goto_tab 2
       map ctrl+3 goto_tab 3
       map ctrl+4 goto_tab 4
       map ctrl+5 goto_tab 5
       map ctrl+6 goto_tab 6
       map ctrl+7 goto_tab 7
       map ctrl+8 goto_tab 8
       map ctrl+9 goto_tab 9

     '';
  };
}
