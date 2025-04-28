{lib, ...}: {
  imports = [./hardware-configuration.nix];

  boot.kernelModules = ["kvm-intel"];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
