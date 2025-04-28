{lib, ...}: {
  imports = [./hardware-configuration.nix];

  boot.kernelModules = [];
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
