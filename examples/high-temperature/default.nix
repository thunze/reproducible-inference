{
  stdenv,
  python3,
}:

stdenv.mkDerivation {
  name = "reproducible-inference-test-high-temperature";

  dontUnpack = true;

  buildInputs = [
    (python3.withPackages (ps: with ps; [ openai ]))
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a ${./main.py} $out/bin/high_temperature
  '';

  meta.mainProgram = "high_temperature";
}
