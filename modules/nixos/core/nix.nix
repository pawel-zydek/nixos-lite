{ ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Automatyczne sprzątanie starych generacji i /nix/store
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;   # deduplikacja plików w /nix/store

  # Bez budowania podręcznika NixOS (`man configuration.nix`) przy każdym nixos-rebuild -
  # na Celeronie oszczędza to sporo czasu i RAM-u. Opcje są na https://search.nixos.org/options
  documentation.nixos.enable = false;

  # Zezwolenie na niewolne pakiety
  nixpkgs.config.allowUnfree = true;
}
