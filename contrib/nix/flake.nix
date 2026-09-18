{
  description = "CFEngine Masterfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        baseVersion = lib.strings.trim (builtins.readFile ../../.CFVERSION);
        shortSha =
          if self ? rev then builtins.substring 0 9 self.rev
          else if self ? dirtyRev then builtins.substring 0 9 self.dirtyRev
          else "unknown0";
        version = "${baseVersion}a.${shortSha}";

        masterfiles = pkgs.callPackage ./masterfiles.nix { inherit version; };
      in
      {
        packages.default = masterfiles;
      }
    );
}
