# Replaces nixpkgs' packages with these releases.
final: prev: import ./default.nix { pkgs = prev; }
