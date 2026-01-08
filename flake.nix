{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );
    in
    {
      packages = forAllSystems (
        { pkgs }:
        {
          llamaServerHook = pkgs.callPackage ./src/llama-server-hook.nix { };
          tests = pkgs.callPackage ./tests { };
        }
      );

      devShells = forAllSystems (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              bashInteractive
              nixfmt
              llama-cpp
            ];
          };
        }
      );

      formatter = forAllSystems ({ pkgs }: pkgs.nixfmt-tree);
    };
}
