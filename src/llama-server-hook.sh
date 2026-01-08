preBuildHooks+=(llamaServerStart)
postBuildHooks+=(llamaServerStop)

llamaServerStart() {
  echo "Starting llama.cpp server..."

  llama-server \
    --model @model@ \
    --seed @seed@ \
    --gpu-layers @gpu_layers@ \
    --ctx-size 0 &  # Load prompt context size from model

  llama_server_pid=$!

  # Wait for the server to start and be healthy, time out after 3 retries
  curl \
    --retry 3 \
    --retry-all-errors \
    -o /dev/null \
    http://127.0.0.1:8080/health
}

llamaServerStop() {
  echo "Stopping llama.cpp server..."

  wait -n $llama_server_pid
}
