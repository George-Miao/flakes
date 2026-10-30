# George Miao's Nix Flakes

A collection of Nix flakes for various projects and tools.

- [Vericert](#vericert)
- [Verus](#verus)
- [Verusfmt](#verusfmt)
- [OpenWebStart](#openwebstart)
- [ns-3](#ns-3)
- [ClashX Meta](#clashx-meta)
- [Obscura Browser](#obscura-browser)
- [Oh My Pi](#oh-my-pi)
- [Computer Use Linux](#computer-use-linux)
- [BreezeX Cursor](#breezex-cursor)
- [Bluetooth Manager Sidebar](#bluetooth-manager-sidebar)
- [XCharter](#xcharter)
- [Orca](#orca)
- [VS Code](#vs-code)
- [VS Code Insider](#vs-code-insider)
- [Pop Wallpaper](#pop-wallpaper)
- [Nordic Wallpaper](#nordic-wallpaper)

## Systems Supported

By default, packages support the following systems unless their package section
states an exception.

- x86_64-linux
- aarch64-linux
- x86_64-darwin
- aarch64-darwin

The current nixpkgs input does not support `x86_64-darwin`.

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

The default overlay makes a selection of packages available in nixpkgs.
Use `flakes.overlays.default` to enable it. The `verus` overlay provides
`verus` and `verusfmt` separately. `ns3` is available only as a flake package.

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

- `.#overlays.default`: combines the overlays below, except `verus`
- `.#overlays.vscode`: includes `vscode` and `vscode-insider`
- `.#overlays.vericert`: includes `vericert`
- `.#overlays.verus`: includes `verus` and `verusfmt`
- `.#overlays.openwebstart`: includes `openwebstart`
- `.#overlays.clashx-meta`: includes `clashx-meta` on macOS
- `.#overlays.obscura-browser`: includes `obscura-browser-bin`
- `.#overlays.oh-my-pi`: includes `oh-my-pi`
- `.#overlays.orca`: includes `orca`
- `.#overlays.computer-use-linux`: includes `computer-use-linux` on Linux
- `.#overlays.breezex-cursor`: includes `breezex-cursor` on Linux
- `.#overlays.bluetooth-manager-sidebar`: includes `bluetooth-manager-sidebar` on `x86_64-linux`
- `.#overlays.xcharter`: includes `xcharter`
- `.#overlays.wallpaper`: includes `pop-wallpaper` and `nordic-wallpaper`

## Packages

### [Vericert](https://github.com/ymherklotz/vericert)

Output: `.#packages.${system}.vericert`

A formally verified high-level synthesis (HLS) tool that compiles C to Verilog with Coq proofs of correctness.

> [!NOTE]
> Vericert is old and requires a specific environment to be built correctly, therefore it pulls in its own nixpkgs. Redirect top-level flake's input will not change the nixpkgs used to build vericert.

### [Verus](https://github.com/verus-lang/verus)

Output: `.#packages.${system}.verus`

Supported systems: `x86_64-linux`, `x86_64-darwin`, and `aarch64-darwin`.

A verifier for Rust programs focused on proving correctness properties (such as safety and functional correctness) through specifications and proofs.

> [!NOTE]
> Verus may require a pinned Rust toolchain and solver dependencies (such as Z3) to work correctly. If you use it in a development shell, make sure your shell provides the required toolchain components.
> Upstream does not provide Verus binaries for `aarch64-linux`.

### [Verusfmt](https://github.com/verus-lang/verusfmt)

Output: `.#packages.${system}.verusfmt`

A source code formatter for Verus.

### [OpenWebStart](https://github.com/karakun/OpenWebStart)

Output: `.#packages.${system}.openwebstart`

A launcher for Java applications that use JNLP files. The package includes
the `openwebstart` launcher and the `openwebstart-settings` control panel,
with OpenJDK 8.

### [ns-3](https://www.nsnam.org/)

Output: `.#packages.${system}.ns3`

A discrete-event network simulator, built from the ns-3 source release.

### [ClashX Meta](https://github.com/MetaCubeX/ClashX.Meta)

Output: `.#packages.${system}.clashx-meta`

Supported systems: `x86_64-darwin` and `aarch64-darwin` only.

A rule-based proxy client for macOS, powered by Mihomo. The package installs
`ClashX Meta.app`.

### [Obscura Browser](https://github.com/h4ckf0r0day/obscura)

Output: `.#packages.${system}.obscura-browser-bin`

A lightweight headless browser for AI agents and web scraping. The
package installs the corresponding native artifact from the upstream GitHub
release and includes both the `obscura` and `obscura-worker` executables.

### [Oh My Pi](https://github.com/can1357/oh-my-pi)

Output: `.#packages.${system}.oh-my-pi`

An AI coding agent for the terminal. The package installs the `omp` executable
from the corresponding upstream release artifact.

### [Computer Use Linux](https://github.com/agent-sh/computer-use-linux)

Output: `.#packages.${system}.computer-use-linux`

Supported systems: `x86_64-linux` and `aarch64-linux` only.

Linux desktop control through MCP and CLI. By default, the package includes
the main executable, the COSMIC helper, the activity indicator, `wtype`, and
the X11 tools `xdotool`, `wmctrl`, and `xprop`.

Use `.override` on the flake package or the overlay package to select a desktop:

```nix
pkgs.computer-use-linux.override {
  desktop = "wayland";
  x11Support = false;
}
```

`desktop` defaults to `"all"`. It selects package dependencies and helpers
at build time.

| `desktop`   | Helpers in addition to the main executable | Desktop dependencies                      |
| ----------- | ------------------------------------------ | ----------------------------------------- |
| `"all"`     | COSMIC helper and activity indicator       | `wtype`, `libxkbcommon`                   |
| `"wayland"` | Activity indicator                         | `wtype`                                   |
| `"gnome"`   | Activity indicator                         | `libxkbcommon` for the GNOME keymap check |
| `"kde"`     | Activity indicator                         | No additional desktop dependencies        |
| `"cosmic"`  | COSMIC helper and activity indicator       | No additional desktop dependencies        |
| `"x11"`     | None                                       | X11 tools                                 |

`x11Support` defaults to `true`. It adds `xdotool`, `wmctrl`, and `xprop` to
each preset, including Wayland presets that need X11 tools. Set it to `false`
to omit those tools. The `"x11"` preset requires `x11Support = true`.
Other tools on the session's `PATH` remain available to the program.

The optional [ydotool](https://github.com/ReimuNotMoe/ydotool) fallback requires a separate ydotoold service.

### [BreezeX Cursor](https://github.com/ful1e5/BreezeX_Cursor)

Output: `.#packages.${system}.breezex-cursor`

Supported systems: `x86_64-linux` and `aarch64-linux` only.

Extended Breeze cursor themes with HiDPI support. The package installs
`BreezeX-Black`, `BreezeX-Dark`, and `BreezeX-Light` under `share/icons`.
Select one of these theme names in your desktop settings.

For Home Manager:

```nix
home.pointerCursor = {
  package = flakes.packages.${pkgs.stdenv.hostPlatform.system}.breezex-cursor;
  name = "BreezeX-Dark";
  size = 24;
  gtk.enable = true;
};
```

### [Bluetooth Manager Sidebar](https://github.com/Relz/bluetooth-manager-sidebar)

Output: `.#packages.${system}.bluetooth-manager-sidebar`

Supported systems: `x86_64-linux` only.

A Bluetooth sidebar for layer-shell Wayland desktops, with BlueZ required
and OBEX required for file transfer.

Command: `bm-sidebar`

Included tools: `pactl`, `rfkill`.

### [XCharter](https://ctan.org/pkg/xcharter)

Output: `.#packages.${system}.xcharter`

Bitstream Charter fonts with small capitals, oldstyle figures, and superior figures.

On NixOS:

```nix
fonts.packages = [ pkgs.xcharter ];
```

### [Orca](https://github.com/stablyai/orca)

Output: `.#packages.${system}.orca`

An agent development environment for orchestrating coding agents. The package
uses Orca's released AppImages on Linux and signed application bundles on macOS,
with native artifacts for x86_64 and aarch64.

### [VS Code](https://code.visualstudio.com/)

Output: `.#packages.${system}.vscode`

Latest stable version of Visual Studio Code, automatically fetched and packaged for Nix. The package is built with the latest stable release from Microsoft's official distribution.

### [VS Code Insider](https://code.visualstudio.com/insiders/)

Output: `.#packages.${system}.vscode-insider`

Latest insider/preview version of Visual Studio Code with experimental features and early access to new functionality. Includes additional build dependencies to build from the insider release.

### [Pop Wallpaper](https://github.com/George-Miao/wallpaper)

Output: `.#packages.${system}.pop-wallpaper`

A collection of wallpapers from George Miao's personal [wallpaper repository](https://github.com/George-Miao/wallpaper).

### [Nordic Wallpaper](https://github.com/linuxdotexe/nordic-wallpapers)

Output: `.#packages.${system}.nordic-wallpaper`

A collection of Nordic-themed wallpapers from the [nordic-wallpapers](https://github.com/linuxdotexe/nordic-wallpapers) repository.
