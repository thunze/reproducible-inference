{
  lib,
  coreutils,
  fastfetch,
  gnutar,
  python3,
  replaceVarsWith,
  symlinkJoin,
  writeShellApplication,

  # List of test cases for which to generate test files. Each test case is an
  # attribute set with the following attributes:
  #
  # {
  #   name = "<name for the test case>";
  #   exampleDerivation = <derivation of the wrapped example script>;
  #   expectedOutputFile = <path to file containing the expected output of the example script>;
  # }
  testCases,
}:

let
  # Generate a pytest test file from the test template by replacing variables
  # with the appropriate values for a given test case.
  # `name` is the name of the test case, `exampleDerivation` is the derivation
  # of the wrapped example script, and `expectedOutputFile` is the path to the
  # file containing the data expected to be written to stdout by the example
  # script.
  generateTestFile =
    {
      name,
      exampleDerivation,
      expectedOutputFile,
    }:
    replaceVarsWith {
      src = ./test_template.py;
      replacements = {
        example_binary = lib.getExe exampleDerivation;
        expected_output_file = expectedOutputFile;
        example_stdout_logfile = "test_${name}_stdout.log";
        example_stderr_logfile = "test_${name}_stderr.log";
      };
      name = "test_${name}.py";
      dir = "/"; # Add to root of Nix store path
    };

  # Link all generated test files into a single directory that can be
  # passed to pytest.
  testDir = symlinkJoin {
    name = "reproducible-inference-tests";
    paths = builtins.map generateTestFile testCases;
  };
in
# Test runner derivation. Running the resulting binary will execute all
# tests and log the results, as well as machine information, to a temporary
# output directory.
writeShellApplication {
  name = "reproducible-inference-test-runner";

  runtimeInputs = [
    coreutils
    fastfetch
    gnutar
    (python3.withPackages (ps: with ps; [ pytest ]))
  ];

  # Using `>&2` to redirect all output except the final tarball path to
  # stderr so that stdout can be easily parsed by consumers to retrieve
  # the tarball path.
  text = ''
    REPRODUCIBLE_INFERENCE_TEST_OUTPUT_DIR=$(mktemp -d)
    export REPRODUCIBLE_INFERENCE_TEST_OUTPUT_DIR
    out=$REPRODUCIBLE_INFERENCE_TEST_OUTPUT_DIR
    tarball="$out/reproducible_inference_test_$(date "+%Y-%m-%d_%H-%M-%S").tar.gz"

    # Log machine information for debugging purposes
    fastfetch --logo none --pipe > "$out/fastfetch.log"
    fastfetch --json > "$out/fastfetch.json"

    # Run pytest with the test directory as an argument, and tee stdout and
    # stderr to `pytest.log` in the output directory. Also disable pytest's
    # cache provider plugin to avoid warnings due to the test directory being
    # read-only (Nix store path).
    pytest ${testDir} -p no:cacheprovider -svv 2>&1 | tee "$out/pytest.log" >&2
    pytestExitCode=''${PIPESTATUS[0]}

    # Create a tarball from the output directory for easy retrieval after the test run
    >&2 touch "$tarball"
    >&2 tar --exclude "$(basename "$tarball")" -czvf "$tarball" -C "$out" .
    >&2 echo "Test output tarball created at: $tarball"
    echo "$tarball"

    exit "$pytestExitCode"
  '';
}
