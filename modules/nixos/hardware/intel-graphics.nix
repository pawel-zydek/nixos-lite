{ config, lib, pkgs, ... }:
let
  cfg = config.my.hardware.intelGraphics;
in
{
  options.my.hardware.intelGraphics = {
    enable = lib.mkEnableOption "sprzętowe dekodowanie wideo na grafice Intel";
    legacy = lib.mkEnableOption "stary sterownik VA-API (i965) dla procesorów sprzed Broadwell (przed 2014)";
  };

  config = lib.mkIf cfg.enable {
    # Sprzętowe dekodowanie wideo (VA-API) w Firefoksie i mpv - na starym procesorze
    # to różnica między płynnym YouTube a 100% CPU.
    hardware.graphics.enable = true;
    hardware.graphics.extraPackages = [
      (if cfg.legacy
       then pkgs.intel-vaapi-driver    # Sandy Bridge, Ivy Bridge, Haswell (i starsze)
       else pkgs.intel-media-driver)   # Broadwell (2014) i nowsze
    ];
    environment.sessionVariables.LIBVA_DRIVER_NAME = if cfg.legacy then "i965" else "iHD";
  };
}
