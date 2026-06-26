{ config, lib, pkgs, ... }:

{
  # VFIO modules available for on-demand binding (NOT bound at boot — no
  # vfio-pci.ids — so the host keeps the 5090 on nvidia for the desktop + CUDA
  # until the win11 VM starts, at which point the hook hands it to vfio-pci).
  boot.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;            # qemu runs as root → can reach the 0700 data drive
      swtpm.enable = true;         # TPM 2.0 for Windows 11
      vhostUserPackages = [ pkgs.virtiofsd ];  # virtiofs shared folder
    };
  };

  programs.virt-manager.enable = true;

  # Default virsh (and other libvirt clients) to the system daemon. Without this,
  # virsh defaults to qemu:///session, which runs as the user and cannot manage
  # the root-owned storage pool or do GPU passthrough.
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";

  environment.systemPackages = with pkgs; [
    virtiofsd
    virtio-win
    swtpm

    # Convenience wrappers. IMPORTANT: run `win11-start` from a TTY (Ctrl+Alt+F2)
    # or over SSH — the prepare hook stops the display manager, which kills any
    # terminal inside the graphical session.
    (writeShellScriptBin "win11-start" ''
      exec ${pkgs.libvirt}/bin/virsh -c qemu:///system start win11
    '')
    (writeShellScriptBin "win11-stop" ''
      exec ${pkgs.libvirt}/bin/virsh -c qemu:///system shutdown win11
    '')
  ];

  # Storage pool parent dir on the data drive (the pool's image dir itself is
  # created by `virsh pool-build`; systemd-tmpfiles can't create root-owned dirs
  # under the user's 0700 home, so it only reliably makes this top level).
  systemd.tmpfiles.rules = [
    "d /home/tsimon/data/libvirt 0755 root root -"
  ];

  # Single-GPU passthrough hook for the `win11` domain only.
  #
  # On VM start (prepare/begin): stop GPU users, tear the Linux desktop down,
  # release the framebuffer console, unload nvidia, and bind the 5090 to vfio-pci.
  # On VM stop (release/end): reverse it and bring the desktop back (fresh login).
  #
  # Uses sysfs + modprobe + systemctl only — NEVER virsh (re-entrant deadlock).
  virtualisation.libvirtd.hooks.qemu.win11-gpu =
    let
      gpu = "0000:01:00.0";
      aud = "0000:01:00.1";
    in
    pkgs.writeShellScript "win11-gpu-hook" ''
      set -u
      export PATH=/run/current-system/sw/bin:$PATH
      GUEST="$1"; OP="$2"; SUBOP="$3"
      [ "$GUEST" = "win11" ] || exit 0

      log() { echo "win11-gpu-hook: $*" >&2; }

      # Bring the host back: reload nvidia, rebind PCI audio, restore the
      # framebuffer console, and restart the desktop + compute. Used both by the
      # normal VM-stop path and by every abort path in start_vm, so a failed
      # start never leaves the host headless.
      restore_desktop() {
        modprobe nvidia nvidia_modeset nvidia_uvm nvidia_drm 2>/dev/null || true
        echo 1 > /sys/bus/pci/rescan 2>/dev/null || true
        for vtcon in /sys/class/vtconsole/vtcon*; do
          [ -e "$vtcon/bind" ] && echo 1 > "$vtcon/bind" 2>/dev/null || true
        done
        systemctl start display-manager.service || true
        systemctl start ollama.service 2>/dev/null || true
      }

      release_vfio() {
        for d in ${gpu} ${aud}; do
          echo "$d" > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
          echo "" > /sys/bus/pci/devices/$d/driver_override 2>/dev/null || true
        done
      }

      driver_of() { basename "$(readlink -f /sys/bus/pci/devices/$1/driver 2>/dev/null)" 2>/dev/null; }

      start_vm() {
        # 1. stop GPU compute consumers
        systemctl stop ollama.service 2>/dev/null || true

        # 2. tear down the graphical session (frees the 5090 from the compositor)
        systemctl stop display-manager.service 2>/dev/null || true
        sleep 2

        # 3. release the framebuffer console(s) holding the GPU's fbdev
        for vtcon in /sys/class/vtconsole/vtcon*; do
          if [ -e "$vtcon/bind" ] && grep -q "frame buffer" "$vtcon/name" 2>/dev/null; then
            echo 0 > "$vtcon/bind" 2>/dev/null || true
          fi
        done
        if [ -e /sys/bus/platform/drivers/efi-framebuffer/efi-framebuffer.0 ]; then
          echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind 2>/dev/null || true
        fi
        sleep 1

        # 4. unload the nvidia stack (retry — the session may take a moment to let go)
        local ok=0 i
        for i in $(seq 1 10); do
          if modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia 2>/dev/null; then ok=1; break; fi
          sleep 1
        done
        # abort if any nvidia module is still resident (base OR sub-module)
        if [ "$ok" -ne 1 ] || lsmod | grep -qE '^nvidia'; then
          log "nvidia would not unload — aborting and restoring desktop"
          restore_desktop
          exit 1
        fi

        # 5. bind the GPU + its audio function to vfio-pci
        if ! modprobe vfio-pci; then
          log "vfio-pci modprobe failed — aborting and restoring desktop"
          restore_desktop
          exit 1
        fi
        for d in ${gpu} ${aud}; do
          echo "$d" > /sys/bus/pci/devices/$d/driver/unbind 2>/dev/null || true
          echo vfio-pci > /sys/bus/pci/devices/$d/driver_override 2>/dev/null || true
          echo "$d" > /sys/bus/pci/drivers/vfio-pci/bind 2>/dev/null || true
        done

        # 6. VERIFY both functions are actually on vfio-pci. If not, libvirt would
        #    otherwise start the VM with no GPU while the host sits headless — so
        #    undo the partial bind and restore the desktop instead.
        for d in ${gpu} ${aud}; do
          if [ "$(driver_of "$d")" != "vfio-pci" ]; then
            log "device $d failed to bind vfio-pci (driver='$(driver_of "$d")') — aborting"
            release_vfio
            restore_desktop
            exit 1
          fi
        done
      }

      if [ "$OP" = "prepare" ] && [ "$SUBOP" = "begin" ]; then
        start_vm
      elif [ "$OP" = "release" ] && [ "$SUBOP" = "end" ]; then
        release_vfio
        restore_desktop
      fi
    '';
}
