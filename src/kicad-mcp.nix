{
  lib,
  buildNpmPackage,
  importNpmLock,
  makeWrapper,
  nodejs,
  python3,
  kicad,
  generated,
}:
let
  source = generated.kicad-mcp;
  kicadSkip = python3.pkgs.buildPythonPackage {
    pname = "kicad-skip";
    inherit (generated.kicad-skip) src version;
    pyproject = true;
    build-system = [ python3.pkgs.setuptools ];
    dependencies = [ python3.pkgs.sexpdata ];
    pythonImportsCheck = [ "skip" ];
  };
  python = python3.withPackages (ps: [
    kicadSkip
    ps.kicad-python
    ps.sexpdata
    ps.pillow
    ps.pymupdf
    ps.cairosvg
    ps.colorlog
    ps.pydantic
    ps.requests
    ps.python-dotenv
    ps.wxpython_4_3
  ]);
in
buildNpmPackage {
  pname = "kicad-mcp";
  version = lib.removePrefix "v" source.version;
  inherit (source) src;

  npmDeps = importNpmLock { npmRoot = source.src; };
  npmConfigHook = importNpmLock.npmConfigHook;
  npmFlags = [ "--ignore-scripts" ];
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    npm prune --omit=dev --ignore-scripts
    mkdir -p $out/lib/kicad-mcp $out/bin
    cp -r dist node_modules python config resources gui_driver_plugin package.json $out/lib/kicad-mcp/
    makeWrapper ${nodejs}/bin/node $out/bin/kicad-mcp \
      --add-flags "$out/lib/kicad-mcp/dist/index.js" \
      --set KICAD_PYTHON ${python}/bin/python3 \
      --prefix PYTHONPATH : "${python}/${python3.sitePackages}:${kicad.base}/${python3.sitePackages}" \
      --prefix PATH : ${lib.makeBinPath [ kicad ]} \
      ${lib.concatStringsSep " " kicad.makeWrapperArgs}
    runHook postInstall
  '';

  meta = {
    description = "MCP server for KiCad board and schematic design";
    homepage = "https://github.com/mixelpixx/KiCAD-MCP-Server";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "kicad-mcp";
  };
}
