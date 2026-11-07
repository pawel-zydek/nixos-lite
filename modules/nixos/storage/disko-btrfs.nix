{ lib, config, ... }:
let
  cfg = config.my.storage;

  # btrfs z subwolumenami - ten sam blok niezależnie od tego, czy jest pod LUKS
  btrfsContent = {
    type = "btrfs";
    extraArgs = [ "-f" ];            # nadpisz stary system plików bez pytania
    subvolumes =
      let
        # zstd:1 - najszybszy poziom kompresji: mniej danych do zapisu/odczytu,
        # co na starym dysku daje więcej, niż kosztuje procesor.
        # noatime - brak zapisu przy każdym odczycie pliku.
        opts = [ "compress=zstd:1" "noatime" ];
      in
      {
        "@"     = { mountpoint = "/";        mountOptions = opts; };
        "@home" = { mountpoint = "/home";    mountOptions = opts; };
        "@nix"  = { mountpoint = "/nix";     mountOptions = opts; };
        "@log"  = { mountpoint = "/var/log"; mountOptions = opts; };
      };
  };
in
{
  # Układ dysku: partycja BIOS boot + ESP 1G + (LUKS2 →) btrfs.
  # Działa tylko, gdy host poda my.disk.
  options.my.disk = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "Ścieżka do dysku, np. /dev/disk/by-id/...";
  };

  options.my.storage.encryption = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Szyfrowanie LUKS2 całego systemu (hasło przy starcie)";
  };

  config.disko.devices = lib.mkIf (config.my.disk != null) {
    disk.main = {
      type = "disk";
      device = config.my.disk;
      content = {
        type = "gpt";
        partitions = {
          # 1 MB dla GRUB-a w trybie BIOS (my.boot.legacyBios). Przy UEFI nieużywana.
          bios = {
            size = "1M";
            type = "EF02";
            priority = 1;
          };
          ESP = {
            size = "1G";
            type = "EF00";
            priority = 2;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content =
              if cfg.encryption then {
                type = "luks";
                name = "cryptroot";
                # bez passwordFile - disko zapyta o hasło przy formatowaniu
                settings.allowDiscards = true;   # TRIM przez LUKS (SSD)
                content = btrfsContent;
              }
              else btrfsContent;
          };
        };
      };
    };
  };
}
