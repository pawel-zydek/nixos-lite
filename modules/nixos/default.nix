{ inputs, ... }:
{
  # Wszystkie moduły systemowe. Moduły z core/ działają zawsze,
  # pozostałe nic nie robią, dopóki host ich nie włączy (my.<nazwa>.enable = true).
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager

    ./core/nix.nix
    ./core/boot.nix
    ./core/memory.nix
    ./core/locale.nix
    ./core/users.nix
    ./core/packages.nix
    ./core/home-manager.nix

    ./storage/disko-btrfs.nix
    ./storage/btrfs.nix
    ./storage/ntfs.nix

    ./desktop/sway.nix
    ./desktop/audio.nix

    ./hardware/firmware.nix
    ./hardware/intel-graphics.nix
    ./hardware/laptop.nix
    ./hardware/bluetooth.nix

    ./services/ssh.nix
    ./services/printing.nix
  ];
}
