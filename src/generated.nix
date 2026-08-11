{ callPackage }:
{
  main = callPackage ../generated/main/generated.nix { };
  obscura = callPackage ../generated/obscura/generated.nix { };
  oh-my-pi = callPackage ../generated/oh-my-pi/generated.nix { };
  orca = callPackage ../generated/orca/generated.nix { };
  vscode = callPackage ../generated/vscode/generated.nix { };
}
