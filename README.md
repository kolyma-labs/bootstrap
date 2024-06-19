<p align="center">
    <img src=".github/assets/header.png" alt="Kolyma's {Bootstrap}">
</p>

<p align="center">
    <h3 align="center">Bootstraping server starting from partition to configs.</h3>
</p>

<p align="center">
    <img align="center" src="https://img.shields.io/github/languages/top/kolyma-labs/bootstrap?style=flat&logo=nixos&logoColor=ffffff&labelColor=242424&color=242424" alt="Top Used Language">
    <a href="https://github.com/kolyma-labs/bootstrap/actions/workflows/build.yml"><img align="center" src="https://img.shields.io/github/actions/workflow/status/kolyma-labs/bootstrap/build.yml?style=flat&logo=github&logoColor=ffffff&labelColor=242424&color=242424" alt="Test CI"></a>
</p>

# About

When you buy a server, specifically from Hetzner, you are not given the option to install NixOS. This repository provides an easy way to install NixOS on a Hetzner server using the [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) tool.

## Quickstart

[![Watch the walkthrough video](https://img.youtube.com/vi/nlX8g0NXW1M/hqdefault.jpg)](https://www.youtube.com/watch?v=nlX8g0NXW1M)

* Order a server on Hetzner Robot
    * For this tutorial, I am using an [AX41-NVMe](https://www.hetzner.com/dedicated-rootserver/ax41-nvme)
    * The `disk-config.nix` file sets software RAID 1 on the 2x 512GB NVMe SSDs (just as the delivered server has)
* Set your SSH public key in `robot.nix` and `linux.nix`
* Go through all the `FIXME:` notices in this repo and make changes wherever
  you want
* Make sure you have activated the [Hetzner Rescue System](https://docs.hetzner.com/robot/dedicated-server/troubleshooting/hetzner-rescue-system/) by enabling it and then doing an automated hardware reset on the Robot web console
* Run [`nixos-anywhere`](https://github.com/nix-community/nixos-anywhere)
  against `root@<server-ip-address>`
```bash
nix run github:numtide/nixos-anywhere -- --flake .#robot root@<server-ip-address>
```
* Wait for the installation to complete
* Try to SSH into the server with `ssh <your-username-selected-in-flake.nix>@<server-ip-address>`
* You'll probably receive an error like the one below; follow the steps to remove the ip address from `known_hosts`
```
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ED25519 key sent by the remote host is
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.
Please contact your system administrator.
Add correct host key in ~/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in ~/.ssh/known_hosts:6
  remove with:
  ssh-keygen -f ~/.ssh/known_hosts" -R "<ip addrress>"
Host key for <ip_address> has changed and you have requested strict checking.
Host key verification failed.
```
* Now you can SSH into the server
* In a local terminal window, you can apply updated configurations to the remote server
```bash
nix run github:serokell/deploy-rs -- --remote-build -s .#robot
```

Note: If developing in Rust, you'll still be managing your toolchains and components like `rust-analyzer` with `rustup`!

## Project Layout

In order to keep the template as approachable as possible for new NixOS users,
this project uses a flat layout without any nesting or modularization.

* `flake.nix` is where dependencies are specified
    * `nixpkgs` is the current release of NixOS
    * `nixpkgs-unstable` is the current trunk branch of NixOS (ie. all the
      latest packages)
    * `home-manager` is used to manage everything related to your home
      directory (dotfiles etc.)
    * `nur` is the community-maintained [Nix User
      Repositories](https://nur.nix-community.org/) for packages that may not
      be available in the NixOS repository
    * `nix-index-database` tells you how to install a package when you run a
      command which requires a binary not in the `$PATH`
    * `disko` is used to prepare VM storage for NixOS
* `robot.nix` is where OpenSSH is configured and where the `root` SSH public
  key is set
* `linux.nix` is where the server is configured
    * The hostname is set here
    * The default shell is set here
    * User groups are set here
    * NixOS options are set here
* `home.nix` is where packages, dotfiles, terminal tools, environment variables
  and aliases are configured

## License

This project is licensed under the MIT License - see the [LICENSE](license) file for details.

<p align="center">
    <img src=".github/assets/footer.png" alt="Kolyma's {Installer}">
</p>