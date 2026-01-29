{
  writeShellApplication,
  curl,
  jq,
}:

writeShellApplication {
  name = "reproducible-inference-test-high-temperature";

  runtimeInputs = [
    curl
    jq
  ];

  # Disabling top-p and min-p sampling to isolate the effect of high temperature.
  # 
  # We are not using the OpenAI Python client here because OpenAI-compatible APIs
  # don't officially support the `min_p` parameter.
  text = ''
    curl http://127.0.0.1:8080/v1/chat/completions \
      -H "Content-Type: application/json" \
      -d '{
        "messages": [
          {"role": "user", "content": "test"}
        ],
        "temperature": 10,
        "top_p": 1.0,
        "min_p": 0.0
      }' \
      | jq -r '.choices.[0].message.content'
  '';
}
