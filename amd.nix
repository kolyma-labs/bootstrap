{lib, ...}: {
  imports = [./hardware-configuration.nix];

  boot.kernelModules = ["kvm-amd"];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
