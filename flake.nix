{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      # We only test on `x86_64-linux`, but with `supportedSystems`
      # we allow building the packages on other platforms as well,
      # in case anyone wants to try that.
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
      # Packages exported by this flake.
      # Can be built using `nix build .#<package>`.
      # Can be run using `nix run .#<package>`.
      packages = forAllSystems (
        { pkgs }:
        rec {
          examples = import ./examples pkgs;
          tests = import ./tests (pkgs // { inherit examples; });
          writeLlamaWrapper = pkgs.callPackage ./src/write-llama-wrapper.nix { };
          liveSystemImage = self.nixosConfigurations.liveSystem.config.system.build.isoImage;
        }
      );

      # NixOS configuration for a live system image with graphics drivers
      # and all test runners pre-installed. This is used for testing on
      # machines that don't have Nix installed.
      nixosConfigurations.liveSystem = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (
            {
              lib,
              config,
              modulesPath,
              ...
            }:
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

              # Add shell aliases for all test runner binaries. We cannot just
              # install them via `environment.systemPackages` because all
              # test runner binaries have the same name and would therefore
              # conflict with each other.
              # The resulting aliases look like `ri-tests-<runner>`, e.g.,
              # `ri-tests-all` or `ri-tests-cpu`.
              environment.shellAliases = lib.mapAttrs' (
                key: runner: lib.nameValuePair "ri-tests-${key}" runner
              ) self.packages.${config.nixpkgs.hostPlatform}.tests;

              # Faster squashfs compression, we don't care about file size
              isoImage.squashfsCompression = "gzip -Xcompression-level 1";
            }
          )
        ];
      };

      # Development shell, used only for development.
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
