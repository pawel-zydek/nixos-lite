{ config, lib, pkgs, ... }:
let
  cfg = config.my.hardware.intelGraphics;
in
{
  options.my.hardware.intelGraphics.enable = lib.mkEnableOption "sprzętowe dekodowanie wideo na grafice Intel HD 400/405 (Braswell)";

  config = lib.mkIf cfg.enable {
    # Sprzętowe dekodowanie wideo (VA-API) w Firefoksie i mpv - na Celeronie/Pentium N
    # to różnica między płynnym filmem a 100% CPU.
    # Braswell nie jest obsługiwany przez nowszy intel-media-driver (iHD, od Broadwell "Core"),
    # więc używamy starszego sterownika i965.
    # Sprzętowo: H.264, HEVC 8-bit, VP8, MPEG-2, VC-1. Brak VP9 i AV1 - dlatego Firefox
    # ma wyłączone VP9/AV1 (modules/home/firefox.nix), a YouTube wysyła wtedy H.264.
    # Wczesne KMS: sterownik grafiki ładowany już w initrd, więc obraz w natywnej
    # rozdzielczości i komunikaty startowe są widoczne od początku (bez długiego czarnego ekranu)
    boot.initrd.kernelModules = [ "i915" ];

    hardware.graphics.enable = true;
    hardware.graphics.extraPackages = [ pkgs.intel-vaapi-driver ];
    environment.sessionVariables.LIBVA_DRIVER_NAME = "i965";
  };
}
