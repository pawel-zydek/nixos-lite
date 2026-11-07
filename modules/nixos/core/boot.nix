{ ... }:
{
  # Bootloader (IdeaPad 110 ma UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;   # maksymalna liczba generacji w menu
  boot.loader.efi.canTouchEfiVariables = true;

  # Cichy start bez Plymouth (krótszy start, mniejszy initrd).
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [ "quiet" "udev.log_level=3" ];

  # initrd oparty o systemd - szybszy start
  boot.initrd.systemd.enable = true;
}
