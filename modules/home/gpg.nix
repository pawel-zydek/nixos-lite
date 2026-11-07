{ pkgs, ... }:
{
  # instaluje gnupg i zarządza plikami konfiguracyjnymi w ~/.gnupg
  programs.gpg.enable = true;

  # agent GPG z okienkiem na hasło (GTK, współpracuje z GNOME Keyring)
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
    defaultCacheTtl = 1800;     # sekundy: jak długo agent pamięta hasło po użyciu
    maxCacheTtl = 7200;         # maksymalny czas pamiętania
  };

  home.packages = with pkgs; [
    paperkey                    # wydruk klucza tajnego
  ];
}
