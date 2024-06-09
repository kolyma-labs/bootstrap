{
  secrets,
  username,
  hostname,
  pkgs,
  inputs,
  ...
}: {
  time.timeZone = "Europe/Helsinki";

  systemd.tmpfiles.rules = [
    "d /home/${username}/.config 0755 ${username} users"
  ];

  networking.hostName = "${hostname}";

  programs.zsh.enable = true;
  environment.pathsToLink = ["/share/zsh"];
  environment.shells = [pkgs.zsh];

  environment.enableAllTerminfo = true;

  security.sudo.wheelNeedsPassword = false;

  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDAGqU+JleLM0T44P2quirtLPrhFExOi6EOe0GYXkTFcTSjhw9LqiuX1/FbqNdKTaP9k6CdV3xc/8Z5wxbNOhpcPi9XLoupv9oNyIew7QYl+ZoAck6/qPsM7uptGYCwo0/ErzPNLd3ERD3KT1axCqrI6rWJ+JFOMAPtGeAZZxIedksViZ5SuNhpzXCIzS2PACqDTxFj7JwXK/pQ200h9ZS0MSh7iLKggXQfRVDndJxRnVY69NmbRa4MqkjgyxqWSDbqrDAXuTHpqKJ5kpXJ6p2a82EIHcCwXXpEmLwKxatxWJWJb9nurm3aS74BYmT3pRVVSPC6n5a2LWN9GxzvVh3AXXZtWGvjXSqBxHdSyUoDPuZnDneycdRC5vs6I1jSGTyDFdc4Etq1M5uUYb6SqCjJIBvTNqVnOf8nzFwl/ENvc8sbIVtILgAbBdwDiiQSu8xppqWMZfkQJy+uI5Ok7TZ8o5rGIblzfKyTiljCQb7RO7Klg3TwysetREn8ZEykBx0= This world soon will cherish into my darkness of my madness"
    ];
  };

  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
  };

  system.stateVersion = "23.11";

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  nix = {
    settings = {
      trusted-users = [username];
      access-tokens = [
        "github.com=${secrets.github_token}"
        # "gitlab.com=OAuth2:${secrets.gitlab_token}"
      ];

      accept-flake-config = true;
      auto-optimise-store = true;
    };

    registry = {
      nixpkgs = {
        flake = inputs.nixpkgs;
      };
    };

    nixPath = [
      "nixpkgs=${inputs.nixpkgs.outPath}"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];

    package = pkgs.nixFlakes;
    extraOptions = ''experimental-features = nix-command flakes'';

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };
}
