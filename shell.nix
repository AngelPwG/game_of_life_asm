{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    binutils
    gdb
  ];

  shellHook = ''
    echo "GNU Assembly environment"
    echo "as: $(as --version | head -n1)"
    echo "ld: $(ld --version | head -n1)"
  '';
}
