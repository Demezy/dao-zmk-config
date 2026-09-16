{
  description = "ZMK firmware for the Dao keyboard";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zmk-nix }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
  in {
    packages = forAllSystems (system: let
      inherit (zmk-nix.legacyPackages.${system}) buildKeyboard buildSplitKeyboard;

      common = {
        src = nixpkgs.lib.sourceFilesBySuffices self [ ".conf" ".json" ".keymap" ".yml" ];

        # Bump with `nix run .#update` after changing revisions in config/west.yml.
        zephyrDepsHash = "sha256-SfZLXdFc4rJSaoV+89txAm3dDvZqYZFjfBUVRA/7wiE=";

        # nanopb pinned by ZMK v0.3 imports pkg_resources, which current setuptools no longer ships.
        postConfigure = ''
          if [ -d ../modules/lib/nanopb/generator/proto ]; then
            sed -i \
              -e 's/import pkg_resources/import importlib.resources/' \
              -e "s/pkg_resources.resource_filename('grpc_tools', '_proto')/str(importlib.resources.files('grpc_tools') \/ '_proto')/" \
              ../modules/lib/nanopb/generator/proto/{__init__,_utils}.py
          fi
        '';

        meta = {
          description = "ZMK firmware for the Dao keyboard";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };
    in rec {
      default = firmware;

      firmware = buildSplitKeyboard (common // {
        name = "dao-firmware";
        board = "dao_%PART%";
      });

      firmware-studio = buildSplitKeyboard (common // {
        name = "dao-firmware-studio";
        board = "dao_%PART%";
        enableZmkStudio = true;
        inherit (firmware) westDeps;
      });

      settings-reset = buildKeyboard (common // {
        name = "settings-reset";
        board = "nice_nano_v2";
        shield = "settings_reset";
        inherit (firmware) westDeps;
      });

      flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}
