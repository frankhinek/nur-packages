# The packages, in the layout of the Nix User Repository (NUR) template:
# a top-level default.nix that takes nixpkgs and returns an attribute set.
# flake.nix builds on this file.
{
  pkgs ? import <nixpkgs> { },
}:
{
  wrangler = import ./pkgs/wrangler.nix { inherit pkgs; };
}
