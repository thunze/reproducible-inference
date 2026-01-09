{
  callPackage,
  fetchurl,
}:

let
  llamaServerHook = callPackage ../src/llama-server-hook.nix {
    acceleration = false; # Use CPU for now
    model = fetchurl {
      url = "https://huggingface.co/ggml-org/gemma-3-270m-it-GGUF/resolve/main/gemma-3-270m-it-Q8_0.gguf";
      hash = "sha256-DvV9LIOEWKGVJmQmDcujjlvdo3SU869zLwbkrdJAaOM=";
    };
  };

  callTest =
    module:
    callPackage module {
      inherit llamaServerHook;
    };
in
{
  hello-curl = callTest ./hello-curl.nix;
}
