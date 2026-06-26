# Windows 11 KVM VM with RTX 5090 Passthrough — Design

**Date:** 2026-06-26
**Host:** `moggio` (NixOS, flake-based config in `nix/`)
**Goal:** Run a Windows 11 virtual machine under KVM/libvirt for Arma Reforger /
Enfusion Workbench development, with the NVIDIA RTX 5090 passed through for real
GPU performance, while keeping the Linux host usable on the AMD integrated GPU.

---

## 1. Context & hardware facts

Established by probing the live system:

| Item | Value | Relevance |
|------|-------|-----------|
| CPU | AMD Ryzen 9 9950X3D, 16C/32T, AMD-V | Plenty of cores for host + VM; SVM virtualization present |
| RAM | 60 GiB total | Room for a 32 GiB VM alongside the host |
| dGPU | NVIDIA RTX 5090 — `01:00.0` (VGA `10de:2b85`) + `01:00.1` (audio `10de:22e8`) | Passthrough target |
| iGPU | AMD Radeon (Granite Ridge) `74:00.0`, already on `amdgpu` | Host display device |
| IOMMU | On (AMD-Vi, 35 groups). 5090 alone in **group 13** | Clean isolation — no ACS-override hacks needed |
| Data drive | `/home/tsimon/data` = ext4, 4.5 TB free, UUID `a721cc76-…`, **no `nofail`** | VM disk + shared folder; needs `nofail` |
| Root SSD | `/` ext4, only ~304 GB free (83% used) | VM disk must NOT go here |
| Existing virt | `qemu`, `virt-manager` in `systemPackages`; **libvirtd NOT enabled**; user not in `libvirtd`/`kvm` | Net-new libvirt enablement required |
| Current display | `services.xserver.videoDrivers = ["nvidia"]`; nvidia modules in initrd | Host currently drives display via the 5090 — must flip to iGPU |
| Monitor | Single panel, EDID = Samsung **Odyssey G93SD** (49" 5120×1440 240Hz QD-OLED). Plugged into the **5090 via HDMI**, currently underdriven at `3840×1080@120` | Move to a **motherboard DisplayPort** output for native 5120×1440 on the iGPU |

**Supplied by user:**
- Windows license keys (located by the user; **values kept out of this repo and
  out of the Nix config** — entered only in the Windows installer). Two keys are
  available, one a **confirmed Windows 10 Home** key (the other an unknown-edition
  ~2020 key, kept as a spare). A Windows 10 Home key activates **Windows 11 Home**,
  so the edition is resolved: **target Windows 11 Home.** Keys cannot be decoded
  offline; entered on the installer's product-key screen, which selects the edition.

**Still to supply:**
- A Windows 11 ISO (only Kali/Ubuntu/NixOS ISOs found in `~/Downloads`).

---

## 2. Decisions (from brainstorming)

1. **Use case:** Arma Reforger / Enfusion Workbench development → needs a real GPU.
2. **GPU topology:** Dual-GPU passthrough. Host on **AMD iGPU**, **RTX 5090 → VM**.
   No single-GPU compromise; host keeps its own display.
3. **GPU sharing:** **Dynamic** — 5090 normally bound to `nvidia` for host CUDA
   (`ollama`, `llama-cpp`, `btop-cuda`); libvirt hooks swap it to `vfio-pci` for the
   VM and back on shutdown.
4. **VM display:** **Looking Glass only** (windowed, low-latency on the Linux
   desktop), with a virtual/dummy display so the 5090 renders a capturable desktop.
   Single monitor; the 5090 is **not** wired to the panel, so Looking Glass is the
   sole way to see Windows — the virtual display is therefore mandatory, not
   optional. Windows view is capped at the iGPU host's resolution/refresh
   (acceptable for development).
5. **Storage:** VM disk image **and** a shared folder both live on
   `/home/tsimon/data`.
6. **Windows version:** **Windows 11 Home** (UEFI + Secure Boot + TPM 2.0),
   activated with the confirmed Windows 10 Home key.
7. **Management approach:** **Declarative host + imperative VM** — all reproducible
   infrastructure in Nix; the Windows install/domain created once via virt-manager.

---

## 3. Architecture overview

```
                         ┌────────────────────────── moggio (NixOS host) ─────────────────────────┐
   monitor(s) ── mobo ──▶│  AMD iGPU (amdgpu) ──▶ Hyprland / GDM desktop                            │
   video out             │                                                                          │
                         │  RTX 5090 (01:00.0/.1)                                                   │
                         │    • VM OFF → nvidia driver → CUDA (ollama / llama-cpp / btop)           │
                         │    • VM ON  → vfio-pci ─────────────────┐                                │
                         │                                          ▼                               │
                         │   libvirtd ── qemu/KVM ──▶  Windows 11 guest (q35, OVMF, swtpm TPM2)     │
                         │     │  hooks: stop ollama → detach nvidia → bind vfio (and reverse)      │
                         │     │  storage pool: /home/tsimon/data/libvirt/images (250 GB qcow2)     │
                         │     │  virtiofs share: /home/tsimon/data ──▶ Windows drive               │
                         │     │  ivshmem ──▶ /dev/shm/looking-glass                                │
                         │     ▼                                                                     │
                         │  looking-glass-client ◀── captures guest framebuffer ── (windowed)       │
                         └──────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Host configuration changes (Nix)

All changes land in the existing `nix/` flake. Grouping for clarity:

### 4.1 Kernel / IOMMU / VFIO
- `boot.kernelParams`: add `amd_iommu=on` and `iommu=pt`.
- Make VFIO modules available (loaded but **not** bound at boot, since binding is
  dynamic): `vfio_pci`, `vfio`, `vfio_iommu_type1`.
- Do **not** set `vfio-pci.ids=` (that would be static binding).
- Keep the `nvidia` driver and modules for host CUDA.

### 4.2 Host display flip to iGPU
- Ensure the **iGPU is the primary DRM device** for the compositor (Hyprland via
  aquamarine: set `AQ_DRM_DEVICES` to the iGPU card path; verify GDM/Wayland picks
  the iGPU too).
- Keep `nvidia` available for compute; the host must not depend on the 5090 for
  display output.
- **Physical step:** move the monitor cable from the 5090 (HDMI) to a
  **motherboard DisplayPort** output (DP-4/5/6) — DP is needed for native
  5120×1440 on the iGPU. The 5090 keeps no display cable; Windows is seen only
  through Looking Glass.
- **Safety:** retain a known-good fallback generation and ensure SSH access so a
  failed display flip is recoverable without a screen.

### 4.3 libvirt / qemu stack
- `virtualisation.libvirtd.enable = true` with:
  - QEMU + OVMF (UEFI firmware).
  - `swtpm` enabled (TPM 2.0 for Windows 11).
  - Hooks enabled for the dynamic GPU swap.
- Add `tsimon` to the `libvirtd` and `kvm` groups.
- Install `virt-manager` (already present), `looking-glass-client`, and reference
  `virtio-win` for guest drivers.

### 4.4 Dynamic GPU-swap hooks
Declared via `virtualisation.libvirtd.hooks.qemu.<name>`. On the Windows domain:
- **prepare/start:** stop `ollama` (and any GPU consumer), detach `01:00.0` and
  `01:00.1` from `nvidia` (`virsh nodedev-detach` or PCI `driver_override` + bind),
  bind `vfio-pci`.
- **release/stop:** unbind `vfio-pci`, reattach `nvidia`, restart `ollama`.
- Hook scoped to this domain name only, so other VMs are unaffected.

### 4.5 Storage
- Create directory `/home/tsimon/data/libvirt/images` and define a libvirt
  storage pool pointing there.
- Add **`nofail`** to the `/home/tsimon/data` mount in `hardware-configuration.nix`
  so an absent/external drive doesn't block boot.
- The libvirt pool/VM autostart should tolerate the drive being mounted slightly
  later (or not autostart).

### 4.6 Shared folder
- **virtiofs** sharing `/home/tsimon/data` into the guest (primary choice).
- Guest side requires WinFsp + the virtiofs driver from the virtio-win ISO.
- Fallback if virtiofs is troublesome on Windows: a host Samba share.

### 4.7 Looking Glass plumbing
- `looking-glass-client` installed on the host.
- ivshmem shared-memory device on the VM; `/dev/shm/looking-glass` created with
  correct ownership/permissions via `systemd.tmpfiles`.
- Guest needs a **virtual/dummy display** (IddSampleDriver / indirect display
  driver, or a physical dummy plug) so the 5090 produces a desktop to capture.

---

## 5. VM specification

| Setting | Value |
|---------|-------|
| Firmware | OVMF (UEFI) + Secure Boot |
| TPM | swtpm, TPM 2.0 |
| Chipset | q35 |
| vCPUs | 8 cores / 16 threads, pinned (prefer the V-cache CCD; `host-passthrough` CPU) |
| RAM | 32 GiB (adjustable; hugepages a later optimization) |
| Disk | 250 GB qcow2 on the data pool (raw is an option for a bit more speed) |
| GPU | RTX 5090 `01:00.0` + `01:00.1` passthrough |
| Display | Looking Glass via ivshmem + virtual display |
| Network | virtio NIC on the default libvirt NAT network |
| Shared FS | virtiofs → `/home/tsimon/data` |
| Install media | Windows 11 ISO + virtio-win ISO (for storage driver at install) |

---

## 6. Manual / imperative steps (one-time)

1. Obtain a **Windows 11 ISO** — the implementation plan will include the official
   Microsoft download steps (microsoft.com/software-download/windows11, "Download
   Windows 11 Disk Image (ISO)"); place it on the data drive.
2. Make the **virtio-win** ISO available (via the Nix package).
3. Locate or purchase the **license key** (optional for install; activate later).
4. In virt-manager: create the VM with the firmware/TPM/specs above; attach both
   ISOs; add the GPU, ivshmem, and virtiofs devices.
5. Install Windows, loading the virtio storage driver when prompted.
6. In Windows, install: NVIDIA drivers, virtio guest tools, WinFsp + virtiofs,
   Looking Glass host, and the virtual display driver.
7. On the host, run `looking-glass-client` and confirm the windowed display.

---

## 7. Risks & mitigations

- **NVIDIA open driver dynamic unbind/rebind** can be stubborn (the
  `nvidia_drm`/`nvidia_modeset`/`nvidia_uvm` modules may hold the device). Mitigate
  by fully stopping GPU consumers in the hook; if it remains unreliable, fall back
  to **static** `vfio-pci.ids` binding (loses host CUDA but is bulletproof).
- **Display flip to iGPU** is the highest-risk change (could boot to a black
  screen). Mitigate with SSH access + a known-good fallback boot generation; test
  deliberately.
- **iGPU desktop performance** is modest vs. the 5090 — fine for Hyprland, less so
  for GPU-heavy host effects.
- **`ollama`/CUDA unavailable while the VM runs** — expected and accepted.
- **External-drive availability** — `nofail` prevents boot hangs; VM start must
  handle the pool being absent gracefully.

---

## 8. Out of scope

- Fully declarative libvirt domain XML (NixVirt) — deliberately not used.
- GPU passthrough for any second/other VM.
- Anti-cheat-sensitive multiplayer gaming considerations (this is for development).
- Automated Windows provisioning (unattended install).
