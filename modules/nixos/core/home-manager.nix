{ ... }:
{
  # Home Manager jako moduł NixOS - konfiguracja użytkownika jest częścią generacji
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    users.pawel = import ../../../users/pawel.nix;
  };
}
