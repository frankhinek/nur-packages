# nur-packages

Newer releases of tools than nixpkgs has yet, built with nixpkgs' own
recipes. Each package overrides only the version and the content hashes of
the recipe in nixpkgs, so it builds the way nixpkgs builds it and can be
dropped as soon as nixpkgs catches up.

| Package | Version | nixpkgs-unstable had | Why |
|---|---|---|---|
| `wrangler` | 4.163.0 | 4.156.0 (2026-11-15) | Security fixes in bundled packages (4.158.0, 4.159.0), credentials redacted from diagnostics (4.160.0) |

## Using it

As a devenv input, in `devenv.yaml`:

```yaml
inputs:
  nur-packages:
    url: github:frankhinek/nur-packages
```

and in `devenv.nix`:

```nix
{ pkgs, inputs, ... }:
{
  packages = [ inputs.nur-packages.packages.${pkgs.stdenv.system}.wrangler ];
}
```

As a flake input, take `packages.<system>.wrangler`, or apply
`overlays.default` to replace nixpkgs' `wrangler`. Without flakes,
`import ./default.nix { inherit pkgs; }` returns the same packages; the
layout is that of the Nix User Repository (NUR) template, so the repository
can also be registered with NUR.

## Building

Nothing here is in a binary cache, so the first use on a machine builds it.
Wrangler's build fetches the dependencies of Cloudflare's whole
`workers-sdk` repository, about 2.9 GB, once per machine; Nix shares the
result across projects.

```sh
nix build .#wrangler
./result/bin/wrangler --version
```

## Moving a package to a new release

In `pkgs/<name>.nix`: set `version`, set each hash to `pkgs.lib.fakeHash`,
then run `nix build .#<name>` once for each hash and copy the hash Nix
reports as `got:`. The recipe's version check fails the build if the
program reports any other version.
