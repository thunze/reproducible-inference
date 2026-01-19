{
  stdenv,
  python3,
}:

stdenv.mkDerivation {
  name = "reproducible-inference-test-ten-paragraphs-logprobs";

  dontUnpack = true;

  buildInputs = [
    (python3.withPackages (ps: with ps; [ openai ]))
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a ${./main.py} $out/bin/ten_paragraphs_logprobs
  '';

  meta.mainProgram = "ten_paragraphs_logprobs";
}
