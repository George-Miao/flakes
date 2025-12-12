lib: rec {
  default = lib.composeManyExtensions [
    vscode
    vericert
    wallpaper
    openwebstart
  ];

  vscode = self: super: {
    inherit (import ./vscode.nix super) vscode vscode-insider;
  };

  vericert = self: super: {
    vericert = (import ./generated.nix super).vericert;
  };

  wallpaper = self: super: {
    inherit (import ./generated.nix super) pop-wallpaper nordic-wallpaper;
  };

  openwebstart = self: super: {
    openwebstart = super.callPackage ./openwebstart.nix { };
  };
}
