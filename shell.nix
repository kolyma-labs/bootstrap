{
  pkgs ? let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
    import nixpkgs {overlays = [];},
  ...
}:
pkgs.stdenv.mkDerivation {
  name = "bootstrap";

  nativeBuildInputs = with pkgs; [
    git
    just
    nixd
    alejandra
    statix
    deadnix
  ];

  NIX_CONFIG = "extra-experimental-features = nix-command flakes";
}
