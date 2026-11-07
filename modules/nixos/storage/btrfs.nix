{ config, lib, ... }:
let
  cfg = config.my.storage.btrfs;
in
{
  options.my.storage.btrfs.enable = lib.mkEnableOption "btrfs (scrub, TRIM, snapshoty /home przez snapper)";

  config = lib.mkIf cfg.enable {
    # Raz w miesiącu sprawdzenie sum kontrolnych wszystkich danych (odpowiednik zpool scrub)
    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };

    # TRIM raz w tygodniu (SSD); na dysku talerzowym nic nie robi
    services.fstrim.enable = true;

    # Planista I/O dobierany automatycznie do rodzaju dysku - nie trzeba wiedzieć,
    # czy w laptopie jest jeszcze fabryczny HDD, czy SSD:
    #   HDD (rotational=1) -> bfq: system i okna reagują, gdy w tle trwa duży zapis (np. nixos-rebuild)
    #   SSD (rotational=0) -> mq-deadline: najmniejszy narzut na słabym procesorze
    services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    '';

    # Snapshoty /home - odpowiednik sanoid z laptopa PG (24 h / 7 dni / 3 mies.).
    # Snapshot btrfs nie zajmuje RAM-u i prawie nie zajmuje miejsca, dopóki pliki się nie zmienią.
    services.snapper = {
      persistentTimer = true;   # nadrabia zaległe snapshoty po włączeniu laptopa
      configs.home = {
        SUBVOLUME = "/home";
        ALLOW_USERS = [ "pawel" ];       # `snapper -c home list` bez sudo
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = 24;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 0;
        TIMELINE_LIMIT_MONTHLY = 3;
        TIMELINE_LIMIT_YEARLY = 0;
      };
    };

    # snapper wymaga subwolumenu /home/.snapshots - "v" w tmpfiles tworzy go przy starcie,
    # jeśli jeszcze nie istnieje
    systemd.tmpfiles.rules = [ "v /home/.snapshots 0750 root users -" ];
  };
}
