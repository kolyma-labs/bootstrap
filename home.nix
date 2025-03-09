{
  # secrets,
  config,
  pkgs,
  username,
  nix-index-database,
  ...
}: let
  unstable-packages = with pkgs.unstable; [
    bat
    bottom
    coreutils
    curl
    du-dust
    fd
    findutils
    fx
    git
    git-crypt
    htop
    jq
    killall
    mosh
    procs
    ripgrep
    sd
    helix
    tmux
    tree
    unzip
    wget
    zip
  ];

  stable-packages = with pkgs; [
    # key tools
    gnumake # for lunarvim
    gcc # for lunarvim
    gh # for bootstrapping
    just

    # local dev stuf
    mkcert
    httpie
  ];
in {
  imports = [
    nix-index-database.hmModules.nix-index
  ];

  home = {
    stateVersion = "24.11";
    username = "${username}";
    homeDirectory = "/home/${username}";

    sessionVariables.EDITOR = "helix";
    sessionVariables.SHELL = "/etc/profiles/per-user/${username}/bin/zsh";

    packages =
      stable-packages
      ++ unstable-packages
      ++ [];
  };

  programs = {
    home-manager.enable = true;

    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    nix-index-database.comma.enable = true;

    starship.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    zsh = {
      enable = true;
      autocd = true;
      history.size = 10000;
      history.save = 10000;
      enableCompletion = true;
      history.ignoreDups = true;
      history.ignoreSpace = true;
      autosuggestion.enable = true;
      history.expireDuplicatesFirst = true;
      historySubstringSearch.enable = true;
    };
  };
}
