{
  callPackage,
  fetchurl,
}:

let
  writeTest =
    module:
    callPackage ../src/write-llama-wrapper.nix {
      unwrapped = callPackage module { };
      acceleration = false; # Use CPU for now
      model = fetchurl {
        url = "https://huggingface.co/ggml-org/gemma-3-270m-it-GGUF/resolve/main/gemma-3-270m-it-Q8_0.gguf";
        hash = "sha256-DvV9LIOEWKGVJmQmDcujjlvdo3SU869zLwbkrdJAaOM=";
      };
    };
in
{
  hello-curl = writeTest ./hello-curl;
  hello-python = writeTest ./hello-python;
}
