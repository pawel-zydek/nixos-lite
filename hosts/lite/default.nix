{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  # --- Tożsamość hosta ---
  networking.hostName = "nixos-lite";

  # Dysk systemowy - uzupełnić przed instalacją (README, krok 4):
  #   ls -l /dev/disk/by-id/ | grep -v part
  my.disk = "/dev/disk/by-id/ata-WPISZ_TUTAJ_DYSK";

  # --- Co jest włączone na tym hoście ---
  my.storage.btrfs.enable = true;
  my.desktop.sway.enable = true;
  my.audio.enable = true;

  my.hardware.firmware.enable = true;
  my.hardware.intelGraphics.enable = true;
  # Procesor starszy niż Broadwell (Core 4. gen. i wcześniejsze, ok. 2014)?
  # Wtedy włącz stary sterownik VA-API (README, krok 4):
  # my.hardware.intelGraphics.legacy = true;
  my.hardware.laptop.enable = true;
  # my.hardware.bluetooth.enable = true;

  # Laptop bez UEFI (tylko tryb BIOS/Legacy) - GRUB zamiast systemd-boot:
  # my.boot.legacyBios = true;

  # my.services.printing.enable = true;
  my.services.ssh.enable = true;

  # Klucze, którymi można logować się przez SSH (np. z PG, żeby budować konfigurację tam)
  users.users.pawel.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlKrUMXtKlnlbGQgiioga7bd/StVWdbAwz+1jJ7+vQO pawel@nixos-pg"
  ];

  # Wersja systemu, na której pierwotnie zainstalowano NixOS - nie zmieniać
  system.stateVersion = "26.05";
}
