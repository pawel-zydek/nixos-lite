{
  description = "Konfiguracja NixOS starego laptopa (host nixos-lite): Sway na btrfs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... }@inputs: {
    # Lista hostów. Cała logika jest w hosts/ i modules/.
    # Nazwa = hostname, więc `sudo nixos-rebuild switch --flake .` sam wybiera właściwy host.
    nixosConfigurations = {
      nixos-lite = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };   # `inputs` dostępne w każdym module
        modules = [ ./hosts/lite ];
      };
    };

    # `nix fmt` - formatowanie wszystkich plików .nix w repo
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
  };
}
