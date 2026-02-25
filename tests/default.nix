{
  lib,
  callPackage,

  # List of examples in the format exported by `../examples/default.nix`, e.g.:
  #
  # {
  #   cpu.gemma-3-270m.conversation-basic = <derivation of wrapped example script>;
  #   cpu.gemma-3-270m.conversation-long = <derivation of wrapped example script>;
  #   ...
  # }
  examples,
}:

let
  # Generate test cases in the expected format for all examples in `examples`.
  # See `./runner.nix` for the expected format of each test case.
  # We stop recursing through `examples` when we encounter a derivation, which
  # should be the wrapped example script for a test case.
  testCases = lib.mapAttrsToListRecursiveCond (path: attrset: !(lib.isDerivation attrset)) (
    path: exampleDerivation: {
      name = lib.concatStringsSep "_" path;
      inherit exampleDerivation;
      expectedOutputFile = ./expected/test_${lib.concatStringsSep "_" path}_stdout.log;
    }) examples;
in
callPackage ./runner.nix {
  inherit testCases;
}
