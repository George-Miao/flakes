{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/1c8257a313a5eb4d5f86edc2d325a23ff8085b94";
  };

  outputs = {nixpkgs, ...}: {
    packages = (import ../common.nix).each nixpkgs (
      pkgs: let
        src = pkgs.fetchFromGitHub {
          owner = "ymherklotz";
          repo = "vericert";
          rev = "bb3556c2d3c852604b22491d7f99c570c19eab24";
          hash = "sha256-mKB9F/rMQpi+yI1AKcRdY6GUsC2nomMBSz0KC70Tkc0=";
          fetchSubmodules = true;
        };
        veriT = pkgs.veriT.overrideAttrs (oA: {
          src = pkgs.fetchurl {
            url = "https://www.lri.fr/~keller/Documents-recherche/Smtcoq/veriT9f48a98.tar.gz";
            sha256 = "sha256-Pe46PxQVHWwWwx5Ei4Bl95A0otCiXZuUZ2nXuZPYnhY=";
          };
          meta.broken = false;
        });
        arch =
          if pkgs.stdenv.hostPlatform.isx86_64
          then "x86"
          else "aarch64";
        coq = pkgs.coq_8_17;
        inputPkgs = with pkgs; [emacs dune_3 gcc python3 lp_solve veriT zchaff];
        ocamlPkgs = with coq.ocamlPackages; [findlib menhir menhirLib ocamlgraph ocp-indent utop merlin];
        pythonPkgs = with pkgs.python3Packages; [alectryon sphinx_rtd_theme];
        coqPackages = pkgs.coqPackages_8_17;
        buildInputs = [coq coq.ocaml coqPackages.serapi] ++ inputPkgs ++ ocamlPkgs ++ pythonPkgs;
      in rec {
        default = vericert;
        vericert = pkgs.stdenv.mkDerivation {
          inherit src buildInputs;
          name = "vericert";
          buildPhase = ''
            runHook preBuild
            make -j8
            runHook postBuild
          '';
          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            sed -i -e 's/arch=verilog/arch=${arch}/' _build/default/driver/compcert.ini
            cp _build/default/driver/VericertDriver.exe $out/bin/vericert
            cp _build/default/driver/compcert.ini $out/bin
            runHook postInstall
          '';
        };
      }
    );
  };
}
