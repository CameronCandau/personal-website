{
  description = "Development shell for the Hugo site";

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
          ];

          shellHook = ''
            cat <<'EOF'
            Dev shell ready.

            Preview full site:
              hugo server
            EOF
          '';
        };
      });
}
