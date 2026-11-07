{ config, lib, pkgs, ... }:
let
  cfg = config.my.hardware.laptop;
in
{
  options.my.hardware.laptop.enable = lib.mkEnableOption "zarządzanie energią laptopa (TLP, bateria, klapa)";

  config = lib.mkIf cfg.enable {
    # TLP: oszczędzanie energii na baterii, pełna wydajność na zasilaczu
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        # Bateria IdeaPada 110 ma tylko 24 Wh - na baterii wyłączamy turbo
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
      };
    };
    # TLP i power-profiles-daemon wykluczają się
    services.power-profiles-daemon.enable = false;

    # Stan baterii dla paska i programów
    services.upower.enable = true;

    # Zamknięcie klapy = uśpienie (na zasilaczu też)
    services.logind.settings.Login.HandleLidSwitch = "suspend";

    environment.systemPackages = [ pkgs.brightnessctl ];   # jasność ekranu (klawisze w Sway)
  };
}
