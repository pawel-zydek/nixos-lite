{ config, lib, ... }:
let
  cfg = config.my.hardware.bluetooth;
in
{
  options.my.hardware.bluetooth.enable = lib.mkEnableOption "Bluetooth";

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;   # włączany ręcznie - oszczędza baterię
    };
    # Okno parowania (blueman-manager); ikonę w zasobniku włącza modules/home/sway.nix
    services.blueman.enable = true;
  };
}
