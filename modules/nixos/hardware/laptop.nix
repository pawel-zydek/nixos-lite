{ config, lib, pkgs, ... }:
let
  cfg = config.my.hardware.laptop;
in
{
  options.my.hardware.laptop.enable = lib.mkEnableOption "zarządzanie energią laptopa (TLP, thermald, bateria)";

  config = lib.mkIf cfg.enable {
    # TLP: oszczędzanie energii na baterii, pełna wydajność na zasilaczu
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      };
    };
    # TLP i power-profiles-daemon wykluczają się
    services.power-profiles-daemon.enable = false;

    # Pilnuje temperatury procesorów Intel (mniej głośnego wentylatora i throttlingu)
    services.thermald.enable = true;

    # Stan baterii dla paska i programów
    services.upower.enable = true;

    # Zamknięcie klapy = uśpienie (na zasilaczu też)
    services.logind.settings.Login.HandleLidSwitch = "suspend";

    environment.systemPackages = [ pkgs.brightnessctl ];   # jasność ekranu (klawisze w Sway)
  };
}
