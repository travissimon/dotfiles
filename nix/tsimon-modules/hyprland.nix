{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

      settings = {
        mod         = { _var = "SUPER"; };
        terminal    = { _var = "ghostty"; };
        fileManager = { _var = "nautilus"; };
        menu        = { _var = "fuzzel -f Lato:size=20"; };

        on = {
          _args = [
            "hyprland.start"
            (lib.generators.mkLuaInline ''
              function()
                hl.exec_cmd("waybar")
                hl.exec_cmd("hypridle")
                hl.exec_cmd("hyprlock")
                hl.exec_cmd("swww init")
                hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
                hl.exec_cmd("dbus-update-activation-environment --systemd --all")
              end
            '')
          ];
        };

        config = {
          general = {
            gaps_in = 5;
            gaps_out = 10;

            border_size = 2;

            # https://wiki.hypr.land/Configuring/Variables/#variable-types for info about colors
            col = {
              active_border = "rgba(ffffff99)";
              inactive_border = {
                colors = [ "rgba(99206699)" "rgba(332099aa)" ];
                angle = 45;
              };
            };

            # Set to true enable resizing windows by clicking and dragging on borders and gaps
            resize_on_border = false;

            # Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on
            allow_tearing = false;

            layout = "dwindle";
          };

          decoration = {
            rounding = 10;
            rounding_power = 2;
            active_opacity = 0.96;
            inactive_opacity = 0.85;

            shadow = {
              enabled = true;
              range = 4;
              render_power = 2;
              color = "rgba(1a1a1a80)";
            };
          };

          animations = {
            enabled = true;
          };

          group = {
            insert_after_current = false;
          };

          cursor = {
            no_hardware_cursors = true;
          };
        };

        curve = {
          _args = [
            "smoov"
            (lib.generators.mkLuaInline ''{ type = "bezier", points = { {0.5, 0}, {0.5, 1} } }'')
          ];
        };

        animation = {
          _args = [
            (lib.generators.mkLuaInline ''{ leaf = "workspaces", enabled = true, speed = 2, bezier = "linear", style = "fade" }'')
          ];
        };
      };

      extraConfig = ''
        -- Mouse binds
        hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
        hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
        hl.bind(mod .. " + ALT + mouse:272", hl.dsp.window.resize(), { mouse = true })

        -- Application launchers / window actions
        hl.bind(mod .. " + ENTER", hl.dsp.exec_cmd(terminal))
        hl.bind(mod .. " + C", hl.dsp.window.close())
        hl.bind(mod .. " + M", hl.dsp.exit())
        hl.bind(mod .. " + E", hl.dsp.exec_cmd(fileManager))
        hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
        hl.bind(mod .. " + R", hl.dsp.exec_cmd(menu))
        hl.bind(mod .. " + S", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
        hl.bind(mod .. " + P", hl.dsp.window.pseudo()) -- dwindle
        hl.bind(mod .. " + J", hl.dsp.layout("swapsplit")) -- dwindle

        -- Move focus with mod + arrow keys
        hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
        hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
        hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
        hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

        -- Switch / move-to workspaces 1-10 with mod + [1-9, 0]
        for i = 1, 10 do
          local key = i % 10
          hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
          hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
        end
      '';
    };


}
