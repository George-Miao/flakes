# George Miao's Nix Flakes

A collection of Nix flakes for various projects and tools.

## Systems Supported

See [./common.nix](./common.nix) for details. Supported systems include:

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
