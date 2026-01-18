{
  stdenv,
  python3,
}:

stdenv.mkDerivation {
  name = "reproducible-inference-test-ten-paragraphs";

  dontUnpack = true;

  buildInputs = [
    (python3.withPackages (ps: with ps; [ openai ]))
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a ${./ten_paragraphs.py} $out/bin/ten_paragraphs
  '';

  meta.mainProgram = "ten_paragraphs";
}
