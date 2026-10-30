{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    crane.url = "github:ipetkov/crane";
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
      crane,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];

        flake = {
          overlays = import ./src/overlays.nix {
            inherit (nixpkgs) lib;
            inherit inputs;
          };
        };

        perSystem =
          {
            pkgs,
            lib,
            system,
            ...
          }:
          let
            craneLib = crane.mkLib pkgs;
            skipCheck = p: (system == "aarch64-linux" && p == "verus");
          in
          rec {
            checks = lib.filterAttrs (p: _: !(skipCheck p)) packages;
            packages =
              let
                openwebstart = pkgs.callPackage ./src/openwebstart.nix { };
                generated = pkgs.callPackage ./src/generated.nix { };
                vscode = pkgs.callPackage ./src/vscode.nix { generated = generated.vscode; };
                verus = pkgs.callPackage ./src/verus.nix { generated = generated.main; };
                verit = pkgs.callPackage ./src/verit.nix { generated = generated.main; };
                verusfmt = pkgs.callPackage ./src/verusfmt.nix {
                  inherit craneLib;
                  generated = generated.main;
                };
                obscura-browser = pkgs.callPackage ./src/obscura-browser.nix {
                  generated = generated.obscura;
                };
                oh-my-pi = pkgs.callPackage ./src/oh-my-pi.nix {
                  generated = generated.oh-my-pi;
                };
                ns3 = pkgs.callPackage ./src/ns3.nix { };
                clashx-meta = pkgs.callPackage ./src/clashx-meta.nix { generated = generated.main; };
                orca = pkgs.callPackage ./src/orca.nix { generated = generated.orca; };
                computer-use-linux = pkgs.callPackage ./src/computer-use-linux.nix {
                  generated = generated.computer-use-linux;
                };
                breezex-cursor = pkgs.callPackage ./src/breezex-cursor.nix {
                  generated = generated.breezex-cursor;
                };
                bluetooth-manager-sidebar = pkgs.callPackage ./src/bluetooth-manager-sidebar.nix {
                  generated = generated.main;
                };
                xcharter = pkgs.callPackage ./src/xcharter.nix {
                  generated = generated.main;
                };
              in
              {
                inherit (vscode) vscode vscode-insider;
                inherit (obscura-browser) obscura-browser-bin;
                inherit
                  openwebstart
                  verusfmt
                  verit
                  oh-my-pi
                  ns3
                  orca
                  xcharter
                  ;
                vericert = vericert.packages.${system}.vericert;
                pop-wallpaper = generated.main.pop-wallpaper.src;
                nordic-wallpaper = generated.main.nordic-wallpaper.src;
              }
              // (lib.optionalAttrs (system != "aarch64-linux") { inherit verus; })
              // (lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
                inherit computer-use-linux breezex-cursor;
              })
              // (lib.optionalAttrs (system == "x86_64-linux") { inherit bluetooth-manager-sidebar; })
              // (lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin { inherit clashx-meta; });
          };
      }
    );
}
