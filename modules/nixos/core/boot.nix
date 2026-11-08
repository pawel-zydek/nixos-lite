{ ... }:
{
  # Bootloader (IdeaPad 110 ma UEFI; Secure Boot musi być wyłączony - systemd-boot nie jest podpisany)
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;   # maksymalna liczba generacji w menu
  boot.loader.efi.canTouchEfiVariables = true;

  # Start z widocznymi komunikatami: jądro i systemd wypisują postęp ("[  OK  ] Started ...").
  # Widać, na czym start się zatrzymuje. Wersja cicha - zamiast tego:
  #   boot.kernelParams = [ "quiet" "udev.log_level=3" ];  boot.consoleLogLevel = 3;  boot.initrd.verbose = false;
  boot.kernelParams = [ "systemd.show_status=true" ];

  # initrd oparty o systemd - szybszy start
  boot.initrd.systemd.enable = true;
}
