{
  # Dependencies
  makeSetupHook,
  cudaPackages,
  curl,
  llama-cpp,

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
in
makeSetupHook {
  name = "llama-server-hook";

  propagatedBuildInputs = [
    curl
    llamaCppPkg
  ];

  substitutions = {
    inherit model seed;

    # Using an absurdly large number for --gpu-layers here because llama.cpp
    # apparently doesn't support requesting that all model layers be loaded
    # into VRAM.
    gpu_layers = if someAcceleration then 9999 else 0;
  };

} ./llama-server-hook.sh
