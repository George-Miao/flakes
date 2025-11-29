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
        perSystem =
          { pkgs, system, ... }:
          {
            packages =
              let
                generated = import ./src/generated.nix pkgs;
                vscode = import ./src/vscode.nix pkgs;
              in
              {
                inherit (vscode) vscode vscode-insider;
                vericert = vericert.packages.${system}.vericert;
                pop-wallpaper = generated.pop-wallpaper.src;
                nordic-wallpaper = generated.nordic-wallpaper.src;
              };
          };
      }
    );
}
