import os
import subprocess
from pathlib import Path


def test():
    """Test function executed by pytest.

    This function runs an example binary, captures its stdout and stderr, and
    asserts that its stdout matches the expected output for the example. The stdout
    and stderr are also written to log files in the test output directory for later
    inspection.
    """
    print(f"Begin test: {__file__}")

    test_output_dir = Path(os.environ["REPRODUCIBLE_INFERENCE_TEST_OUTPUT_DIR"])
    stdout_logfile = test_output_dir / "@example_stdout_logfile@"
    stderr_logfile = test_output_dir / "@example_stderr_logfile@"

    expected_output = Path("@expected_output_file@").read_bytes()

    print("  Running example binary...")

    result = subprocess.run(
        ["@example_binary@"],
        env={},  # Don't inherit any environment variables
        capture_output=True,
    )

    print(f"  Finished running example binary with exit code {result.returncode}")

    stdout_logfile.write_bytes(result.stdout or b"")
    print(f"  Wrote example stdout to: {stdout_logfile}")

    stderr_logfile.write_bytes(result.stderr or b"")
    print(f"  Wrote example stderr to: {stderr_logfile}")

    assert result.returncode == 0
    assert result.stdout == expected_output
