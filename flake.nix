{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nix-doom-emacs = {
      url = "github:nix-community/nix-doom-emacs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nix-doom-emacs, emacs-overlay, flake-utils }:
  let
    system = "x86_64-linux";
    doom-emacs = nix-doom-emacs.packages.${system}.default.override {
      doomPrivateDir = ./.;
    };
    inherit(flake-utils.lib) mkApp;
  in {
    inherit doom-emacs;

    packages.x86_64-linux.default = self.doom-emacs;

    apps.x86_64-linux.default = mkApp { drv = self.packages.x86_64-linux.default; exePath = "/bin/emacs"; };
  };
}
