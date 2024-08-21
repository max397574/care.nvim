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
            self.overlays.default
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
          inherit (pkgs.vimPlugins) care-nvim;
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
      flake = {
        overlays.default = final: prev: let
          luaPackage-override = luaself: luaprev: {
            care-nvim = luaself.callPackage ({
              buildLuarocksPackage,
              lua,
              fzy,
            }:
              buildLuarocksPackage {
                pname = "care.nvim";
                version = "scm-1";
                knownRockspec = "${self}/care.nvim-scm-1.rockspec";
                propagatedBuildInputs = [
                  lua
                  fzy
                ];
              }) {};
          };
        in {
          lua5_1 = prev.lua5_1.override {
            packageOverrides = luaPackage-override;
          };
          lua51Packages = prev.lua51Packages // final.lua5_1.pkgs;
          vimPlugins =
            prev.vimPlugins
            // {
              care-nvim = final.neovimUtils.buildNeovimPlugin {
                pname = "care.nvim";
                version = "dev";
                src = self;
              };
            };
        };
      };
    };
}
