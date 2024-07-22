{
  description = "care.nvim package + dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    gen-luarc.url = "github:mrcjkb/nix-gen-luarc-json";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    gen-luarc,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = {system, ...}: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            gen-luarc.overlays.default
          ];
        };
        luarc = pkgs.mk-luarc {
          nvim = pkgs.neovim-unwrapped;
        };
      in {
        devShells.default = pkgs.mkShell {
          name = "lua devShell";
          shellHook = ''
            ln -fs ${pkgs.luarc-to-json luarc} .luarc.json
          '';
          buildInputs = with pkgs; [
            lua-language-server
            stylua
            alejandra
            (lua5_1.withPackages (ps:
              with ps; [
                luarocks
                busted
                luacheck
                fzy
                nlua
              ]))
          ];
        };

        packages = rec {
          default = care-nvim;
          care-nvim = pkgs.vimUtils.buildVimPlugin {
            pname = "care.nvim";
            version = "dev";
            src = self;
          };
          nvim = let
            config = pkgs.neovimUtils.makeNeovimConfig {
              plugins = with pkgs; [
                care-nvim
                fzy
              ];
            };
          in
            pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped config;
        };
      };
    };
}
