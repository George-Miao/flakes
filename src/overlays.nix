lib: rec {
  default = lib.composeManyExtensions [
    vscode
    vericert
    wallpaper
    openwebstart
  ];

  vscode = self: super: {
    inherit (super.callPackage ./vscode.nix { }) vscode vscode-insider;
  };

  vericert = self: super: {
    vericert = (super.callPackage ./generated.nix { }).vericert;
  };

  wallpaper = self: super: {
    inherit (super.callPackage ./generated.nix { }) pop-wallpaper nordic-wallpaper;
  };

  verus = self: super: {
    verus = (super.callPackage ./verus.nix (super.callPackage ./generated.nix { }));
  };

  openwebstart = self: super: {
    openwebstart = import ./openwebstart.nix super;
  };
}
