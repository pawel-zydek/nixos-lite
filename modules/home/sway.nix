{ config, lib, pkgs, osConfig, ... }:
let
  mod = config.wayland.windowManager.sway.config.modifier;
  wallpaper = ../../assets/wallpapers/NixOS/NixOS-Simple-Blue.png;
  lock = "${pkgs.swaylock}/bin/swaylock -f";
  fuzzel = "${pkgs.fuzzel}/bin/fuzzel";

  # Super+Shift+d: dowolne polecenie, jak dmenu_run w i3 (lista wszystkich programów z PATH)
  runner = pkgs.writeShellScript "uruchom" ''
    compgen -c | sort -u | ${fuzzel} --dmenu --prompt "uruchom: " | xargs -r swaymsg exec --
  '';

  # Tryb zasilania (Super+Shift+e) - nazwa trybu wyświetla się na pasku jako podpowiedź
  powerMode = "zasilanie: (w)yloguj  (u)śpij  (r)estart  (p)wyłącz  [Esc] anuluj";
in
{
  # Konfiguracja Sway (~/.config/sway/config). Sesję uruchamia greetd (modules/nixos/desktop/sway.nix).
  # Składnia i skróty są takie same jak w i3: https://i3wm.org/docs/refcard.html
  # Opis wszystkich opcji: `man 5 sway`, `man 5 sway-input`, `man 5 sway-output`
  wayland.windowManager.sway = {
    enable = true;
    package = null;            # sam Sway jest instalowany przez NixOS (programs.sway)
    checkConfig = false;       # sprawdzanie wymaga pakietu Sway w Home Managerze
    systemd.enable = true;     # sway-session.target - startuje usługi użytkownika (mako, gpg-agent...)

    config = {
      modifier = "Mod4";       # klawisz Super (Windows)
      terminal = "footclient"; # okno terminala podłączane do serwera foot (modules/home/foot.nix)
      menu = fuzzel;   # Super+d: programy z plikami .desktop (te z menu w Plasmie)

      fonts = {
        names = [ "DejaVu Sans" ];
        size = 10.0;
      };

      # Klawiatura i touchpad (`swaymsg -t get_inputs` pokazuje urządzenia)
      input = {
        "type:keyboard" = {
          xkb_layout = "pl";
          xkb_numlock = "enabled";
        };
        "type:touchpad" = {
          tap = "enabled";                # stuknięcie = kliknięcie
          natural_scroll = "enabled";
          dwt = "enabled";                # touchpad wyłączony podczas pisania
        };
      };

      # Tapeta bez dodatkowego programu (swaybg startuje sam Sway)
      output."*".bg = "${wallpaper} fill";

      window = {
        border = 2;
        titlebar = false;        # bez pasków tytułu (widać je w trybie kart: Mod+w)
      };
      focus.followMouse = false;

      # Start na obszarze 1. Bez tego Sway startuje na 10: Home Manager zapisuje skróty
      # alfabetycznie, więc "Mod4+0" (obszar 10) jest pierwszym skrótem do obszaru w pliku.
      defaultWorkspace = "workspace number 1";

      # Reguły dla okien (`swaymsg -t get_tree` pokazuje app_id i title)
      window.commands = [
        # małe okna ustawień jako pływające, zamiast dzielić ekran na pół
        { criteria.app_id = "pavucontrol"; command = "floating enable"; }
        { criteria.app_id = "nm-connection-editor"; command = "floating enable"; }
        { criteria.app_id = ".blueman-manager-wrapped"; command = "floating enable"; }
        # obraz w obrazie z Firefoksa: pływający i widoczny na każdym obszarze roboczym
        { criteria.title = "^Obraz w obrazie$|^Picture-in-Picture$"; command = "floating enable, sticky enable"; }
      ];

      keybindings = lib.mkOptionDefault {
        # blokada ekranu
        "${mod}+Shift+x" = "exec ${lock}";

        # dowolne polecenie (np. poweroff, btop, nmtui)
        "${mod}+Shift+d" = "exec ${runner}";

        # tryb zasilania zamiast domyślnego pytania o wyjście z Sway
        "${mod}+Shift+e" = ''mode "${powerMode}"'';

        # zrzuty ekranu do schowka: cały ekran / zaznaczony obszar
        "Print" = "exec ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy";
        "Shift+Print" = ''exec ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy'';

        # klawisze multimedialne laptopa
        "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        # głośność bez klawiszy multimedialnych (np. w VM)
        "${mod}+Prior" = "exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";   # Page Up
        "${mod}+Next" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";           # Page Down
        "${mod}+End" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };

      # Tryby: po wejściu działają tylko klawisze z trybu (jak Super+r przy zmianie rozmiaru)
      modes = lib.mkOptionDefault {
        "${powerMode}" = {
          w = "exec swaymsg exit";
          u = "mode default, exec systemctl suspend";   # ekran zablokuje swayidle (before-sleep)
          r = "exec systemctl reboot";
          p = "exec systemctl poweroff";
          Escape = "mode default";
          Return = "mode default";
        };
      };

      startup = [
        # ikona sieci w zasobniku paska (Wi-Fi bez wpisywania nmcli)
        { command = "nm-applet --indicator"; }
      ];

      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3status}/bin/i3status";
          fonts = {
            names = [ "DejaVu Sans Mono" ];
            size = 10.0;
          };
        }
      ];
    };
  };

  # Pasek stanu: sieć, bateria, dysk, obciążenie, pamięć, głośność, data (ten sam program co w i3).
  # Kolejność według `position`. Opis modułów i formatów: `man i3status`
  programs.i3status = {
    enable = true;
    enableDefault = true;          # zestaw domyślny, poniżej zmiany względem niego
    modules = {
      "ipv6".enable = false;       # bez adresu IPv6
      "volume master" = {
        position = 8;
        settings = {
          format = "🔊 %volume";
          format_muted = "🔇 %volume";
          device = "pulse";        # PipeWire udostępnia interfejs PulseAudio
        };
      };
      "tztime local".position = 9; # zegar na końcu
    };
  };

  # Ekran blokady
  programs.swaylock = {
    enable = true;
    settings = {
      color = "1d2021";
      show-failed-attempts = true;
      indicator-caps-lock = true;
    };
  };

  # Bezczynność: blokada po 5 min, wyłączenie ekranu po 10 min, blokada przed uśpieniem
  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 300; command = lock; }
      {
        timeout = 600;
        command = "${pkgs.sway}/bin/swaymsg 'output * power off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * power on'";
      }
    ];
    events = {
      before-sleep = lock;
    };
  };

  # Powiadomienia (też od earlyoom, gdy zamknie program z braku pamięci)
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;     # ms
      font = "DejaVu Sans 10";
    };
  };

  # Wyszukiwarka programów (Mod+d)
  programs.fuzzel = {
    enable = true;
    settings.main = {
      font = "DejaVu Sans:size=11";
      terminal = "footclient";
    };
  };

  # Ikona Bluetooth w zasobniku - tylko gdy host ma włączony Bluetooth
  services.blueman-applet.enable = osConfig.my.hardware.bluetooth.enable;

  # Ciemny motyw programów GTK i kursor
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";   # programy libadwaita
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
    sway.enable = true;
  };

  home.packages = with pkgs; [
    wl-clipboard      # wl-copy / wl-paste - schowek w terminalu
    wireplumber       # wpctl - głośność
  ];
}
