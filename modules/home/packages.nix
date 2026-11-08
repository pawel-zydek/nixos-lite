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
    remmina                       # Klient RDP i VNC
    ncdu                          # Zużycie dysku (w terminalu)
    lame flac vorbis-tools opus-tools   # kodery MP3, FLAC, Ogg
    # Gry:
    wesnoth
  ];

  # Odtwarzacz wideo zamiast VLC - lżejszy i dobrze korzysta ze sprzętowego dekodowania
  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";        # VA-API (modules/nixos/hardware/intel-graphics.nix)
      vo = "gpu";
      profile = "fast";           # mniej obróbki obrazu - mniej pracy dla starego GPU
      # Filmy z sieci (`mpv https://youtube.com/...`): H.264 do 720p - ekran ma 768 linii,
      # a H.264 jest dekodowane sprzętowo (VP9/AV1 nie)
      ytdl-format = "bestvideo[height<=?720][vcodec^=avc1]+bestaudio/best[height<=?720]";
    };
  };

  # Przeglądarka PDF sterowana z klawiatury (jak vim)
  programs.zathura.enable = true;
}
