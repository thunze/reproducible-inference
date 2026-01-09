{
  # Dependencies
  makeSetupHook,
  curl,
  llama-cpp,

  # Model to be hosted by llama.cpp server in GGUF format, e.g. fetched using fetchurl
  model,

  # One of:
  # - false (CPU)
  # - "cuda" (NVIDIA GPU)
  acceleration ? false,

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
