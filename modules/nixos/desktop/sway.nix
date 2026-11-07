{ config, lib, pkgs, ... }:
let
  cfg = config.my.desktop.sway;
  sway = "${config.programs.sway.package}/bin/sway";   # Sway z NixOS (z poprawkami GTK)
in
{
  options.my.desktop.sway.enable = lib.mkEnableOption "menedżer okien Sway (Wayland) z ekranem logowania greetd";

  config = lib.mkIf cfg.enable {
    # Sway od strony systemu: PAM dla swaylock, polkit, portale XDG, XWayland.
    # Konfiguracja użytkownika (skróty, pasek, wygląd) jest w modules/home/sway.nix.
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;      # poprawne motywy i czcionki w programach GTK
      extraPackages = [ ];             # bez domyślnego zestawu (foot, dmenu...) - dostarcza je Home Manager
    };

    # greetd: lekki menedżer logowania (kilka MB; LightDM/SDDM - kilkadziesiąt).
    services.greetd = {
      enable = true;
      settings = {
        # Autologowanie: po starcie systemu od razu Sway jako pawel, bez pytania o hasło
        initial_session = {
          command = sway;
          user = "pawel";
        };
        # Po wylogowaniu (Super+Shift+e) - tekstowy ekran logowania tuigreet
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd ${sway}";
          user = "greeter";
        };
      };
    };

    # Magazyn haseł (Secret Service) - z niego korzysta git (credential.helper = libsecret).
    # Przy autologowaniu nie ma hasła, którym mógłby się odblokować - przy pierwszym
    # zapisie (git push) poprosi o utworzenie magazynu "login": puste hasło = odblokowany
    # zawsze, ale zapisany niezaszyfrowany (README, krok 11).
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;
    programs.seahorse.enable = true;    # podgląd zapisanych haseł

    # Programy Electron/Chromium (Obsidian, Spotify, ...) natywnie na Waylandzie,
    # bez XWaylanda - mniej RAM-u i ostrzejszy obraz
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    fonts = {
      enableDefaultPackages = true;
      packages = [ pkgs.font-awesome ];   # ikony w pasku i powiadomieniach
    };

    environment.systemPackages = with pkgs; [
      pavucontrol         # mikser dźwięku
      networkmanagerapplet  # nm-applet w zasobniku + nm-connection-editor
    ];
  };
}
