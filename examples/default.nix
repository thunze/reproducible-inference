{
  lib,
  callPackage,
  fetchurl,
  ...
}:

let
  # Acceleration types to generate example derivations for.
  accelerations = [
    # Run purely on the CPU, with no GPU acceleration.
    "cpu"
    # Run with CUDA acceleration on NVIDIA GPUs. Requires a compatible
    # NVIDIA GPU and driver installed.
    "cuda"
  ];

  # List of large language models to generate example derivations for.
  # Each model evaluates to a model file in GGUF format.
  models = {
    gemma-3-270m = fetchurl {
      url = "https://huggingface.co/ggml-org/gemma-3-270m-it-GGUF/resolve/main/gemma-3-270m-it-Q8_0.gguf";
      hash = "sha256-DvV9LIOEWKGVJmQmDcujjlvdo3SU869zLwbkrdJAaOM=";
    };
    gemma-3-1b = fetchurl {
      url = "https://huggingface.co/ggml-org/gemma-3-1b-it-GGUF/resolve/main/gemma-3-1b-it-Q8_0.gguf";
      hash = "sha256-sgWEDF3O9VB44300RneGmnFP/UKkrkSMSNz7UuS7ENU=";
    };
    gemma-3-4b = fetchurl {
      url = "https://huggingface.co/ggml-org/gemma-3-4b-it-GGUF/resolve/main/gemma-3-4b-it-Q4_K_M.gguf";
      hash = "sha256-iC6NLbRNxVT7DqUHfLfkvEnnNCofDaV5AcCALqIaCGM=";
    };
    granite-4-350m = fetchurl {
      url = "https://huggingface.co/unsloth/granite-4.0-350m-GGUF/resolve/main/granite-4.0-350m-Q4_0.gguf";
      hash = "sha256-0Hn2yKm0JebHrKJa+9NNcgkZhCRr9kCbgAqPgcJX6h8=";
    };
  };

  # List of module names corresponding to derivations of example scripts in
  # this directory to generate examples for.
  modules = [
    "conversation-basic"
    "conversation-long"
    "hello-curl"
    "hello-python"
    "high-temperature"
    "long-input"
    "ten-paragraphs"
    "ten-paragraphs-logprobs"
    "tool-calling"
  ];

  # Wrap a concrete example script with the necessary llama.cpp wrapper and
  # model configuration to run it.
  # Takes an acceleration type, model name, and module name as arguments and
  # returns a derivation of the wrapped example script.
  writeExample =
    {
      acceleration,
      model,
      module,
    }:
    callPackage ../src/write-llama-wrapper.nix (
      {
        acceleration = if acceleration == "cpu" then false else acceleration;
        model = models.${model};
        unwrapped = callPackage ./${module} { };
      }
      // lib.optionalAttrs (acceleration == "cuda") {
        # For our CUDA tests, we are using NVIDIA GPUs as old as the GeForce 900 series
        # (compute capability 5.2), so we include architectures from 5.2 upwards.
        # This will require compilation of llama-cpp with support for these architectures
        # but gives us one binary that works across a wide range of GPUs.
        cudaArchitecturesString = "52;60;61;70;75;80;86;89;90;100;120";
      }
    );
in
# The resulting attribute set looks like this:
#
# {
#   cpu.gemma-3-270m.conversation-basic = <derivation of wrapped example script>;
#   cpu.gemma-3-270m.conversation-long = <derivation of wrapped example script>;
#   ...
# }
builtins.foldl' lib.recursiveUpdate { } (
  lib.mapCartesianProduct
    (
      {
        acceleration,
        model,
        module,
      }:
      {
        ${acceleration}.${model}.${module} = writeExample {
          inherit acceleration module model;
        };
      }
    )
    {
      acceleration = accelerations;
      model = lib.attrNames models; # `models` is an attribute set
      module = modules;
    }
)
