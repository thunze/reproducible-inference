{
  stdenv,
  python3,
}:

stdenv.mkDerivation {
  name = "reproducible-inference-test-conversation-long";

  dontUnpack = true;

  buildInputs = [
    (python3.withPackages (ps: with ps; [ openai ]))
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a ${./main.py} $out/bin/conversation_long
  '';

  meta.mainProgram = "conversation_long";
}
