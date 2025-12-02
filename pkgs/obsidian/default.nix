{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:

stdenvNoCC.mkDerivation rec {
  pname = "obsidian";
  version = "1.10.6";

  src = fetchurl {
    url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/Obsidian-${version}.dmg";
    sha256 = "sha256-p/vYc1PXgCkzoT49kPVcORFMQZrEjUWaNWvatzwSioo=";
  };

  nativeBuildInputs = [ _7zz ];

  sourceRoot = ".";

  unpackCmd = ''
    7zz x $curSrc
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r Obsidian.app $out/Applications/

    runHook postInstall
  '';

  # Skip fixup phase to preserve signature
  dontFixup = true;

  meta = with lib; {
    description = "A powerful knowledge base on top of a local folder of plain text Markdown files";
    homepage = "https://obsidian.md";
    license = licenses.unfree;
    platforms = platforms.darwin;
    maintainers = with maintainers; [
      cffnpwr
    ];
  };
}
