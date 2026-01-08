preBuildHooks+=(llamaServerStart)
postBuildHooks+=(llamaServerStop)

llamaServerStart() {
  echo "Starting llama.cpp server..."
}

llamaServerStop() {
  echo "Stopping llama.cpp server..."
}
