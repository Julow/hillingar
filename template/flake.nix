{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    hillingar.url = "github:RyanGibb/hillingar";

    # use different repositories to those pinned in hillingar
    #hillingar.inputs.opam-repository.follows = "opam-repository";
    #hillingar.inputs.opam-overlays.follows = "opam-overlays";
    #opam-repository = {
    #  url = "github:ocaml/opam-repository";
    #  flake = false;
    #};
    #opam-overlays = {
    #  url = "github:dune-universe/opam-overlays";
    #  flake = false;
    #};

    # make hillingar's nixpkgs follow this flake
    # useful if pinning nixos system nixpkgs with
    #   `nix.registry.nixpkgs.flake = nixpkgs;`
    #hillingar.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, hillingar, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = let
          mirage-nix = (hillingar.lib.${system});
          inherit (mirage-nix) mkUnikernelPackages;
        in mkUnikernelPackages {
          unikernelName = throw "Put the unikernel name here";
          # list external dependencies here
          depexts = with pkgs; [ ];
          # specify mirage files in a non-root directory
          #mirageDir = "mirage";
          monorepoQuery = {
            # solve for non-trunk compiler
            ocaml-base-compiler = "*";
            # workaround https://github.com/RyanGibb/hillingar/issues/3
            # if a package doesn't have an overlay to build with dune
            # find a version https://github.com/dune-universe/opam-overlays/
            # or
            # find a version https://github.com/dune-universe/mirage-opam-overlays/
            #<package> = "<version>";
          };
          query = {
            # solve for non-trunk compiler
            ocaml-base-compiler = "*";
            # use a specific version of mirage
            #mirage = "4.5.0";
          };
        } self;

        defaultPackage = self.packages.${system}.unix;
      });
}
