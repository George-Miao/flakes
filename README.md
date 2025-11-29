# George Miao's Nix Flakes

A collection of Nix flakes for various projects and tools.

## Systems Supported

- x86_64-linux
- aarch64-linux
- x86_64-darwin
- aarch64-darwin

## Usage

In your `flake.nix`, you can import packages from this flake as follows:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    flakes.url = "github:George-Miao/flakes";
    flakes.inputs.nixpkgs.follows = "nixpkgs";
    # ... other inputs ...
  };

  outputs = { self, nixpkgs, flakes, ... }:
    let
      system = "x86_64-linux"; # or your system
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          flakes.packages.${system}.vericert
          # ... other packages ...
        ];
      };
    };
}
```

## Overlays

All packages exposed in this flake can be also accessed via overlays. The easiest way is to use `.#overlay.default` and all packages will be available in your nixpkgs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flakes.url = "github:George-Miao/flakes";
  };

  outputs = { self, nixpkgs, flakes, ... }: {
    nixosConfigurations.myHost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nixpkgs.overlays = [ flakes.overlays.default ];
        }
        # Now you can use flakes packages in your configuration
      ];
    };
  };
}
```

You can also use specific overlays for individual packages:

- `.#overlays.default`: includes all packages
- `.#overlays.vscode`: includes `vscode` and `vscode-insider`
- `.#overlays.vericert`: includes `vericert`
- `.#overlays.wallpaper`: includes `pops-wallpaper` and `nordic-wallpaper`

## Packages

### Vericert

Output: `.#packages.${system}.vericert`

A formally verified high-level synthesis (HLS) tool that compiles C to Verilog with Coq proofs of correctness.

> [!NOTE]
> Vericert is old and requires a specific environment to be built correctly, therefore it pulls in its own nixpkgs. Redirect top-level flake's input will not change the nixpkgs used to build vericert.

### VS Code

Output: `.#packages.${system}.vscode`

Latest stable version of Visual Studio Code, automatically fetched and packaged for Nix. The package is built with the latest stable release from Microsoft's official distribution.

### VS Code Insider

Output: `.#packages.${system}.vscode-insider`

Latest insider/preview version of Visual Studio Code with experimental features and early access to new functionality. Includes additional build dependencies to build from the insider release.

### Pop Wallpaper

Output: `.#packages.pop-wallpaper` and `.#packages.${system}.pop-wallpaper`

A collection of wallpapers from George Miao's personal [wallpaper repository](https://github.com/George-Miao/wallpaper).

### Nordic Wallpaper

Output: `.#packages.nordic-wallpaper` and `.#packages.${system}.nordic-wallpaper`

A collection of Nordic-themed wallpapers from the [nordic-wallpapers](https://github.com/linuxdotexe/nordic-wallpapers) repository.
