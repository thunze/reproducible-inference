{
  stdenv,
  python3,
}:

stdenv.mkDerivation {
  name = "reproducible-inference-test-tool-calling";

  dontUnpack = true;

  buildInputs = [
    (python3.withPackages (
      ps: with ps; [
        langchain
        langchain-openai
      ]
    ))
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a ${./main.py} $out/bin/tool_calling
  '';

  meta.mainProgram = "tool_calling";
}
