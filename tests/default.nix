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

  writeTest =
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
    conversation-basic = writeTest ./conversation-basic "cpu";
    conversation-long = writeTest ./conversation-long "cpu";
    hello-curl = writeTest ./hello-curl "cpu";
    hello-python = writeTest ./hello-python "cpu";
    high-temperature = writeTest ./high-temperature "cpu";
    ten-paragraphs = writeTest ./ten-paragraphs "cpu";
  };
  cuda = {
    conversation-basic = writeTest ./conversation-basic "cuda";
    conversation-long = writeTest ./conversation-long "cuda";
    hello-curl = writeTest ./hello-curl "cuda";
    hello-python = writeTest ./hello-python "cuda";
    high-temperature = writeTest ./high-temperature "cuda";
    ten-paragraphs = writeTest ./ten-paragraphs "cuda";
  };
}
