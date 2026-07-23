{ lib, inputs }:
rec {
  default = lib.composeManyExtensions [
    vscode
    vericert
    wallpaper
    openwebstart
    obscura-browser
    clashx-meta
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

  verus =
    final: prev:
    let
      generated = (prev.callPackage ./generated.nix { });
      craneLib = inputs.crane.mkLib prev;
    in
    {
      verus = prev.callPackage ./verus.nix { inherit generated; };
      verusfmt = prev.callPackage ./verusfmt.nix { inherit generated craneLib; };
    };

  openwebstart = final: prev: {
    openwebstart = prev.callPackage ./openwebstart.nix { };
  };

  obscura-browser = final: prev: {
    inherit
      (prev.callPackage ./obscura-browser.nix {
        generated = prev.callPackage ./generated.nix { };
      })
      obscura-browser-bin
      ;
  };

  clashx-meta =
    final: prev:
    lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
      clashx-meta = prev.callPackage ./clashx-meta.nix {
        generated = prev.callPackage ./generated.nix { };
      };
    };
}
