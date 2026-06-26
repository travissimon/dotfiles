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

  # Default virsh (and other libvirt clients) to the system daemon. Without
  # this, virsh defaults to qemu:///session, which runs as the user and cannot
  # manage the root-owned storage pool or do GPU passthrough. virt-manager
  # already targets the system daemon; this keeps the CLI consistent with it.
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";

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
