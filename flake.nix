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
  outputs = { self, nixpkgs, nix-doom-emacs, emacs-overlay, flake-utils }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; overlays = [ emacs-overlay.overlays.default ]; };
      doom-emacs = nix-doom-emacs.packages.${system}.default.override {
        doomPrivateDir = ./doom;
        doomPackageDir = pkgs.linkFarm "my-doom-packages" [
          { name = "config.el"; path = pkgs.emptyFile; }
          { name = "init.el"; path = ./doom/init.el; }
          { name = "packages.el"; path = ./doom/packages.el; }
        ];
        extraPackages = epkgs: with pkgs;[
          fd
          findutils
          ripgrep
        ];
      };
      gnu-emacs = pkgs.emacs.pkgs.withPackages
        (epkgs: (with epkgs.melpaStablePackages; [
          (pkgs.runCommand "default.el" { } ''
            mkdir -p $out/share/emacs/site-lisp
            cp -r ${./gnu} $out/share/emacs/site-lisp/
          '')
          dracula-theme
        ]));
      inherit (flake-utils.lib) mkApp;
    in
    {
      inherit doom-emacs gnu-emacs;

      packages.x86_64-linux.gnu-emacs = self.gnu-emacs;
      packages.x86_64-linux.doom-emacs = self.doom-emacs;
      packages.x86_64-linux.default = self.packages.x86_64-linux.doom-emacs;

      apps.x86_64-linux.gnu-emacs = mkApp { drv = self.packages.x86_64-linux.gnu-emacs; exePath = "/bin/emacs"; };
      apps.x86_64-linux.doom-emacs = mkApp { drv = self.packages.x86_64-linux.doom-emacs; exePath = "/bin/emacs"; };
    };
}
