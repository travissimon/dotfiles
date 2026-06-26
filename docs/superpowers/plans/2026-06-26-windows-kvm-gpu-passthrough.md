# Windows 11 KVM VM with RTX 5090 Passthrough — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up a Windows 11 Home VM under KVM/libvirt with the RTX 5090 passed through for Arma Reforger / Enfusion Workbench development, while the Linux host runs on the AMD iGPU and keeps CUDA when the VM is off.

**Architecture:** Declarative host (libvirt + VFIO + dynamic GPU-swap hooks + Looking Glass + virtiofs, all in the Nix flake) plus an imperatively-created/installed guest. The 5090 (PCI `0000:01:00.0`/`.1`, IOMMU group 13, isolated) is dynamically rebound between `nvidia` (host CUDA) and `vfio-pci` (VM) by libvirt qemu hooks. Host display moves to the AMD iGPU (`0000:74:00.0`); Windows is viewed via Looking Glass.

**Tech Stack:** NixOS (nixpkgs unstable), libvirtd/QEMU/KVM, OVMF (UEFI+SecureBoot), swtpm (TPM 2.0), vfio-pci, virtiofsd, virtio-win.

> ## ⚠️ REVISION 2026-06-27 — Single-GPU passthrough (overrides Tasks 5–10 below)
>
> Switched from dual-GPU + Looking Glass to **single-GPU passthrough** (host runs
> natively on the 5090; the VM is rare). See the spec's REVISION section. The task
> changes:
>
> - **Task 5 → REVERSED.** Do NOT flip the host to the iGPU. Revert the iGPU edits
>   (`git revert 8292d96`): host stays on the 5090 (`videoDrivers=["nvidia"]`,
>   `nvidia-drm.fbdev=1`, no `AQ_DRM_DEVICES`). No monitor-cable move, no BIOS change.
> - **Drop `looking-glass-client`** from `windows-vm.nix`. No ivshmem, no
>   `/dev/shm/looking-glass` (Task 9), no Looking Glass guest/client (Task 10).
> - **Task 7 → single-GPU teardown/restore hook** (replaces the dynamic-swap hook).
>   prepare/begin: `systemctl stop ollama`; `systemctl stop display-manager`;
>   free the framebuffer console (unbind `/sys/class/vtconsole/vtcon*/bind`,
>   `efi-framebuffer.0` if present); `modprobe -r nvidia_drm nvidia_modeset
>   nvidia_uvm nvidia`; bind `vfio-pci`. release/end: unbind vfio; `modprobe
>   nvidia nvidia_modeset nvidia_uvm nvidia_drm`; rebind console; `systemctl start
>   display-manager`; `systemctl start ollama`.
> - **Task 6 → single-GPU teardown test, run from SSH** (the desktop dies during
>   the test).
> - **Task 8** unchanged (attach the 5090, `managed='no'`), except set the emulated
>   video to `none` (or keep QXL only as a pre-driver fallback) so Windows uses the
>   5090 as primary; the VM drives the physical monitor directly.
> - **VM must be started detached** from the GUI session (SSH/TTY or
>   `systemd-run --scope`), because the prepare hook stops the display manager and
>   would kill the launching shell. A wrapper script will be provided.
> - **SSH recovery is mandatory** — already in place (`tsimon@10.17.13.205`).
>
> Tasks 0–4 (infra, media, VM install) and Task 11 (virtiofs) are unaffected.

## Global Constraints

- Flake + rebuild target: `sudo nixos-rebuild switch --flake /home/tsimon/dotfiles/nix#moggio` (use `test` instead of `switch` when a change might break the display/boot — `test` does not touch the bootloader).
- Host: `moggio`, AMD Ryzen 9 9950X3D, 60 GiB RAM. CPU virt: AMD-V; use `kvm-amd`.
- GPU to pass through: NVIDIA RTX 5090 — `0000:01:00.0` (`10de:2b85`) + `0000:01:00.1` (`10de:22e8`). Alone in IOMMU group 13.
- Host display GPU: AMD iGPU `0000:74:00.0`, card path `/dev/dri/by-path/pci-0000:74:00.0-card`.
- Guest libvirt domain name: **`win11`** (hooks key off this exact name — do not rename without updating the hook).
- Storage: VM disk + shared folder on `/home/tsimon/data` (ext4, 4.5 TB free, UUID `a721cc76-4c65-438a-9a52-56188839c59b`).
- License keys are **never** written to the repo or Nix config — entered only in the Windows installer. Target edition: **Windows 11 Home**.
- `nixpkgs.config.allowUnfree = true` is already set (required for `virtio-win`).
- In this nixpkgs, `virtualisation.libvirtd.qemu.ovmf` is REMOVED — OVMF ships by default. Do NOT set it.
- libvirt qemu hooks must NOT call `virsh` (re-entrancy deadlock). Use sysfs + `modprobe` + `systemctl` only.

---

## File structure

| File | Responsibility | Action |
|------|----------------|--------|
| `nix/windows-vm.nix` | NEW system module: VFIO modules, libvirtd (swtpm, virtiofsd), virt-manager, looking-glass-client, GPU-swap hook, storage-pool dir + shm tmpfiles, vfio kernel params | Create |
| `nix/configuration.nix` | Import the new module; add `amd_iommu=on iommu=pt`; add `tsimon` to `libvirtd`/`kvm` groups | Modify |
| `nix/hardware-configuration.nix` | `videoDrivers = ["amdgpu" "nvidia"]`; `nofail` on the data mount | Modify |
| `nix/home-tsimon.nix` | `AQ_DRM_DEVICES` so Hyprland renders on the iGPU | Modify |

Phases 2/3/5b/6/7 also create libvirt/guest state (imperative) and edit the domain XML via `virsh edit win11`.

---

## Phase 0 — Safety net

### Task 0: Establish rollback + remote access before touching graphics

No code change; this protects the later display flip.

- [ ] **Step 1: Record the current working generation**

Run: `sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -3`
Expected: a numbered list; note the current (latest) generation number — you can boot it from the systemd-boot menu if the iGPU flip fails.

- [ ] **Step 2: Enable SSH so a black-screen host is still reachable**

Add to `nix/configuration.nix` inside `services = { ... }`:

```nix
    openssh = {
      enable = true;
      settings.PasswordAuthentication = true;
    };
```

- [ ] **Step 3: Build and verify SSH from another machine (or phone)**

Run: `sudo nixos-rebuild switch --flake /home/tsimon/dotfiles/nix#moggio`
Then from another device: `ssh tsimon@moggio` (or the host IP from `ip a`).
Expected: a shell prompt. This is your recovery path for Phase 4.

- [ ] **Step 4: Commit**

```bash
cd /home/tsimon/dotfiles
git add nix/configuration.nix
git commit -m "Enable sshd as recovery path before GPU/display changes"
```

---

## Phase 1 — libvirt + VFIO infrastructure (no display change, no passthrough)

Goal: a working libvirtd that can create VMs, with OVMF/swtpm/virtiofs available and the storage pool ready. Nothing here touches the running display or the 5090, so it is low-risk.

### Task 1: Create the `windows-vm.nix` system module (infra only)

**Files:**
- Create: `nix/windows-vm.nix`
- Modify: `nix/configuration.nix` (imports + kernelParams + groups)

**Interfaces:**
- Produces: `virtualisation.libvirtd` service, `/home/tsimon/data/libvirt/images` dir, packages `virt-manager`/`looking-glass-client`, vfio kernel modules. The GPU-swap hook and shm tmpfiles are added in Phase 5/6 (kept out here so Phase 1 stays display-safe).

- [ ] **Step 1: Write the module (infra subset)**

Create `nix/windows-vm.nix`:

```nix
{ config, lib, pkgs, ... }:

{
  # VFIO modules available for on-demand binding (NOT bound at boot — no
  # vfio-pci.ids, so nvidia keeps the 5090 for host CUDA until a VM starts).
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

  environment.systemPackages = with pkgs; [
    looking-glass-client
    virtiofsd
    virtio-win
    swtpm
  ];

  # Storage pool directory on the data drive.
  systemd.tmpfiles.rules = [
    "d /home/tsimon/data/libvirt        0755 root root -"
    "d /home/tsimon/data/libvirt/images 0755 root root -"
  ];
}
```

- [ ] **Step 2: Wire it into configuration.nix**

In `nix/configuration.nix`, change the `imports` block:

```nix
  imports = [
    ./hardware-configuration.nix
    ./windows-vm.nix
  ];
```

Add IOMMU params to the existing `boot.kernelParams` line (currently `[ "nvidia-drm.fbdev=1" ]`):

```nix
    kernelParams = [ "nvidia-drm.fbdev=1" "amd_iommu=on" "iommu=pt" ];
```

Add `tsimon` to the libvirt/kvm groups (existing `extraGroups`):

```nix
      extraGroups = [ "wheel" "audio" "scanner" "lp" "docker" "plugdev" "libvirtd" "kvm" ];
```

- [ ] **Step 3: Build**

Run: `sudo nixos-rebuild switch --flake /home/tsimon/dotfiles/nix#moggio`
Expected: completes without evaluation errors. (If it complains about `qemu.ovmf`, you added it — remove it; OVMF is automatic here.)

- [ ] **Step 4: Verify libvirtd + groups (re-login first so group membership applies)**

Run:
```bash
systemctl status libvirtd --no-pager | head -3
groups | tr ' ' '\n' | grep -E 'libvirtd|kvm'
virsh list --all
```
Expected: libvirtd `active (running)`; `libvirtd` and `kvm` listed; `virsh list --all` prints an empty table (no error).

- [ ] **Step 5: Verify OVMF + swtpm are present for libvirt**

Run:
```bash
ls /run/libvirt/nix-ovmf/ 2>/dev/null
which swtpm
```
Expected: OVMF `*.fd` files (e.g. `OVMF_CODE.fd`, and a `.secboot.fd` variant); `swtpm` path printed.

- [ ] **Step 6: Commit**

```bash
cd /home/tsimon/dotfiles
git add nix/windows-vm.nix nix/configuration.nix
git commit -m "Add libvirt/VFIO infrastructure module (no display change yet)"
```

### Task 2: Add `nofail` to the data mount and define the storage pool

**Files:**
- Modify: `nix/hardware-configuration.nix`

- [ ] **Step 1: Add `nofail` so an absent drive can't hang boot**

In `nix/hardware-configuration.nix`, change the `/home/tsimon/data` entry:

```nix
    "/home/tsimon/data" = {
      device = "/dev/disk/by-uuid/a721cc76-4c65-438a-9a52-56188839c59b";
      fsType = "ext4";
      options = [ "nofail" "x-systemd.device-timeout=10s" ];
    };
```

- [ ] **Step 2: Build**

Run: `sudo nixos-rebuild switch --flake /home/tsimon/dotfiles/nix#moggio`
Expected: success.

- [ ] **Step 3: Confirm the mount and the pool dir exist**

Run:
```bash
findmnt /home/tsimon/data
ls -ld /home/tsimon/data/libvirt/images
```
Expected: mount shown with `nofail`; the images dir exists.

- [ ] **Step 4: Define + start the libvirt storage pool**

Run:
```bash
virsh pool-define-as win-images dir --target /home/tsimon/data/libvirt/images
virsh pool-autostart win-images
virsh pool-start win-images
virsh pool-list --all
```
Expected: `win-images` listed as `active` and `yes` (autostart).

- [ ] **Step 5: Ensure the default NAT network is running**

Run:
```bash
virsh net-list --all
virsh net-autostart default
virsh net-start default 2>/dev/null || true
virsh net-list
```
Expected: `default` network `active`. (If `default` is missing entirely, create it: `virsh net-define /run/current-system/sw/share/libvirt/networks/default.xml` then repeat — but it normally ships enabled.)

- [ ] **Step 6: Commit**

```bash
cd /home/tsimon/dotfiles
git add nix/hardware-configuration.nix
git commit -m "Mark data drive nofail for the libvirt storage pool"
```

---

## Phase 2 — Acquire installation media

### Task 3: Get the Windows 11 ISO and virtio-win drivers onto the data drive

No repo change; one-time downloads.

- [ ] **Step 1: Download the official Windows 11 ISO**

In Firefox/Chrome, open `https://www.microsoft.com/software-download/windows11`, choose **"Download Windows 11 Disk Image (ISO) for x64 devices"**, pick a language, and download. Save to `/home/tsimon/data/iso/`:

```bash
mkdir -p /home/tsimon/data/iso
# move the downloaded file, e.g.:
mv ~/Downloads/Win11_*.iso /home/tsimon/data/iso/
ls -lh /home/tsimon/data/iso/
```
Expected: a ~5–7 GB `Win11_*.iso` present.

- [ ] **Step 2: virtio-win ISO**

NOTE (discovered during execution): the nixpkgs `virtio-win` package ships the
**extracted driver tree** (plus `virtio-win-guest-tools.exe`/`.msi`), NOT an
`.iso`. An ISO was therefore built from that tree with `xorrisofs` to
`/home/tsimon/data/iso/virtio-win.iso` (volume label `virtio-win-0.1.285`). Use
that path when attaching the second CD-ROM. To rebuild it if needed:
`xorrisofs -o /home/tsimon/data/iso/virtio-win.iso -V virtio-win -J -joliet-long -r <virtio-win-store-path>/`

- [ ] **Step 3: No commit** (downloads only; nothing tracked).

---

## Phase 3 — Create and install Windows 11 (NO passthrough yet)

Install Windows first with ordinary virtio video so we have a known-good, activated guest before adding GPU/display complexity. View it through the built-in virt-manager console for now.

### Task 4: Create the VM in virt-manager and install Windows

No repo change; libvirt domain state.

- [ ] **Step 1: Launch virt-manager and start a new VM**

Run: `virt-manager`
- New VM → Local install media → browse to `/home/tsimon/data/iso/Win11_*.iso`.
- OS type: Windows 11 (if not auto-detected, pick "Windows 11" or generic Windows).

- [ ] **Step 2: Set CPU/RAM**

Memory: `32768` MiB. CPUs: `16` (8 cores × 2 threads). CPU pinning to the
9950X3D's V-cache CCD is an optional later optimization — identify the CCDs with
`lscpu -e` / `lstopo` and add a `<cputune>` block if you want it; not required for
a working VM.

- [ ] **Step 3: Create the disk on the data pool**

Choose "Select or create custom storage" → Manage → pool `win-images` → New volume:
- Name `win11.qcow2`, format `qcow2`, capacity `250` GiB.

- [ ] **Step 4: Before finishing, tick "Customize configuration before install"** and set:
- Firmware: **UEFI** with the **secboot** OVMF (e.g. `OVMF_CODE.secboot.fd`) — required for Windows 11.
- Chipset: **Q35**.
- Add Hardware → **TPM** → model `CRB`, version `2.0`.
- Add Hardware → **Storage** → CDROM → the **virtio-win** ISO (second optical drive).
- NIC device model: `virtio`. Disk bus: `virtio`. (Leave the default video — QXL/virtio — for now.)
- Begin installation.

- [ ] **Step 5: Install Windows, loading the virtio storage driver**

In Setup, when no disk is shown: **Load driver** → browse the virtio-win CD →
`viostor\w11\amd64` (the storage driver; layout is device\OS\arch). The 250 GB
disk appears; install onto it. (If prompted for network later, the NetKVM driver
is at `NetKVM\w11\amd64`.)

- [ ] **Step 6: Enter the product key when prompted**

Use the confirmed **Windows 10 Home** key. The installer selects **Windows 11 Home** automatically. (If the key is rejected at the install screen, choose "I don't have a product key", install Home, and activate later via Settings → System → Activation.)

- [ ] **Step 7: Finish setup; inside Windows install the full virtio guest tools**

From the virtio-win CD run `virtio-win-guest-tools.exe` (installs balloon, serial, qxl/spice, vioscsi, NetKVM, etc.). Reboot. Confirm network works (`ping 1.1.1.1` in cmd).

- [ ] **Step 8: Verify activation**

In Windows: Settings → System → Activation → expect "Windows is activated". (If not, run `slmgr /ipk <key>` then `slmgr /ato`, or activate via the GUI.)

- [ ] **Step 9: Snapshot this clean state**

In a host terminal: `virsh snapshot-create-as win11 clean-install "Activated Win11 Home, virtio tools, pre-passthrough"`
Expected: snapshot created — a safe restore point before GPU changes.

---

## Phase 4 — Flip the host display to the AMD iGPU (highest risk)

This frees the 5090 from being the host's primary display so it can be handed to the VM. Do this with the SSH recovery path from Phase 0 ready.

### Task 5: Physical + BIOS + Nix changes to run the host on the iGPU

**Files:**
- Modify: `nix/hardware-configuration.nix` (`videoDrivers`)
- Modify: `nix/configuration.nix` (drop `nvidia-drm.fbdev=1`)
- Modify: `nix/home-tsimon.nix` (`AQ_DRM_DEVICES`)

- [ ] **Step 1: Move the monitor cable**

Physically move the G93SD cable from the 5090 to a **motherboard DisplayPort** output (one of DP-4/5/6). DisplayPort is required for native 5120×1440 on the iGPU.

- [ ] **Step 2: Set the BIOS primary display to the integrated GPU**

Reboot into BIOS (MSI). Set "Initiate Graphic Adapter" / "Primary Display" to **IGD/Integrated**, and enable "IGD Multi-Monitor" if present. Save & exit. This makes the iGPU `boot_vga`, so GDM/mutter come up on the monitor you just moved.

- [ ] **Step 3: Make amdgpu a display driver and keep nvidia for compute**

In `nix/hardware-configuration.nix` change:

```nix
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
```

- [ ] **Step 4: Drop the nvidia framebuffer param**

In `nix/configuration.nix`, edit the kernelParams (remove the fbdev entry so nvidia holds less display state, easing later unbind):

```nix
    kernelParams = [ "amd_iommu=on" "iommu=pt" ];
```

- [ ] **Step 5: Force Hyprland to render on the iGPU**

In `nix/home-tsimon.nix`, inside `home.sessionVariables`, add:

```nix
      AQ_DRM_DEVICES = "/dev/dri/by-path/pci-0000:74:00.0-card";
```

- [ ] **Step 6: Build with `test` first (does not change bootloader)**

Run: `sudo nixos-rebuild test --flake /home/tsimon/dotfiles/nix#moggio`
Expected: completes. If the screen survives / comes back, good. If it goes black, SSH in and run `sudo nixos-rebuild test --rollback` or just reboot into the prior generation.

- [ ] **Step 7: Reboot and verify the host is on the iGPU**

Run after login:
```bash
hyprctl monitors | grep -iE "Monitor|description"     # monitor present on the iGPU
echo "AQ_DRM_DEVICES=$AQ_DRM_DEVICES"
sudo lspci -k -s 01:00.0 | grep "Kernel driver"        # should still say nvidia (compute)
nvidia-smi | head -15                                   # CUDA stack alive on the 5090
```
Expected: a working desktop driven by the iGPU; nvidia driver still bound to the 5090; `nvidia-smi` lists the RTX 5090.

- [ ] **Step 8: Confirm CUDA workloads still run**

Run: `systemctl restart ollama && ollama run llama3.2 "hi" --verbose 2>&1 | tail -5` (or any model you have).
Expected: it loads on the GPU (check `nvidia-smi` shows the process). This proves nvidia-for-compute survives the display flip.

- [ ] **Step 9: Persist (switch) and commit**

```bash
sudo nixos-rebuild switch --flake /home/tsimon/dotfiles/nix#moggio
cd /home/tsimon/dotfiles
git add nix/hardware-configuration.nix nix/configuration.nix nix/home-tsimon.nix
git commit -m "Run host desktop on AMD iGPU; keep nvidia for CUDA"
```

**Fallback if the desktop won't come up on the iGPU:** boot the previous generation (Phase 0), revert this commit. The whole project can instead use **static** vfio binding (5090 always to the VM, host always on iGPU, no CUDA) — see Task 7's fallback note.

---

## Phase 5 — GPU passthrough + dynamic bind/unbind

### Task 6: Verify a manual GPU detach/reattach works (before automating)

No repo change — this de-risks the hook by proving the swap by hand.

- [ ] **Step 1: Stop GPU consumers and unload nvidia**

Run:
```bash
sudo systemctl stop ollama.service
sleep 2
sudo modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia
echo $?
```
Expected: exit `0`. If it fails with "Module ... is in use", find the holder (`sudo lsof /dev/nvidia*`; `nvidia-smi`), stop it, retry. (Common holders: ollama, open-webui, a running `nvidia-smi -l`, btop-cuda.)

- [ ] **Step 2: Bind the 5090 to vfio-pci**

Run:
```bash
sudo modprobe vfio-pci
for d in 0000:01:00.0 0000:01:00.1; do
  echo vfio-pci | sudo tee /sys/bus/pci/devices/$d/driver_override
  echo $d | sudo tee /sys/bus/pci/drivers/vfio-pci/bind
done
sudo lspci -k -s 01:00.0 | grep "Kernel driver"
```
Expected: `Kernel driver in use: vfio-pci`.

- [ ] **Step 3: Reverse it (reattach to nvidia)**

Run:
```bash
for d in 0000:01:00.0 0000:01:00.1; do
  echo $d | sudo tee /sys/bus/pci/drivers/vfio-pci/unbind
  echo | sudo tee /sys/bus/pci/devices/$d/driver_override
done
sudo modprobe nvidia nvidia_modeset nvidia_uvm nvidia_drm
echo 1 | sudo tee /sys/bus/pci/rescan
sudo systemctl start ollama.service
nvidia-smi | head -5
```
Expected: `nvidia-smi` works again. This confirms the swap is reliable on this hardware. If Step 1 cannot reliably unload nvidia, switch to the **static** fallback in Task 7 before proceeding.

### Task 7: Add the dynamic GPU-swap hook to the Nix module

**Files:**
- Modify: `nix/windows-vm.nix` (add the hook)

- [ ] **Step 1: Add the hook script + registration to `windows-vm.nix`**

Add inside the module (e.g. above the closing `}`), then reference it in `virtualisation.libvirtd.hooks`:

```nix
  # Dynamic GPU swap: only for the "win11" domain.
  virtualisation.libvirtd.hooks.qemu.win11-gpu =
    let
      gpu = "0000:01:00.0";
      aud = "0000:01:00.1";
    in pkgs.writeShellScript "win11-gpu-hook" ''
      set -u
      export PATH=/run/current-system/sw/bin:$PATH
      GUEST="$1"; OP="$2"; SUBOP="$3"
      [ "$GUEST" = "win11" ] || exit 0

      bind_vfio() {
        systemctl stop ollama.service || true
        # add any other GPU consumers here (e.g. open-webui) if they hold the GPU
        sleep 3
        if ! modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia; then
          echo "win11-gpu-hook: nvidia modules busy, aborting VM start" >&2
          systemctl start ollama.service || true
          exit 1
        fi
        modprobe vfio-pci
        for d in ${gpu} ${aud}; do
          # unbind from whatever driver still holds it (e.g. the audio function
          # may be on snd_hda_intel even after the nvidia modules unload)
          echo "$d" > /sys/bus/pci/devices/$d/driver/unbind 2>/dev/null || true
          echo vfio-pci > /sys/bus/pci/devices/$d/driver_override
          echo "$d" > /sys/bus/pci/drivers/vfio-pci/bind 2>/dev/null || true
        done
      }

      unbind_vfio() {
        for d in ${gpu} ${aud}; do
          echo "$d" > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
          echo "" > /sys/bus/pci/devices/$d/driver_override
        done
        modprobe nvidia nvidia_modeset nvidia_uvm nvidia_drm || true
        echo 1 > /sys/bus/pci/rescan
        systemctl start ollama.service || true
      }

      if [ "$OP" = "prepare" ] && [ "$SUBOP" = "begin" ]; then
        bind_vfio
      elif [ "$OP" = "release" ] && [ "$SUBOP" = "end" ]; then
        unbind_vfio
      fi
    '';
```

- [ ] **Step 2: Build**

Run: `sudo nixos-rebuild switch --flake /home/tsimon/dotfiles/nix#moggio`
Expected: success.

- [ ] **Step 3: Confirm the hook is installed**

Run: `ls -l /var/lib/libvirt/hooks/qemu.d/`
Expected: a `win11-gpu` entry (symlink to the nix store script).

- [ ] **Step 4: Commit**

```bash
cd /home/tsimon/dotfiles
git add nix/windows-vm.nix
git commit -m "Add dynamic nvidia<->vfio GPU-swap libvirt hook for win11"
```

**Static fallback (only if dynamic proves unreliable):** instead of the hook, in `configuration.nix` set `boot.kernelParams += [ "vfio-pci.ids=10de:2b85,10de:22e8" ]` and remove the `nvidia` entries from `hardware-configuration.nix` (initrd modules, `extraModulePackages`, `hardware.nvidia`, and `videoDrivers`). The 5090 then belongs to the VM permanently and the host loses CUDA. Document this clearly if chosen.

### Task 8: Attach the 5090 to the VM and boot Windows with it

No repo change — domain XML edit.

- [ ] **Step 1: Add the GPU as a manually-managed hostdev**

Run: `virsh edit win11`. Inside `<devices>` add (note `managed='no'` — the hook does the binding):

```xml
    <hostdev mode='subsystem' type='pci' managed='no'>
      <source>
        <address domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
      </source>
    </hostdev>
    <hostdev mode='subsystem' type='pci' managed='no'>
      <source>
        <address domain='0x0000' bus='0x01' slot='0x00' function='0x1'/>
      </source>
    </hostdev>
```

- [ ] **Step 2: Start the VM and watch the swap happen**

Run:
```bash
virsh start win11
sleep 5
sudo lspci -k -s 01:00.0 | grep "Kernel driver"   # expect vfio-pci
systemctl is-active ollama                          # expect inactive (hook stopped it)
```
Expected: 5090 on `vfio-pci`; ollama stopped. Open the virt-manager console — Windows boots.

- [ ] **Step 3: Install the NVIDIA driver inside Windows**

In the guest, download/run the standard GeForce driver for the RTX 5090. Reboot the guest. In Device Manager the RTX 5090 should appear with no Error 43.

- [ ] **Step 4: Shut down and confirm the host gets the GPU back**

Run:
```bash
virsh shutdown win11
sleep 10
sudo lspci -k -s 01:00.0 | grep "Kernel driver"   # expect nvidia
nvidia-smi | head -5                                # CUDA back
systemctl is-active ollama                          # expect active (hook restarted it)
```
Expected: 5090 back on `nvidia`, `nvidia-smi` works, ollama running. The dynamic cycle is proven.

---

## Phase 6 — Looking Glass (windowed Windows on the Linux desktop)

### Task 9: Add the ivshmem device + shm permissions

**Files:**
- Modify: `nix/windows-vm.nix` (shm tmpfiles rule)

- [ ] **Step 1: Add the Looking Glass shm file rule**

In `nix/windows-vm.nix`, extend `systemd.tmpfiles.rules` with:

```nix
    "f /dev/shm/looking-glass 0660 root kvm -"
```

- [ ] **Step 2: Build**

Run: `sudo nixos-rebuild switch --flake /home/tsimon/dotfiles/nix#moggio`
Expected: success; `ls -l /dev/shm/looking-glass` shows the file (`root kvm`, mode 660).

- [ ] **Step 3: Add the ivshmem device to the domain**

Run: `virsh edit win11`. Inside `<devices>` add (128 MiB covers 5120×1440):

```xml
    <shmem name='looking-glass'>
      <model type='ivshmem-plain'/>
      <size unit='M'>128</size>
    </shmem>
```

- [ ] **Step 4: Commit the Nix change**

```bash
cd /home/tsimon/dotfiles
git add nix/windows-vm.nix
git commit -m "Provision /dev/shm/looking-glass for Looking Glass ivshmem"
```

### Task 10: Windows-side Looking Glass host + virtual display; host-side client

No repo change.

- [ ] **Step 1: Install a virtual display in the guest**

The 5090 has no monitor attached, so install a Virtual Display Driver (e.g. the IddSampleDriver / "Virtual Display Driver" project) inside Windows, OR plug a cheap HDMI/DP dummy plug into the 5090. Set the virtual/dummy display to 5120×1440 and make it the primary display. (Without this, the GPU renders nothing for Looking Glass to capture.)

- [ ] **Step 2: Install the IVSHMEM driver in the guest**

In Windows Device Manager the ivshmem device shows as an unknown "PCI standard RAM Controller". Update its driver with the **virtio-win** `Balloon`/`ivshmem` driver, or the signed IVSHMEM driver from the Looking Glass releases page matching the host version (`looking-glass-client -h` shows it, currently the `B7` series).

- [ ] **Step 3: Install + run the Looking Glass host app in the guest**

Install the **looking-glass-host** matching the client version, set it to run at logon. It begins writing frames to the ivshmem region.

- [ ] **Step 4: Run the client on the host**

Run: `looking-glass-client -f /dev/shm/looking-glass`
Expected: a window showing the Windows desktop at the virtual display's resolution, low latency. Add `:full-screen` or spice clipboard options as desired. (Keyboard/mouse capture defaults to ScrollLock toggle.)

- [ ] **Step 5: Confirm copy/paste + input**

Type into the Looking Glass window; confirm SPICE clipboard sharing works between host and guest.

---

## Phase 7 — virtiofs shared folder (`/home/tsimon/data` in Windows)

### Task 11: Add the virtiofs filesystem device + shared memory backing

No repo change (virtiofsd already provisioned in Task 1) — domain XML edit.

- [ ] **Step 1: Enable shared memory backing on the domain**

Run: `virsh edit win11`. As a top-level child of `<domain>` (sibling of `<memory>`), add:

```xml
  <memoryBacking>
    <source type='memfd'/>
    <access mode='shared'/>
  </memoryBacking>
```

- [ ] **Step 2: Add the virtiofs filesystem device**

Inside `<devices>` add:

```xml
    <filesystem type='mount' accessmode='passthrough'>
      <driver type='virtiofs'/>
      <source dir='/home/tsimon/data'/>
      <target dir='data'/>
    </filesystem>
```

- [ ] **Step 3: Start the VM and install the guest virtiofs pieces**

In Windows: install **WinFsp** (https://winfsp.dev) and the **VirtIO-FS** service from the virtio-win CD (`virtiofs` folder → run `virtiofs.exe install` from an elevated prompt, or enable the "VirtIO-FS Service" in services). Start the service.

- [ ] **Step 4: Verify the share appears in Windows**

Expected: a new drive (e.g. `Z:`) mapped to `/home/tsimon/data`. Create a file from Windows; confirm it appears on the host:

```bash
ls -l /home/tsimon/data/
```
Expected: the file created in Windows is visible on the host (and vice-versa).

- [ ] **Step 5: Final snapshot**

Run: `virsh snapshot-create-as win11 fully-configured "GPU passthrough + Looking Glass + virtiofs working"`
Expected: snapshot created.

---

## Done — acceptance check

- [ ] `virsh start win11` → host frees the 5090 to the VM, ollama stops (hook).
- [ ] Looking Glass window shows Windows with the 5090 active (Device Manager, no Error 43).
- [ ] `Z:` (or chosen letter) in Windows reads/writes `/home/tsimon/data`.
- [ ] `virsh shutdown win11` → 5090 returns to `nvidia`, `nvidia-smi` works, ollama restarts.
- [ ] Arma Reforger Tools / Enfusion Workbench launches and renders in the guest.
```
