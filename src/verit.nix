{ generated, verit }:
verit.overrideAttrs (old: {
  inherit (generated.verit) src version;
  meta = old.meta // {
    homepage = "https://www.verit-solver.org/";
    broken = false;
  };
})
