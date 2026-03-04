{
  stdenv,
  python3,
}:

stdenv.mkDerivation {
  name = "reproducible-inference-test-long-input-logprobs";

  dontUnpack = true;

  buildInputs = [
    (python3.withPackages (ps: with ps; [ openai ]))
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a ${./main.py} $out/bin/long_input_logprobs
  '';

  meta.mainProgram = "long_input_logprobs";
}
