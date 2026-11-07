{ ... }:
{
  # Przy 4 GB RAM to jest najważniejszy plik w repo.

  # Swap w RAM, kompresowany zstd (zwykle 3-4x). Przy 4 GB RAM daje
  # efektywnie ~6-8 GB pamięci, zanim system zacznie się dławić.
  # Bez partycji swap - na wolnym dysku swap na dysku i tak zamraża system.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;     # maks. rozmiar zram = 100% RAM (zajmuje tyle, ile faktycznie użyte)
  };

  boot.kernel.sysctl = {
    # Przy zram wymiana stron jest tania (to tylko kompresja w RAM),
    # więc jądro może z niej korzystać chętnie. Wartość zalecana dla zram.
    "vm.swappiness" = 180;
    # zram nie ma czasu dostępu jak dysk - czytanie stron "na zapas" nic nie daje
    "vm.page-cluster" = 0;
  };

  # Gdy pamięć się kończy, earlyoom zamyka najbardziej pamięciożerny proces
  # (zwykle kartę przeglądarki), zanim system zamarznie na kilka minut.
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;    # % wolnego RAM
    freeSwapThreshold = 10;  # % wolnego swapu
    enableNotifications = true;   # powiadomienie (mako), co zostało zamknięte
  };
  # earlyoom zamiast systemd-oomd - nie dublujemy mechanizmów
  systemd.oomd.enable = false;
}
