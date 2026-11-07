# TYMCZASOWY plik - zostanie nadpisany przy instalacji (README, krok 5):
#   nixos-generate-config --no-filesystems --show-hardware-config > hosts/lite/hardware-configuration.nix
{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "ehci_pci" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
