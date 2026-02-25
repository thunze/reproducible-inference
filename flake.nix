{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
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
        rec {
          examples = import ./examples pkgs;
          tests = pkgs.callPackage ./tests {
            inherit examples;
          };
          writeLlamaWrapper = pkgs.callPackage ./src/write-llama-wrapper.nix { };
          liveSystemImage = self.nixosConfigurations.liveSystem.config.system.build.isoImage;
        }
      );

      nixosConfigurations.liveSystem = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (
            { modulesPath, ... }:
            {
              imports = [
                (modulesPath + "/installer/cd-dvd/installation-cd-graphical-gnome.nix")
              ];
              hardware.graphics.enable = true;

              # Use the proprietary NVIDIA kernel module because we need to
              # support GPU architectures older than Turing, which the open
              # kernel module doesn't support.
              hardware.nvidia.open = false;
              services.xserver.videoDrivers = [ "nvidia" ];

              # Faster squashfs compression, we don't care about file size
              isoImage.squashfsCompression = "gzip -Xcompression-level 1";
            }
          )
        ];
      };

      devShells = forAllSystems (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              bash
              nixfmt
              llama-cpp
            ];
          };
        }
      );

      formatter = forAllSystems ({ pkgs }: pkgs.nixfmt-tree);
    };
}
