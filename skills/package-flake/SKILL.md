---
name: package-flake
description: Package an upstream application or CLI in this repository's Nix flake, especially from released binary artifacts. Use when adding a new package URL, creating a binary package, wiring package outputs and overlays, or updating package documentation in this flake.
---

# Package Flake

Follow `AGENTS.md` and preserve unrelated work. Prefer released upstream
binaries unless the user explicitly requests a source build.

## Workflow

1. Inspect upstream releases. Identify artifact layouts and supported systems.
   Omit systems without a compatible released binary.
2. Choose the nvfetcher unit:
   - Put a package with exactly one source entry in `nvfetcher/main.toml` and
     consume it through the `main` attribute from `src/generated.nix`.
   - Give a package with multiple source entries, such as platform or
     architecture variants, its own `nvfetcher/<unit>.toml` and
     `generated/<unit>/` output directory.
   Add every new unit to the dictionary in `src/generated.nix`; do not create
   per-unit adapter files.
   Never edit generated files by hand.
3. Regenerate only the selected unit:

   ```sh
   nix-shell -p nvfetcher --command \
     "nvfetcher -v --keep-going -c nvfetcher/<unit>.toml -o generated/<unit>"
   ```

   Keep `scripts/update-nvfetcher.sh` as the all-unit entry point used by CI.
   Adding a unit must not require a package-specific CI command.
4. Add `src/<package>.nix`. Consume versions and fixed-output sources only
   through the generated dictionary. Map artifacts by
   `stdenv.hostPlatform.system`, preserve signed bundles, and set accurate
   metadata including platforms and binary source provenance.
5. Add a package-specific overlay in `src/overlays.nix`, include it in the
   default overlay, and export the package from `flake.nix`. Gate unavailable
   systems with `lib.optionalAttrs` instead of exposing failing derivations.
6. Update `README.md` with the output, purpose, supported systems, and important
   installation or runtime details.
7. Format changed hand-written Nix files and run `git diff --check`.
8. Build only the target package:

   ```sh
   NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#<package>
   ```

   Read-only evaluation for other supported systems is allowed. Do not build
   other packages and do not run the full flake check.

## Completion criteria

Finish only when generated sources match their config, the target package
builds, its overlay and flake output evaluate, README documentation is present,
and the diff contains no unrelated generated-source churn.
