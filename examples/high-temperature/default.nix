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
  # Also setting an upper bound on the number of output tokens to prevent
  # excessively long outputs that could result from the high temperature setting.
  #
  # We're not using the OpenAI Python client here because OpenAI-compatible APIs
  # don't officially support the `min_p` parameter.
  text = ''
    curl http://127.0.0.1:8080/v1/chat/completions \
      -H "Content-Type: application/json" \
      -d '{
        "messages": [
          {"role": "user", "content": "Hello, world!"}
        ],
        "temperature": 10,
        "top_p": 1.0,
        "min_p": 0.0,
        "max_tokens": 500
      }' \
      | jq -r '.choices.[0].message.content'
  '';
}
