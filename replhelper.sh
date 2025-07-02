#!/bin/bash

REVISION=$1
REVISION_LOCAL_PATH=`find /nix/store -maxdepth 1 -type d -print | rg --regexp=".*$REVISION"`

if [[ -z "$REVISION_LOCAL_PATH" ]];
then
    echo "nixpkgs version not found in store, downloading via github..."
    SHA=`nix-prefetch-url --unpack https://github.com/NixOS/nixpkgs/tarball/$REVISION`
else
    echo "local path to nixpkgs revision:$REVISION_LOCAL_PATH"
    SHA=`nix-store --query --hash $REVISION_LOCAL_PATH`
fi

echo "sha -> $SHA"

nix repl --expr "import(
builtins.fetchTarball{
    url = \"https://github.com/NixOS/nixpkgs/tarball/$REVISION\";
    sha256 = \"$SHA\";
  }	
){}"
