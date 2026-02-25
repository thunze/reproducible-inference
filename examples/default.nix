{
  lib,
  callPackage,
  fetchurl,
}:

let
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

  writeExample =
    module: acceleration:
    callPackage ../src/write-llama-wrapper.nix (
      {
        unwrapped = callPackage module { };
        model = gemma-3-270m;
        acceleration = if acceleration == "cpu" then false else acceleration;
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
{
  cpu = {
    conversation-basic = writeExample ./conversation-basic "cpu";
    conversation-long = writeExample ./conversation-long "cpu";
    hello-curl = writeExample ./hello-curl "cpu";
    hello-python = writeExample ./hello-python "cpu";
    high-temperature = writeExample ./high-temperature "cpu";
    long-input = writeExample ./long-input "cpu";
    ten-paragraphs = writeExample ./ten-paragraphs "cpu";
    ten-paragraphs-logprobs = writeExample ./ten-paragraphs-logprobs "cpu";
    tool-calling = writeExample ./tool-calling "cpu";
  };
  cuda = {
    conversation-basic = writeExample ./conversation-basic "cuda";
    conversation-long = writeExample ./conversation-long "cuda";
    hello-curl = writeExample ./hello-curl "cuda";
    hello-python = writeExample ./hello-python "cuda";
    high-temperature = writeExample ./high-temperature "cuda";
    long-input = writeExample ./long-input "cuda";
    ten-paragraphs = writeExample ./ten-paragraphs "cuda";
    ten-paragraphs-logprobs = writeExample ./ten-paragraphs-logprobs "cuda";
    tool-calling = writeExample ./tool-calling "cuda";
  };
}
