{
  description = "Helium macOS development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        llvmNoChecks = pkgs.llvm.overrideAttrs (old: {
          doCheck = false;
          doInstallCheck = false;
          doTest = false;
        });
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            (pkgs.python311.withPackages (
              ps: with ps; [
                pip
                httplib2
              ]
            ))
            pkgs.ninja
            pkgs.coreutils-prefixed
            pkgs.readline
            pkgs.xz
            pkgs.zlib
            pkgs.perl
            pkgs.nodejs
            pkgs.git
            pkgs.rustc
            pkgs.cargo
            pkgs.quilt
            pkgs.libiconv
            # llvmNoChecks
          ];
          shellHook = ''
            export LDFLAGS="-L${pkgs.libiconv}/lib $LDFLAGS"
            export CPPFLAGS="-I${pkgs.libiconv}/include $CPPFLAGS"
            export LIBRARY_PATH="${pkgs.libiconv}/lib:$LIBRARY_PATH"
            export RUSTFLAGS="-L ${pkgs.libiconv}/lib $RUSTFLAGS"
            export PKG_CONFIG_PATH="${pkgs.libiconv}/lib/pkgconfig:$PKG_CONFIG_PATH"
            echo "Helium macOS dev environment loaded."
          '';
        };
      }
    );
}
