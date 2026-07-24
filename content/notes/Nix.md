## flake.nix Template for DevShell

```
{
  description = "project shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          # tools go here
        ];
      };
    };
}
```

## Update flake lock (optionally, restrict to single input by name)

```
nix flake update [foo]
```

## Start Nix Shell with program foo

```
nix-shell -p foo
```

## Spawn OpenAI Codex

```
nix --extra-experimental-features nix-command --extra-experimental-features flakes shell nixpkgs#nodejs -c npx @openai/codex
```

## Collect Garbage

```
nix-collect-garbage
```

## ionice nixpkgs-review

```
ionice -c3 nice -n 19 nixpkgs-review rev HEAD
```
