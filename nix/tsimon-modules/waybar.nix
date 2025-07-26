{
  pkgs,
  config,
  ...
}: {

  programs = {

    waybar = {
      enable = true;

      style = ''
      * {
        font-family: Roboto, Helvetica, Arial, sans-serif;
        font-size: 13px;
        padding: 0 4px;
        margin: 0 4px;
      }
      window#waybar {
        background-color: rgba(40, 40, 60, 0.9);
        border-bottom: 1px solid rgba(100, 100, 125, 0.5);
        border-radius: 0;
        color: #ffffff;
      }

      button {
        color: #ffffff;
        border: 1px solid rgba(255, 255, 255, 0.05);
        border-radius: 0;
        box-shadow: none;
        padding: 0;
        margin: 0;
      }

      button:hover {
        border: 1px solid rgba(255, 255, 255, 0.25);
      }

      #custom-nix-updates {
        margin-left: 10px;
        color: #ffffff;
      }

      #network {
        font-family: "RobotoMono Nerd Font", Roboto;
      }
      '';

      settings = {
        mainBar = {
          layer = "top";
          spacing = 4;
          position = "top";
          height = 34;
          modules-left = [
            "hyprland/workspaces"
            "custom/nix-updates"
          ];
          modules-center = [
            "custom/hello-from-waybar"
          ];
          modules-right = [
            "network"
            "cpu"
            "memory"
            "disk"
            "wireplumber"
            "clock"
          ];

          "custom/nix-updates" = {
            exec = "bash $HOME/bin/update_checker";
            interval = "3600";
            # signal = 12;
            #on-click = "bash $HOME/bin/update_checker";
            on-click-right = "rm ~/.cache/nix-update-last-run";
            return-type = "json";
            format = "{icon}  {}";
            tooltip = true;
            format-icons = {
              has-updates = "󰚰";
              updating = "";
              updated = "";
              error = "";
            };
          };

          "hyprlan/workspaces" = {
            "format" = "{icon} {windows)";
            "on-click" = "activate";
            "persistent_workspaces" = {
              "1" = [];
              "2" = [];
            };
          };

          "custom/hello-from-waybar" = {
            format = "hello {}";
            max-length = 40;
            interval = "once";
            exec = pkgs.writeShellScript "hello-from-waybar" ''
              echo "from `whoami`"
           '';
          };

          "cava" = {
            # "cava_config" = "$XDG_CONFIG_HOME/cava/cava.conf";
            "framerate" = 30;
            "autosens" = 1;
            "bars" = 14;
            "lower_cutoff_freq" = 50;
            "higher_cutoff_freq" = 10000;
            "hide_on_silence" = false;
            # "format_silent" = "quiet";
            "method" = "pipewire";
            "source" = "auto";
            "stereo"= false;
            "reverse"= false;
            "bar_delimiter"= 0;
            "monstercat"= false;
            "waves"= false;
            "noise_reduction"= 0.7;
            "input_delay"= 2;
            "format-icons"= ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
            "actions"= {
              "on-click-right"= "mode";
            };
          };

          "cpu" = {
            interval = 10;
            "format" = "   {usage}%";
            "format-alt" = "   frequency max: {max_frequency} avg: {avg_frequency} min: {min_frequency} - usage: {usage}%";
            "format-icons" = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
            "tooltip" = false;
          };

          "memory" = {
            "interval" = 20;
            "format" = "   {used} of {total}   󰾴  {swapUsed} of {swapTotal}";
          };

          "disk" = {
	          "interval" = 30;
            "path" = "/";
	          "format" = "󰋊  {percentage_used}%";
            "tooltip-format" = "{used} of {total} on {path} ({percentage_used}%)";
	          "unit" = "GB";
          };

          "network" = {
            "interval" = 1;
            "format-wifi" = "  {bandwidthTotalBytes:>2}";
            "format-ethernet" = " {bandwidthUpBytes:>1}   {bandwidthDownBytes:>1}";
            "tooltip-format-ethernet" = "󰈀  {ipaddr}";
            "tooltip-format-wifi" = "  {essid} ({signalStrength}%)";
            "tooltip-format" = "󰤯  {ifname} via {gwaddr}";
            "format-linked" = "󰀦  {ifname} (No IP)";
            "format-disconnected" = "󰀦 Disconnected";
            "format-alt" = "{ifname} {gwaddr} -{bandwidthTotalBytes:>1}";
          };

          "wireplumber"=  {
            "format" = "   {volume}%";
            "format-muted" = "󰟎";
            "on-click" = "easyeffects";
            "on-right-click" = "helvum";
            "max-volume" = 150;
            "scroll-step" = 0.5;
          };

          "clock" = {
            "interval" = 60;
            "timezones" = [ "Australia/ACT" "America/Chicago" "Europe/Oslo"];
            "format" = "{:%FT%R %Z}";
            "tooltip-format" = "{tz_list}";
            "format-alt" = "{:%I:%M %p on %A %d %B, %Y %Z}";
            "actions" = {
              "on-click-right" = "calendar";
              "on-scroll-up" = "tz_up";
              "on-scroll-down" = "tz_down";
            };
          };

        };
      };
    };

  };


  # For the update module
  home = {
    file."bin/update_checker" = {
      executable = true;
      text = ''
#!/bin/bash

# NixOS Update Checker for Waybar
# This script checks for NixOS updates and outputs JSON for Waybar integration

# ===== Configuration =====
UPDATE_INTERVAL=3599  # Check interval in seconds (1 hour)
#NIXOS_CONFIG_PATH="$HOME/.config/nixos"  # Path to NixOS configuration
NIXOS_CONFIG_PATH="/etc/nixos"  # Path to NixOS configuration
CACHE_DIR="$HOME/.cache/nix-update"
STATE_FILE="$CACHE_DIR/nix-update-state"
LAST_RUN_FILE="$CACHE_DIR/nix-update-last-run"
LAST_RUN_TOOLTIP="$CACHE_DIR/nix-update-tooltip"
BOOT_MARKER_FILE="$CACHE_DIR/nix-update-boot-marker"  # Marker file to detect boot/resume

# The grace period prevents the update checker from running immediately after:
# 1. First boot - when the system has just started up
# 2. Resume from hibernation/suspension - when the system has just woken up
# This avoids unnecessary resource usage and notifications during these transition periods.
SKIP_AFTER_BOOT=true  # Set to false if you want to run the checker even after boot/resume
GRACE_PERIOD=60  # Grace period in seconds (60 seconds) after boot/resume

# If true, update the lock file in the config folder.
# If false, copy config to temp folder first, and then update the temp dir's lock file.
UPDATE_LOCK_FILE="false"

# If you have a separate script to update your lock file (i.e. "nix flake update" script)
# and you have UPDATE_LOCK_FILE set to "false",
# the UPDATE_FLAG will signal that your lock file has been updated.
# Add the following to your update script so that the output of nvd diff is piped in:
# | tee >(if grep -qe '\\[U'; then touch \"$HOME/.cache/nix-update-update-flag\"; else rm -f \"$HOME/.cache/nix-update-update-flag\"; fi) &&
UPDATE_FLAG="$CACHE_DIR/nix-update-update-flag"

# The REBUILD_FLAG signals this script to run after your system has been rebuilt.
# Add this to your update script:
# if [ -f \"$HOME/.cache/nix-update-update-flag\" ]; then touch \"$HOME/.cache/nix-update-rebuild-flag\" && pkill -x -RTMIN+12 .waybar-wrapped; fi &&
REBUILD_FLAG="$CACHE_DIR/nix-update-rebuild-flag"

# The UPDATING_FLAG signals if upgrade process is currently performing
# This is required to force waybar module to render while we wait for nixos rebuild
# and also this is enhances UI/UX side
UPDATING_FLAG="$CACHE_DIR/nix-update-updating-flag"

# ===== Initialize Files =====
function init_files() {
    # Create the state file if it doesn't exist
    if [ ! -f "$STATE_FILE" ]; then
        echo "0" > "$STATE_FILE"
    fi

    # Create the last run file if it doesn't exist
    if [ ! -f "$LAST_RUN_FILE" ]; then
        echo "0" > "$LAST_RUN_FILE"
    fi

    # Create the tooltip file if it doesn't exist
    if [ ! -f "$LAST_RUN_TOOLTIP" ]; then
        updates=$(cat "$STATE_FILE")
        if [ "$updates" -eq 0 ]; then
            echo "System updated" > "$LAST_RUN_TOOLTIP"
        else
            # Will be populated during update check
            echo "" > "$LAST_RUN_TOOLTIP"
        fi
    fi
}

# ===== Helper Functions =====
function send_notification() {
    local title="$1"
    local message="$2"
    hyprctl notify 1 5000 0 "$title $message"
}

function check_boot_resume() {
        # This function detects if the system has recently booted or resumed from hibernation/sleep
        # Returns 0 (true) if we're in the grace period, 1 (false) otherwise

        local current_time=$(date +%s)
        local uptime_seconds=$(cat /proc/uptime | awk '{print int($1)}')
        local last_boot_time=$((current_time - uptime_seconds))

        # Check if this is first run after boot
        if [ ! -f "$BOOT_MARKER_FILE" ] || [ $((current_time - last_boot_time)) -lt "$GRACE_PERIOD" ]; then
            # We're either in first run or within grace period after boot
            echo "$current_time" > "$BOOT_MARKER_FILE"
            return 0
        fi

        # Initialize resume timestamp
        local last_resume=0

        # Try to detect resume using systemd logs
        if command -v journalctl >/dev/null 2>&1; then
            # Get timestamp of last resume/wakeup event from systemd journal
            local resume_log=$(journalctl -b -u systemd-suspend.service -u systemd-hibernate.service -n 1 -o short-unix 2>/dev/null)
            if [ -n "$resume_log" ]; then
                # Extract just the numeric timestamp from the beginning of the line
                local timestamp=$(echo "$resume_log" | sed -E 's/^([0-9]+).*/\1/')
                if [ -n "$timestamp" ] && [[ "$timestamp" =~ ^[0-9]+$ ]]; then
                    last_resume=$timestamp
                fi
            fi

            # If no direct service logs, try looking for resume messages in kernel logs
            if [ $last_resume -eq 0 ]; then
                local wake_log=$(journalctl -b -k -g "PM: resumed" -n 1 -o short-unix 2>/dev/null)
                if [ -n "$wake_log" ]; then
                    # Extract just the numeric timestamp from the beginning of the line
                    local timestamp=$(echo "$wake_log" | sed -E 's/^([0-9]+).*/\1/')
                    if [ -n "$timestamp" ] && [[ "$timestamp" =~ ^[0-9]+$ ]]; then
                        last_resume=$timestamp
                    fi
                fi
            fi
        fi

        # Check if we can find resume info in NixOS-specific locations
        if [ $last_resume -eq 0 ] && [ -d "/run/systemd/system" ]; then
            # Check systemd sleep state
            if [ -f "/run/systemd/suspend/active" ] || [ -f "/run/systemd/hibernate/active" ]; then
                last_resume=$current_time  # Just woke up
            fi
        fi

        # If we detected a resume and it's recent, we're in grace period
        if [ $last_resume -gt 0 ] && [ $((current_time - last_resume)) -lt "$GRACE_PERIOD" ]; then
            echo "$current_time" > "$BOOT_MARKER_FILE"
            return 0
        fi

        # Check if we have a saved boot marker and we're still in grace period
        if [ -f "$BOOT_MARKER_FILE" ]; then
            local marker_time=$(cat "$BOOT_MARKER_FILE")
            if [[ "$marker_time" =~ ^[0-9]+$ ]] && [ $((current_time - marker_time)) -lt "$GRACE_PERIOD" ]; then
                return 0  # Still in grace period from marker
            fi
        fi

        # Not in grace period
        return 1
    }

function check_network_connectivity() {
    # Check if either ethernet or wireless is connected
    if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
        return 0  # Connected to the internet
    else
        return 1  # Not connected to the internet
    fi
}

function sys_updated() {
  if [ -f "$REBUILD_FLAG" ]; then
    hyprctl notify 1 5000 0 "System updated"
    return 0 # System has been updated
  else
    hyprctl notify 1 5000 0 "System not updated"
    return 1 # System has not been updated
  fi
}

function calc_next_update() {
    local last_run=$(cat "$LAST_RUN_FILE")
    local current_time=$(date +%s)
    local next_update=$((UPDATE_INTERVAL - (current_time - last_run)))
    local next_update_min=$((next_update / 60))
    echo "$next_update_min"
}

function var_setter() {
    if [ "$updates" -ne 0 ]; then
        alt="has-updates"
        tooltip=$(cat "$LAST_RUN_TOOLTIP")
    else
        alt="updated"
        tooltip="System updated"
    fi
}

# ===== Update Check Logic =====
function check_for_updates() {
    local tempdir=$(mktemp -d)
    # Ensure cleanup happens when script exits
    trap "rm -rf '$tempdir'" EXIT

    hyprctl notify 1 5000 0 "Checking for updates"

    local updates=0
    local tooltip=""

    if [ "$UPDATE_LOCK_FILE" = "true" ]; then
        # Use the config directory directly
        cd "$NIXOS_CONFIG_PATH" || return 1
        nix flake update
        nix build .#nixosConfigurations.$(hostname).config.system.build.toplevel
        if [ "$?" -eq 0 ]; then
            updates=$(nvd diff /run/current-system ./result | grep -e '\[U' | wc -l)
            tooltip=$(nvd diff /run/current-system ./result | grep -e '\[U' | awk '{ for (i=3; i<NF; i++) printf $i " "; if (NF >= 3) print $NF; }' ORS='\\n')
        else
            return 1
        fi
    else
        # Use a temp directory to avoid modifying lock file
        cp -r "$NIXOS_CONFIG_PATH"/* "$tempdir"
        cd "$tempdir" || return 1
        hyprctl notify 1 5000 0 "Update/build"
        nix flake update
        nix build .#nixosConfigurations.$(hostname).config.system.build.toplevel
        if [ "$?" -eq 0 ]; then
            updates=$(nvd diff /run/current-system ./result | grep -e '\[U' | wc -l)
            tooltip=$(nvd diff /run/current-system ./result | grep -e '\[U' | awk '{ for (i=3; i<NF; i++) printf $i " "; if (NF >= 3) print $NF; }' ORS='\\n')
        else
            return 1
        fi
    fi

    # Save results
    echo "$updates" > "$STATE_FILE"
    echo "$(date +%s)" > "$LAST_RUN_FILE"

    if [ "$updates" -eq 0 ]; then
        echo "System updated" > "$LAST_RUN_TOOLTIP"
        hyprctl notify 1 5000 0 "Update check complete - no updates avaialable"
    elif [ "$updates" -eq 1 ]; then
        echo "$tooltip" > "$LAST_RUN_TOOLTIP"
        hyprctl notify 1 5000 0 "Update check complete - found 1 update"
    else
        echo "$tooltip" > "$LAST_RUN_TOOLTIP"
        hyprctl notify 1 5000 0 "Update check complete - found $updates updates"
    fi

    return 0
}

# ===== Main Function =====
function main() {
    init_files

    # Check if we're in post-boot/resume grace period
    if [ "$SKIP_AFTER_BOOT" = "true" ] && check_boot_resume; then
        # Skip update check during grace period after boot or resume from hibernation
        # This prevents unnecessary resource usage during system startup or wakeup
        updates=$(cat "$STATE_FILE")
        var_setter
        echo "{ \"text\":\"$updates\", \"alt\":\"$alt\", \"tooltip\":\"$tooltip\" }"
        exit 0
    fi

    # Check for network connectivity before proceeding
    if check_network_connectivity; then

      local updates=0
      local alt=""
      local tooltip=""

      # Delete flags if system was just updated
      if sys_updated; then
          updates=0
          alt="updated"
          tooltip="System updated"
          echo "$updates" > "$STATE_FILE"
          echo "$tooltip" > "$LAST_RUN_TOOLTIP"
          if [ -f $UPDATE_FLAG ]; then
            rm "$UPDATE_FLAG"
          fi
          rm "$REBUILD_FLAG"
      else
          # Read state from files
          updates=$(cat "$STATE_FILE")
          local last_run=$(cat "$LAST_RUN_FILE")
          local current_time=$(date +%s)

          # Decide whether to show saved state or perform new check
          if [ $((current_time - last_run)) -gt "$UPDATE_INTERVAL" ]; then
              # Separating updating and updated phase
              if [ -f $UPDATING_FLAG ]; then
                  # Time to check for updates
                  if check_for_updates; then
                      updates=$(cat "$STATE_FILE")
                      var_setter
                  else
                      # Update check failed
                      updates=""
                      alt="error"
                      tooltip="Update check failed"
                  fi
                  rm $UPDATING_FLAG
              else
                  updates=$(cat "$STATE_FILE")
                  alt="updating"
                  tooltip="Performing an update"
                  touch $UPDATING_FLAG
                  # Rerun same script just to show updating status and
                  # run update process in separate thread
                  pkill -x -RTMIN+12 .waybar-wrapped
              fi
          else
              # Use saved state
              hyprctl notify 1 5000 0 "Next update is in $(calc_next_update) min"
              var_setter
          fi
      fi
    else
        updates=$(cat "$STATE_FILE")
        var_setter
    fi

    # Output JSON for Waybar
    echo "{ \"text\":\"$updates\", \"alt\":\"$alt\", \"tooltip\":\"$tooltip\" }"
}

# Execute main function
main
      '';
    };
  };

}
