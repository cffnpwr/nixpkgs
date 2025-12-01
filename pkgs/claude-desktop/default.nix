{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "claude";
  version = "0.13.37";
  commit = "bfd4edc4eb20f97ee38d1b36c081d83da6d1a37b";

  src = fetchurl {
    url = "https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest/release-${version}-artifact-${commit}.zip";
    sha256 = "24371bd47b33ac69067f3bdd333049d939d86250fe4ef17a03eeb5944617c95f";
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r Claude.app $out/Applications/

    runHook postInstall
  '';

  # Skip fixup phase to preserve signature
  skipFixup = true;

  meta = with lib; {
    description = "Claude AI assistant desktop application";
    homepage = "https://claude.ai";
    license = licenses.unfree;
    platforms = platforms.darwin;
    maintainers = with maintainers; [
      cffnpwr
    ];
  };
}
