{
  lib,
  stdenv,
  fetchgit,
  haskellPackages,
  writeShellScriptBin,
}:
let
  src = fetchgit {
    url = "https://github.com/kmonad/kmonad";
    rev = "5e1c2b7c844dde844498532fccaedb73a0e5e6d9"; # v0.4.4
    sha256 = "1na88075c0axfw9ip59lzsrccr302a7a6v1r6nkjl7r6n235f18l";
    fetchSubmodules = true;
  };

  fakeGit = writeShellScriptBin "git" ''
    echo ${src.rev}
  '';
in
haskellPackages.mkDerivation {
  pname = "kmonad";
  version = "0.4.4";
  inherit src;

  license = lib.licenses.mit;

  isLibrary = true;
  isExecutable = true;

  # Haskell dependencies from cabal2nix output
  libraryHaskellDepends = with haskellPackages; [
    base
    cereal
    hashable
    lens
    megaparsec
    mtl
    optparse-applicative
    resourcet
    rio
    template-haskell
    time
    transformers
    unix
    unliftio
  ];

  executableHaskellDepends = with haskellPackages; [ base ];

  testHaskellDepends = with haskellPackages; [
    base
    hspec
    rio
  ];

  testToolDepends = with haskellPackages; [ hspec-discover ];

  configureFlags = lib.optional stdenv.hostPlatform.isDarwin "--flag=dext";

  buildTools = [ fakeGit ];

  preConfigure = lib.optionalString stdenv.hostPlatform.isDarwin ''
    if [ ! -d c_src/mac/Karabiner-DriverKit-VirtualHIDDevice/include ]; then
      echo "Karabiner submodule not found. This package needs to be built with submodules on darwin." 1>&2
      exit 1
    fi
  '';

  description = "Advanced keyboard remapping utility";
  homepage = "https://github.com/kmonad/kmonad";
  platforms = lib.platforms.unix;
  mainProgram = "kmonad";
}
