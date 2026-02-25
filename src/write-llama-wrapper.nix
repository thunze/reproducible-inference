{
  # Derivation whose main program to wrap (determined via `lib.getExe`)
  unwrapped,

  # Model to be hosted by llama.cpp server in GGUF format, e.g. fetched using fetchurl
  model,

  # One of:
  # - false (CPU)
  # - "cuda" (NVIDIA GPU)
  acceleration ? false,

  # Semicolon-separated list of CUDA architectures llama-cpp should be compiled for
  # when using CUDA acceleration. Change this if the default architectures configured
  # in `cudaPackages.flags.cmakeCudaArchitecturesString` don't cover your GPU and
  # therefore llama-cpp cannot utilize your GPU as it wasn't built for its architecture.
  #
  # Example:
  #   "52;60;61;70;75;80;86;89;90;100;120"
  #
  # Lists of NVIDIA GPU architectures:
  #   - https://developer.nvidia.com/cuda/gpus
  #   - https://developer.nvidia.com/cuda/gpus/legacy
  cudaArchitecturesString ? cudaPackages.flags.cmakeCudaArchitecturesString,

  # RNG seed used by llama.cpp
  seed ? 42,

  # Dependencies
  lib,
  writeShellApplication,
  cudaPackages,
  curl,
  llama-cpp,
}:

assert builtins.elem acceleration [
  false
  "cuda"
];

let
  someAcceleration = acceleration != false;

  # Configure llama-cpp package for `acceleration`
  llamaCppPkg =
    if !someAcceleration then
      llama-cpp
    else
      {
        cuda = llama-cpp.override {
          cudaSupport = true;
          cudaPackages = cudaPackages // {
            flags = cudaPackages.flags // {
              cmakeCudaArchitecturesString = cudaArchitecturesString;
            };
          };
        };
      }
      .${acceleration};

  # Using an absurdly large number for --gpu-layers here because llama.cpp
  # apparently doesn't support requesting that all model layers be loaded
  # into VRAM.
  gpuLayers = if someAcceleration then 9999 else 0;
in
writeShellApplication {
  name = "${unwrapped.name}-wrapped";

  runtimeInputs = [
    curl
    llamaCppPkg
  ];

  # llama-server flags used:
  #
  #   --model        Path to GGUF model file
  #   --seed         RNG seed for reproducibility
  #   --gpu-layers   Number of model layers to load into GPU memory
  #   --ctx-size 0   Load prompt context size from model
  #   --no-warmup    Avoid unnecessary GPU warmup time
  #
  # Using `>&2` to redirect all output except that of the wrapped application
  # to stderr to keep stdout clean for the wrapped application.
  text = ''
    cleanup() {
      if [[ -n "''${llama_server_pid:-}" ]]; then
        >&2 echo "Stopping llama.cpp server..."
        >&2 kill -s TERM "$llama_server_pid"
        >&2 wait -n "$llama_server_pid"
      fi
    }

    trap cleanup EXIT

    >&2 echo "Starting llama.cpp server..."

    >&2 llama-server \
      --model ${model} \
      --seed ${builtins.toString seed} \
      --gpu-layers ${builtins.toString gpuLayers} \
      --ctx-size 0 \
      --no-warmup &

    llama_server_pid=$!

    # Wait for the server to start and be healthy, time out after 3 retries
    >&2 curl \
      --retry 5 \
      --retry-all-errors \
      -o /dev/null \
      http://127.0.0.1:8080/health

    >&2 echo "Successfully started llama.cpp server!"

    ${lib.getExe unwrapped} "$@"
  '';
}
