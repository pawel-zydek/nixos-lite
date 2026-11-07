{ ... }:
{
  # Home Manager użytkownika pawel: wybór modułów z modules/home/
  imports = [
    ../modules/home/git.nix           # konfiguracja gita
    ../modules/home/vim.nix           # konfiguracja vima
    ../modules/home/bash.nix          # konfiguracja powłoki Bash
    ../modules/home/firefox.nix       # instalacja i konfiguracja Firefoksa
    ../modules/home/thunderbird.nix   # instalacja i konfiguracja Thunderbirda
    ../modules/home/sway.nix          # Sway, pasek, blokada ekranu, powiadomienia, motyw
    ../modules/home/foot.nix          # terminal
    ../modules/home/packages.nix      # dodatkowe programy
    ../modules/home/gpg.nix           # obsługa GPG
    ../modules/home/ssh.nix           # agent SSH
  ];

  # wersja z pierwszego wdrożenia; nie zmieniamy przy aktualizacjach
  home.stateVersion = "26.05";
}
