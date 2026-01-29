{
  writeShellApplication,
  curl,
  jq,
}:

writeShellApplication {
  name = "reproducible-inference-test-hello-curl";

  runtimeInputs = [
    curl
    jq
  ];

  text = ''
    curl http://127.0.0.1:8080/v1/chat/completions \
      -H "Content-Type: application/json" \
      -d '{
        "messages": [
          {"role": "user", "content": "Hello, world!"}
        ]
      }' \
      | jq -r '.choices.[0].message.content'
  '';
}
