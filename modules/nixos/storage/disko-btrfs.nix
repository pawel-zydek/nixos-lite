{ lib, config, ... }:
{
  # Układ dysku: ESP 1G + LUKS2 + btrfs z subwolumenami.
  # Działa tylko, gdy host poda my.disk.
  options.my.disk = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "Ścieżka do dysku, np. /dev/disk/by-id/...";
  };

  config.disko.devices = lib.mkIf (config.my.disk != null) {
    disk.main = {
      type = "disk";
      device = config.my.disk;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              # Szyfrowanie całego systemu. Celeron N3060 / Pentium N3710 mają AES-NI,
              # więc LUKS prawie nie spowalnia dysku.
              type = "luks";
              name = "cryptroot";
              # bez passwordFile - disko zapyta o hasło przy formatowaniu
              settings.allowDiscards = true;   # TRIM przez LUKS (gdy dysk to SSD)
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];          # nadpisz stary system plików bez pytania
                subvolumes =
                  let
                    # zstd:1 - najszybszy poziom kompresji: mniej danych do zapisu/odczytu,
                    # co na wolnym dysku daje więcej, niż kosztuje procesor.
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
            };
          };
        };
      };
    };
  };
}
