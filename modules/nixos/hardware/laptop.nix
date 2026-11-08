{ config, lib, pkgs, ... }:
let
  cfg = config.my.hardware.laptop;
in
{
  options.my.hardware.laptop.enable = lib.mkEnableOption "zarządzanie energią laptopa (TLP, bateria, klapa)";

  config = lib.mkIf cfg.enable {
    # TLP: oszczędzanie energii (dysk, USB, Wi-Fi, PCIe) na domyślnych ustawieniach.
    # Procesora celowo nie ograniczamy: z wyłączonym turbo i polityką "power" Celeron N3060
    # na baterii pracował przy 480 MHz i 100% obciążenia. Domyślnie TLP na baterii
    # ustawia "balance_power" i zostawia turbo, a procesor i tak zwalnia, gdy nic nie robi.
    # Stan: `sudo tlp-stat -p` (procesor), `sudo tlp-stat -s` (zasilacz/bateria).
    services.tlp.enable = true;
    # TLP i power-profiles-daemon wykluczają się
    services.power-profiles-daemon.enable = false;

    # Stan baterii dla paska i programów
    services.upower.enable = true;

    # Zamknięcie klapy = uśpienie (na zasilaczu też)
    services.logind.settings.Login.HandleLidSwitch = "suspend";

    environment.systemPackages = [ pkgs.brightnessctl ];   # jasność ekranu (klawisze w Sway)
  };
}
