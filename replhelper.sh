#!/bin/bash

REVISION=$1

nix repl --expr "import(
builtins.fetchTarball{
    url = \"https://github.com/NixOS/nixpkgs/tarball/$REVISION\";
  }	
){}"
