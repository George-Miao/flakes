rec {
  systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
  each = nixpkgs: f:
    nixpkgs.lib.genAttrs systems (
      system: f nixpkgs.legacyPackages.${system}
    );
}
