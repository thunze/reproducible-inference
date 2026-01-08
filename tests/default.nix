{
  callPackage,
  llamaServerHook,
}:

let
  callTest = module: callPackage module { inherit llamaServerHook; };
in
{
  trivial = callTest ./trivial.nix;
}
