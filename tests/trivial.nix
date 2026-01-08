{
  stdenv,
  llamaServerHook,
}:

stdenv.mkDerivation {
  name = "llama-server-hook-test-trivial";

  # We don't need to unpack any sources.
  dontUnpack = true;

  nativeBuildInputs = [
    llamaServerHook
  ];
}
