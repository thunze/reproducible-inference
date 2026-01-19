{
  stdenv,
  python3,
}:

stdenv.mkDerivation {
  name = "reproducible-inference-test-conversation-basic";

  dontUnpack = true;

  buildInputs = [
    (python3.withPackages (ps: with ps; [ openai ]))
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a ${./main.py} $out/bin/conversation_basic
  '';

  meta.mainProgram = "conversation_basic";
}
