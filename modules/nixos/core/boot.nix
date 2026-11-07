{ config, lib, ... }:
let
  cfg = config.my.boot;
in
{
  options.my.boot.legacyBios = lib.mkEnableOption ''
    GRUB zamiast systemd-boot - dla laptopów bez UEFI (tylko BIOS/Legacy).
    Układ dysku (disko-btrfs.nix) ma partycję BIOS boot, więc działa bez zmian'';

  config = lib.mkMerge [
    (lib.mkIf (!cfg.legacyBios) {
      boot.loader.systemd-boot.enable = true;
      boot.loader.systemd-boot.configurationLimit = 10;   # maksymalna liczba generacji w menu
      boot.loader.efi.canTouchEfiVariables = true;
    })

    (lib.mkIf cfg.legacyBios {
      boot.loader.grub = {
        enable = true;
        # Dysk dla GRUB-a ustawia disko - wykrywa partycję BIOS boot (EF02) w disko-btrfs.nix
        configurationLimit = 10;
      };
    })

    {
      # Cichy start bez Plymouth (krótszy start, mniejszy initrd).
      # Hasło LUKS jest pytane w zwykłej konsoli.
      boot.consoleLogLevel = 3;
      boot.initrd.verbose = false;
      boot.kernelParams = [ "quiet" "udev.log_level=3" ];

      # initrd oparty o systemd - szybszy start, ładniejsze pytanie o hasło LUKS
      boot.initrd.systemd.enable = true;
    }
  ];
}
