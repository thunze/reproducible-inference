{
  stdenv,
  llamaServerHook,
  python3,
}:

let
  python = python3.withPackages (ps: with ps; [ openai ]);
in
stdenv.mkDerivation {
  name = "llama-server-hook-test-hello-python";

  src = ./.;

  nativeBuildInputs = [
    llamaServerHook
  ];

  # stdenv sets `SSL_CERT_FILE` to a non-existent file by default and httpx
  # always reads the file at `$SSL_CERT_FILE` if set.
  preBuild = ''
    unset SSL_CERT_FILE
  '';

  buildPhase = ''
    runHook preBuild

    mkdir -p $out

    ${python.interpreter} main.py

    runHook postBuild
  '';
}
