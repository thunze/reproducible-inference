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
}

llamaServerStop() {
  echo "Stopping llama.cpp server..."

  wait -n $llama_server_pid
}
