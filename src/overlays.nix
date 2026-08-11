{ lib, inputs }:
let
  generatedSources = final: prev: {
    _flakesGenerated = prev.callPackage ./generated.nix { };
  };

  vscodePackage = final: prev: {
    inherit (prev.callPackage ./vscode.nix { generated = final._flakesGenerated.vscode; })
      vscode
      vscode-insider
      ;
  };

  wallpaperPackage = final: prev: {
    inherit (final._flakesGenerated.main) pop-wallpaper nordic-wallpaper;
  };

  verusPackage =
    final: prev:
    let
      craneLib = inputs.crane.mkLib prev;
    in
    {
      verus = prev.callPackage ./verus.nix { generated = final._flakesGenerated.main; };
      verusfmt = prev.callPackage ./verusfmt.nix {
        inherit craneLib;
        generated = final._flakesGenerated.main;
      };
    };

  obscuraBrowserPackage = final: prev: {
    inherit
      (prev.callPackage ./obscura-browser.nix {
        generated = final._flakesGenerated.obscura;
      })
      obscura-browser-bin
      ;
  };

  clashxMetaPackage =
    final: prev:
    lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
      clashx-meta = prev.callPackage ./clashx-meta.nix {
        generated = final._flakesGenerated.main;
      };
    };

  ohMyPiPackage = final: prev: {
    oh-my-pi = prev.callPackage ./oh-my-pi.nix {
      generated = final._flakesGenerated.oh-my-pi;
    };
  };

  orcaPackage = final: prev: {
    orca = prev.callPackage ./orca.nix {
      generated = final._flakesGenerated.orca;
    };
  };

  withGenerated =
    overlay:
    lib.composeManyExtensions [
      generatedSources
      overlay
    ];
in
rec {
  default = lib.composeManyExtensions [
    generatedSources
    vscodePackage
    vericert
    wallpaperPackage
    openwebstart
    obscuraBrowserPackage
    clashxMetaPackage
    ohMyPiPackage
    orcaPackage
  ];

  vscode = withGenerated vscodePackage;

  vericert = final: prev: {
    vericert = (prev.callPackage ./generated.nix { }).main.vericert;
  };

  wallpaper = withGenerated wallpaperPackage;

  verus = withGenerated verusPackage;

  openwebstart = final: prev: {
    openwebstart = prev.callPackage ./openwebstart.nix { };
  };

  obscura-browser = withGenerated obscuraBrowserPackage;

  clashx-meta = withGenerated clashxMetaPackage;

  oh-my-pi = withGenerated ohMyPiPackage;

  orca = withGenerated orcaPackage;
}
