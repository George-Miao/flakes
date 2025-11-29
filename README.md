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

Output: `.#packages.${system}.pop-wallpaper`

A collection of wallpapers from George Miao's personal [wallpaper repository](https://github.com/George-Miao/wallpaper).

### Nordic Wallpaper

Output: `.#packages.${system}.nordic-wallpaper`

A collection of Nordic-themed wallpapers from the [nordic-wallpapers](https://github.com/linuxdotexe/nordic-wallpapers) repository.
