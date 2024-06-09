{
  description = "NixOS configuration for affecting servers";

  # NixOS 22.11 (idk why, kexec works fine with 22.11)
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
  inputs.nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

  # Home Manager
  inputs.home-manager.url = "github:nix-community/home-manager/release-22.11";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  # Nix User Repository
  inputs.nur.url = "github:nix-community/NUR";

  # Nix Index Database
  inputs.nix-index-database.url = "github:Mic92/nix-index-database";
  inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

  # Disko
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  # NixOS config deployer
  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs:
    with inputs; let
      # If theres secrets in the secrets.json file
      # secrets = builtins.fromJSON (builtins.readFile "${self}/secrets.json");

      nixpkgsWithOverlays = with inputs; rec {
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
          ];
        };
        overlays = [
          nur.overlay
          (_final: prev: {
            # this allows us to reference pkgs.unstable
            unstable = import nixpkgs-unstable {
              inherit (prev) system;
              inherit config;
            };
          })
        ];
      };

      configurationDefaults = args: {
        nixpkgs = nixpkgsWithOverlays;
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-backup";
        home-manager.extraSpecialArgs = args;
      };

      argDefaults = {
        inherit inputs self nix-index-database;
        channels = {
          inherit nixpkgs nixpkgs-unstable;
        };
      };

      mkNixosConfiguration = {
        system ? "x86_64-linux",
        hostname,
        username,
        args ? {},
        modules,
      }: let
        specialArgs = argDefaults // {inherit hostname username;} // args;
      in
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules =
            [
              (configurationDefaults specialArgs)
              home-manager.nixosModules.home-manager
            ]
            ++ modules;
        };
    in {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

      nixosConfigurations.robot = mkNixosConfiguration {
        hostname = "robot";
        username = "sakhib";
        modules = [
          ./amd.nix
          disko.nixosModules.disko
          ./robot.nix
          ./linux.nix
        ];
      };

      deploy = {
        sshUser = "sakhib";
        user = "sakhib";
        autoRollback = false;
        magicRollback = false;
        remoteBuild = true;
        nodes = {
          robot = {
            hostname = "95.216.248.236";
            profiles.system = {
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.robot;
            };
          };
        };
      };

      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
