{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    vericert = {
      url = "path:vericert";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs =
    inputs@{
      vericert,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];

        flake = {
          overlays = import ./src/overlays.nix nixpkgs.lib;
        };

        perSystem =
          {
            pkgs,
            lib,
            system,
            ...
          }:
          let
            skipCheck = p: (system == "aarch64-linux" && p == "verus");
          in
          rec {
            checks = lib.filterAttrs (p: _: !(skipCheck p)) packages;
            packages =
              let
                openwebstart = pkgs.callPackage ./src/openwebstart.nix { };
                generated = pkgs.callPackage ./src/generated.nix { };
                vscode = pkgs.callPackage ./src/vscode.nix { inherit generated; };
                verus = pkgs.callPackage ./src/verus.nix { inherit generated; };
              in
              {
                inherit (vscode) vscode vscode-insider;
                inherit openwebstart;
                vericert = vericert.packages.${system}.vericert;
                pop-wallpaper = generated.pop-wallpaper.src;
                nordic-wallpaper = generated.nordic-wallpaper.src;
              }
              // (lib.optionalAttrs (system != "aarch64-linux") { inherit verus; });
          };
      }
    );
}
