lib: rec {
  default = lib.composeManyExtensions [
    vscode
    vericert
    wallpaper
    openwebstart
  ];

  vscode = final: prev: {
    inherit (prev.callPackage ./vscode.nix { generated = (prev.callPackage ./generated.nix { }); })
      vscode
      vscode-insider
      ;
  };

  vericert = final: prev: {
    vericert = (prev.callPackage ./generated.nix { }).vericert;
  };

  wallpaper = final: prev: {
    inherit (prev.callPackage ./generated.nix { }) pop-wallpaper nordic-wallpaper;
  };

  verus = final: prev: {
    verus = (prev.callPackage ./verus.nix { generated = (prev.callPackage ./generated.nix { }); });
  };

  openwebstart = final: prev: {
    openwebstart = import ./openwebstart.nix prev;
  };
}
