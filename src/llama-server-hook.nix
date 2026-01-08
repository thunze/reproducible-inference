{
  makeSetupHook,
  llama-cpp,
}:

makeSetupHook {
  name = "llama-server-hook";

  propagatedBuildInputs = [
    llama-cpp
  ];
} ./llama-server-hook.sh
