{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.meson
    pkgs.clang-tools
    pkgs.llvmPackages.libcxxClang
  ];
}

