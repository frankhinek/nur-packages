{
  description = "Newer releases of tools than nixpkgs has yet, built with nixpkgs' own recipes";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      # Use as an overlay, or take the packages directly.
      overlays.default = import ./overlay.nix;

      packages = forAllSystems (pkgs: import ./default.nix { inherit pkgs; });
    };
}
