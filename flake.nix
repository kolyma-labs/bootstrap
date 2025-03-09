{
  description = "NixOS configuration for affecting servers";

  inputs = {
    # NixOS 24.11 & Unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake utils for eachSystem
    flake-utils.url = "github:numtide/flake-utils";

    # Nix User Repository
    nur.url = "github:nix-community/NUR";

    # Nix Index Database
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disko
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS config deployer
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

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
    in
      {
        nixosConfigurations.robot = mkNixosConfiguration {
          hostname = "robot";
          system = "aarch64-linux";
          username = "sakhib";
          modules = [
            disko.nixosModules.disko
            # ./amd.nix
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
              hostname = "65.109.74.214";
              profiles.system = {
                path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.robot;
              };
            };
          };
        };

        # This is highly advised, and will prevent many possible mistakes
        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      }
      // inputs.flake-utils.lib.eachDefaultSystem (
        system: let
          # Packages for the current <arch>
          pkgs = inputs.nixpkgs.legacyPackages.${system};
        in
          # Nixpkgs packages for the current system
          {
            # Development shells
            devShells.default = import ./shell.nix {inherit pkgs;};

            # Formatter for your nix files, available through 'nix fmt'
            # Other options beside 'alejandra' include 'nixpkgs-fmt'
            formatter = pkgs.alejandra;
          }
      );
}
