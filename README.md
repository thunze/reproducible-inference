# Reproducible Inference

`reproducible-inference` is a project that aims to evaluate the reproducibility of LLM inference output across different hardware configurations. The project includes a set of exemplary LLM inference tasks, along with scripts to run these tasks on various hardware setups and compare the outputs against reference outputs for reproducibility checking.

Executing the inference tasks and reproducibility tests requires [Nix](https://github.com/NixOS/nix) with [Nix flakes](https://wiki.nixos.org/wiki/Flakes#Setup) enabled.

## Running individual inference tasks

For each LLM inference task, a llama.cpp server is set up to run the inference and shut down after the inference is complete. The inference task output is written to stdout, while all other logs, including llama.cpp logs, are written to stderr. This allows for easy capturing of the inference output for reproducibility checking.

To run a single inference task for a single model and using CPU inference:

```bash
nix run .#examples.cpu.<model>.<task>
```

To run a single inference task for a single model and using CUDA GPU inference:

```bash
NIXPKGS_ALLOW_UNFREE=1 nix run --impure .#examples.cuda.<model>.<task>
```

> [!NOTE]
> The `NIXPKGS_ALLOW_UNFREE=1` environment variable is required for CUDA GPU inference because the NVIDIA CUDA toolkit is classified as unfree software in Nixpkgs. `--impure` is required for the Nix CLI to allow reading the `NIXPKGS_ALLOW_UNFREE` environment variable.

## Running reproducibility tests

Reproducibility tests compare the inference output for all model–task combinations against reference outputs (see `tests/expected/`) to check for reproducibility. The tests are organized by acceleration mode, with separate test suites for CPU inference and CUDA GPU inference. Running the tests will also write the captured stdout and stderr logs, as well as the test runner logs and some information captured about the hardware using [fastfetch](https://github.com/fastfetch-cli/fastfetch), to a temporary directory, whose path will be printed after the test run. This allows for inspection of the logs and hardware information in case of test failures.

To run reproducibility tests for CPU inference:

```bash
nix run .#tests.cpu
```

To run reproducibility tests for CUDA GPU inference:

```bash
NIXPKGS_ALLOW_UNFREE=1 nix run --impure .#tests.cuda
```

To run reproducibility tests, regardless of the acceleration mode:

```bash
NIXPKGS_ALLOW_UNFREE=1 nix run --impure .#tests.all
```

> [!NOTE]
> CUDA GPU inference is currently not expected to be reproducible across different NVIDIA GPUs. The reference outputs were generated using an NVIDIA GTX 960 (4 GB) graphics card.

> [!NOTE]
> The `NIXPKGS_ALLOW_UNFREE=1` environment variable is required for CUDA GPU inference because the NVIDIA CUDA toolkit is classified as unfree software in Nixpkgs. `--impure` is required for the Nix CLI to allow reading the `NIXPKGS_ALLOW_UNFREE` environment variable.

## Supported configurations

Currently, two acceleration modes are supported:

- `cpu`: Inference is performed using the CPU.
- `cuda`: Inference is performed using NVIDIA GPUs with CUDA support.
  - This requires a suitable NVIDIA GPU and the appropriate graphics drivers installed on your system.

The following large language models (LLMs) are available for testing in this project:

- `gemma-3-270m`: Gemma 3 270M Q8_0
- `gemma-3-1b`: Gemma 3 1B Q8_0
- `gemma-3-4b`: Gemma 3 4B Q4_K_M
- `qwen-3-0-6b`: Qwen3 0.6B Q8_0
- `qwen-3-1-7b`: Qwen3 1.7B Q8_0
- `qwen-3-4b`: Qwen3 4B Q4_K_M

The following LLM inference tasks are included in the project:

- `conversation`: Simple multi-turn conversation.
- `hello-curl`: Simple “Hello, world!” single-turn inference task, requested via a curl command.
- `hello-python`: Simple “Hello, world!” single-turn inference task, requested via a Python script.
- `high-temperature`: Single-turn inference task with a high temperature setting.
- `long-input`: Single-turn inference task with a long input prompt.
- `reasoning`: Single-turn inference task with reasoning enabled.
  - Note: Reasoning is only supported by the Qwen3 family of models. For the Gemma 3 family of models, this task will be a plain single-turn inference task without reasoning.
- `ten-paragraphs`: Single-turn inference task with an input prompt that requests a long output of ten paragraphs.
- `ten-paragraphs-logprobs`: Single-turn inference task with an input prompt that requests a long output of ten paragraphs. Log probabilities of the generated output are captured as well for this task.
- `tool-calling`: Simple multi-turn conversation where the model is expected to call a tool in the first turn and a different tool in the second turn.

## Directory structure

- `examples/`: Contains scripts and Nix derivations for the various inference tasks. `default.nix` in this directory defines the available acceleration modes, models and tasks, and generates the corresponding example scripts.
- `src/`: Contains the logic for wrapping an inference task with a script that sets up a llama.cpp server, runs the inference task, captures the output and logs, and shuts down the server after the inference is complete.
- `tests/`: Contains the reproducibility testing logic that compares the inference output against reference outputs in the tests.
- `tests/expected/`: Contains the reference outputs for all model–task combinations, which are used for reproducibility checking in the tests.
- `flake.nix`: The [Nix flake](https://wiki.nixos.org/wiki/Flakes) that exposes the packages that can be executed using `nix run` for running the inference tasks and reproducibility tests.
- `flake.lock`: The lock file for the Nix flake, which pins the exact version of [Nixpkgs](https://github.com/NixOS/nixpkgs/) used in this project.

## License

This project is licensed under the [Unlicense](https://unlicense.org/). See the [LICENSE](LICENSE) file for more details.
