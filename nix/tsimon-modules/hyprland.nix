{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

      settings = {
        "$mod" = "SUPER";
        "$terminal" = "ghostty";
        "$fileManager" = "nautilus";
        "$menu" = "fuzzel -f Lato:size=20";

        exec-once = [
          "waybar"
          "hypridle"
          "hyprlock"
          "swww init"
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "dbus-update-activation-environment --systemd --all"
        ];

        decoration = {
          rounding = 10;
          rounding_power = 2;
          active_opacity = 0.96;
          inactive_opacity = 0.85;

          shadow = {
            enabled = true;
            range = 4;
            render_power = 2;
            offset = "2 4";
            color = "rgba(1a1a1a80)";
          };
        };

        animations = {
          bezier = "smoov, 0.5, 0, 0.5, 1";
          animation = "workspaces, 1, 2, linear, fade";
        };

        group = {
          insert_after_current = false;
        };

        general = {
          "gaps_in" = "5";
          "gaps_out" = "10";

          "border_size" = "2";

          # https://wiki.hypr.land/Configuring/Variables/#variable-types for info about colors                                                 
          "col.active_border" = "rgba(ffffff99)";
          "col.inactive_border" = "rgba(99206699) rgba(332099aa) 45deg";

          # Set to true enable resizing windows by clicking and dragging on borders and gaps                                                   
          "resize_on_border" = "false";

          # Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on                                                     
          "allow_tearing" = "false";

          "layout" = "dwindle";
        };

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
          "$mod ALT, mouse:272, resizewindow"
        ];

        bind = [
          "$mod, ENTER, exec, $terminal"
          "$mod, C, killactive,"
          "$mod, M, exit,"
          "$mod, E, exec, $fileManager"
          "$mod, V, togglefloating,"
          "$mod, R, exec, $menu"
          "$mod, S, exec, hyprshot -m region --clipboard-only"
          "$mod, P, pseudo," # dwindle
          "$mod, J, layoutmsg, swapsplit" # dwindle

          # Move focus with mainMod + arrow keys
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          # Switch workspaces with mainMod + [0-9]
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"

        ];

      };
    };


}

