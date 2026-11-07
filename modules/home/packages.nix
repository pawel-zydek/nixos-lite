{ pkgs, ... }:
{
  # Lekkie zamienniki (GTK lub terminal). RAM zajmuje tylko to, co jest uruchomione,
  # ale ciężkie programy Electron zostawiamy zakomentowane - włącz, jeśli naprawdę potrzebujesz.
  home.packages = with pkgs; [
    pcmanfm                       # Lekki menedżer plików
    imv                           # Przeglądarka obrazów
    libreoffice                   # Pakiet biurowy (ciężki tylko, gdy jest otwarty)
    hunspell                      # Silnik sprawdzania pisowni
    hunspellDicts.pl_PL           # Polski słownik (pl_PL)
    keepassxc                     # Menedżer haseł
    remmina                       # Klient RDP i VNC
    ncdu                          # Zużycie dysku (w terminalu)
    lame flac vorbis-tools opus-tools   # kodery MP3, FLAC, Ogg

    # --- Electron/CEF: każdy z nich to 200-500 MB RAM ---
    # obsidian                    # Notatki w MD (zamiennik: vim + katalog z plikami .md)
    # spotify                     # Klient Spotify (zamiennik: odtwarzacz w przeglądarce)
    # drawio                      # Diagramy (zamiennik: app.diagrams.net w przeglądarce)
    # anki-bin                    # Fiszki (Qt, ~200 MB)
  ];

  # Odtwarzacz wideo zamiast VLC - lżejszy i dobrze korzysta ze sprzętowego dekodowania
  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";        # VA-API (modules/nixos/hardware/intel-graphics.nix)
      vo = "gpu";
      profile = "fast";           # mniej obróbki obrazu - mniej pracy dla starego GPU
    };
  };

  # Przeglądarka PDF sterowana z klawiatury (jak vim)
  programs.zathura.enable = true;
}
