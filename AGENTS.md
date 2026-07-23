# AGENTS.md

## Repository overview

This repository is a multi-platform Nix flake that packages several independent
tools and source-only wallpaper collections. The root flake uses `flake-parts`
and supports Linux and Darwin on x86_64 and aarch64.

## Layout

- `flake.nix` defines supported systems, package outputs, checks, and exported
  overlays.
- `src/*.nix` contains hand-written package and overlay definitions.
- `nvfetcher.toml` is the source of truth for dependencies maintained by
  nvfetcher.
- `_sources/generated.nix` and `_sources/generated.json` are generated files;
  do not edit them by hand.
- `src/generated.nix` is only a small adapter around the generated nvfetcher
  expression.
- `vericert/` is a nested flake with its own pinned `nixpkgs` and lock file.
- `.github/workflows/check.yml` runs the main flake check on all four supported
  platform families.
- `.github/workflows/nvfetcher.yml` performs scheduled dependency refreshes.

The `result` path is a local Nix build symlink and is ignored by Git. Do not
depend on or commit its contents.

## Making changes

- Keep package-specific logic in `src/<package>.nix`. Wire a new package into
  `packages` in `flake.nix` and add an overlay in `src/overlays.nix` when the
  package should also be consumable through overlays.
- Package attributes automatically become flake checks, except for explicit
  platform exclusions in `flake.nix`. A new package must therefore evaluate and
  build as a check on every platform where it is exposed.
- Use Nix platform predicates such as `stdenv.hostPlatform.isLinux`, `isDarwin`,
  and `isAarch` when dependencies or artifacts vary by target. If an upstream
  artifact does not exist for a system, omit the package for that system rather
  than leaving a guaranteed failing derivation.
- Preserve the existing Nix style: two-space indentation, argument sets at the
  top of package files, `let` bindings for derived values, and trailing
  semicolons. Keep diffs focused; do not reformat generated files.
- When changing a fixed-output source manually, update its version/revision and
  hash together. Prefer SRI hashes (`sha256-...`).
- Treat `vericert/flake.lock` independently from the root `flake.lock`. Update
  only the lock file associated with the flake whose inputs changed.

## Updating generated sources

Always use nvfetcher for package sources when it can represent the upstream.
Add or update the source in `nvfetcher.toml` and consume it through
`src/generated.nix`; use a hand-written fixed-output fetcher only when nvfetcher
cannot support the source.

After editing `nvfetcher.toml`, regenerate both files under `_sources/` with:

```sh
nix-shell -p nvfetcher --command "nvfetcher -v --keep-going"
```

Review the generated diff and commit the configuration and generated outputs
together. Entries consumed through `generated` must retain names that match the
lookups in the relevant package definition (for example the platform-specific
VS Code and Verus entries).

## Validation

Run the narrowest relevant checks first, followed by the full flake evaluation
when practical:

```sh
# Evaluate all checks without building them.
NIXPKGS_ALLOW_UNFREE=1 nix flake check --impure --no-build

# Build one changed package on the current system.
NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#<package>

# Match the main CI check (can be expensive).
NIXPKGS_ALLOW_UNFREE=1 nix flake check --impure
```

VS Code is unfree, so keep `NIXPKGS_ALLOW_UNFREE=1` and `--impure` when
evaluating the complete package set. For platform-specific changes, local
success covers only the current system; inspect conditionals for every supported
system and rely on the CI matrix for native cross-platform builds.

After a dependency refresh, build each affected package rather than assuming
successful source generation proves that its archive layout or build interface
is unchanged.
