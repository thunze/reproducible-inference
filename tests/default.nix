{
  lib,
  callPackage,

  # List of all examples in the format exported by `../examples/default.nix`, i.e.:
  #
  # {
  #   cpu.gemma-3-270m.conversation = <derivation of wrapped example script>;
  #   cpu.gemma-3-270m.hello-curl = <derivation of wrapped example script>;
  #   ...
  # }
  examples,
  ...
}:

let
  # Generate test cases in the expected format for all available examples
  # with acceleration type `acceleration`.
  # See `./runner.nix` for the expected format of each test case.
  # We stop recursing through `examples` when we encounter a derivation, which
  # should be the wrapped example script for a test case.
  generateTestCases =
    acceleration:
    lib.mapAttrsToListRecursiveCond (path: attrset: !(lib.isDerivation attrset)) (
      path: exampleDerivation: rec {
        name = "${acceleration}_${lib.concatStringsSep "_" path}";
        inherit exampleDerivation;
        expectedOutputFile = ./expected/test_${name}_stdout.log;
      }) examples.${acceleration};

  # Create a test runner for a list of test cases
  createTestRunner = testCases: callPackage ./runner.nix { inherit testCases; };

  # Map acceleration types to their corresponding test cases
  testCasesByAcceleration = lib.genAttrs (lib.attrNames examples) generateTestCases;
in
# The resulting attribute set looks like this:
#
# {
#   cpu = <derivation of test runner for all `cpu` test cases>;
#   cuda = <derivation of test runner for all `cuda` test cases>;
#   ...
#   all = <derivation of test runner for all test cases>;
# }
(lib.mapAttrs (acceleration: createTestRunner) (
  testCasesByAcceleration
  // {
    all = lib.concatAttrValues testCasesByAcceleration;
  }
))
