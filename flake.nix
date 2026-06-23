{
  description = "Development shell for the Hugo site and embedded Quartz CTF section";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bashInteractive
            git
            hugo
            nodejs_22
            rsync
          ];

          shellHook = ''
            export CTF_QUARTZ_DIR="$PWD/ctf-quartz"
            export CTF_OUTPUT_DIR="$PWD/static/ctf"
            export npm_config_cache="$PWD/.npm-cache"

            cat <<'EOF'
            Dev shell ready.

            First-time Quartz setup:
              cd ctf-quartz && npm ci

            Build CTF output into Hugo:
              ./scripts/build-ctf.sh

            Preview full site:
              hugo server

            Optional live Quartz preview:
              cd ctf-quartz
              node ./quartz/bootstrap-cli.mjs build -d content -o ../static/ctf --serve
            EOF
          '';
        };
      });
}
