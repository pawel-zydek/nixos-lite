{ config, lib, ... }:
let
  cfg = config.my.services.ssh;
in
{
  options.my.services.ssh.enable = lib.mkEnableOption "serwer SSH (tylko klucze, bez roota)";

  config = lib.mkIf cfg.enable {
    # port 22 otwiera się w zaporze automatycznie
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    # Pozwala wdrażać konfigurację zdalnie (nixos-rebuild --target-host)
    nix.settings.trusted-users = [ "root" "@wheel" ];
  };
}
