{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    vericert.url = "path:vericert";
  };

  outputs = {
    vericert,
    nixpkgs,
    ...
  }: let
    common = import ./common.nix;
  in {
    packages = common.each nixpkgs (
      pkgs: {
        vericert = vericert.packages.${pkgs.stdenv.hostPlatform.system}.vericert;
      }
    );
  };
}
