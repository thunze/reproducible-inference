{
  stdenv,
  llamaServerHook,
  curl,
  jq,
}:

stdenv.mkDerivation {
  name = "llama-server-hook-test-trivial";

  # We don't need to unpack any sources.
  dontUnpack = true;

  nativeBuildInputs = [
    llamaServerHook
    curl
    jq
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out

    curl http://127.0.0.1:8080/v1/chat/completions \
      -H "Content-Type: application/json" \
      -d '{
        "messages": [
          {"role": "user", "content": "Hello, world!"}
        ]
      }' \
      | jq -r '.choices.[0].message.content' \
      > $out/response.txt
    
    cat $out/response.txt

    runHook postBuild
  '';
}
