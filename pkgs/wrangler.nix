# Cloudflare's Wrangler at a newer release than nixpkgs has, built with
# nixpkgs' own recipe (pkgs/by-name/wr/wrangler/package.nix): only the
# version and the two content hashes change. The recipe's version check
# confirms the built program reports this version.
#
# To move to a new release: set `version`, set both hashes to
# `lib.fakeHash`, build, and copy each hash Nix reports in turn.
{ pkgs }:
pkgs.wrangler.overrideAttrs (
  finalAttrs: old: {
    version = "4.163.0";

    src = pkgs.fetchFromGitHub {
      owner = "cloudflare";
      repo = "workers-sdk";
      rev = "wrangler@${finalAttrs.version}";
      hash = "sha256-401gvvf4XEeoWjXzQf+p8n9OYOJrF9bjP/VIAKst4j8=";
    };

    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs)
        pname
        version
        src
        postPatch
        ;
      pnpm = pkgs.pnpm_10;
      fetcherVersion = 3;
      hash = "sha256-JnHy68faWvolTUNuIrcRcOCGqsAuxlPv7g5/RAgSqgM=";
    };

    # Since 4.159, Wrangler's local browser rendering brings in `kerberos`
    # (through @puppeteer/browsers and proxy-agent), and workers-sdk lets pnpm
    # run its install script, which compiles a native module with node-gyp.
    # It only adds Kerberos authentication for HTTP proxies and is loaded only
    # when a proxy asks for it, so the install skips scripts instead of
    # compiling it. Only `kerberos` is allowed to run scripts at all.
    installPhase =
      let
        from = "pnpm --filter=wrangler --prod deploy $out/lib";
        to = "pnpm --filter=wrangler --prod --ignore-scripts deploy $out/lib";
      in
      assert pkgs.lib.hasInfix from old.installPhase;
      builtins.replaceStrings [ from ] [ to ] old.installPhase;
  }
)
