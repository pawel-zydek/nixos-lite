{ ... }:
{
  # Lenovo IdeaPad 110-15IBR (typ 80T7), 2016:
  #   - Intel Celeron N3060 (2 rdzenie) lub Pentium N3710 (4 rdzenie), rodzina Braswell
  #   - grafika Intel HD 400/405 (Gen8) - VA-API tylko przez sterownik i965
  #   - 4 GB DDR3L, ekran 1366x768, dysk SATA (HDD 5400 obr. lub SSD po wymianie)
  #   - UEFI, Wi-Fi + Bluetooth na jednej karcie (Realtek lub Qualcomm Atheros)
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  # --- Tożsamość hosta ---
  networking.hostName = "nixos-lite";

  # Dysk systemowy. Numer seryjny jest inny w każdym egzemplarzu, więc wpisuje go
  # skrypt podczas instalacji (README, krok 4): ./scripts/ustaw-dysk.sh
  my.disk = "/dev/disk/by-id/ata-KINGSTON_SV300S37A120G_50026B7243091A57";

  # --- Co jest włączone na tym hoście ---
  my.storage.btrfs.enable = true;
  my.desktop.sway.enable = true;
  my.audio.enable = true;

  my.hardware.firmware.enable = true;
  my.hardware.intelGraphics.enable = true;
  my.hardware.laptop.enable = true;
  my.hardware.bluetooth.enable = true;

  # my.services.printing.enable = true;
  my.services.ssh.enable = true;

  # Klucze, którymi można logować się przez SSH (np. z PG, żeby budować konfigurację tam)
  users.users.pawel.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlKrUMXtKlnlbGQgiioga7bd/StVWdbAwz+1jJ7+vQO pawel@nixos-pg"
  ];

  # Wersja systemu, na której pierwotnie zainstalowano NixOS - nie zmieniać
  system.stateVersion = "26.05";
}
