{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    vericert.url = "path:vericert";
    flake-parts.url = "github:hercules-ci/flake-parts";
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
          { pkgs, system, ... }:
          {
            packages =
              let
                generated = pkgs.callPackage ./src/generated.nix { };
                vscode = pkgs.callPackage ./src/vscode.nix { };
                openwebstart = pkgs.callPackage ./src/openwebstart.nix { };
              in
              {
                inherit (vscode) vscode vscode-insider;
                inherit openwebstart;
                vericert = vericert.packages.${system}.vericert;
                pop-wallpaper = generated.pop-wallpaper.src;
                nordic-wallpaper = generated.nordic-wallpaper.src;
              };
          };
      }
    );
}
