{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
  xar,
  gzip,
  cpio,
}:

stdenvNoCC.mkDerivation {
  pname = "google-japanese-ime";
  version = "2.30.5590";

  src = fetchurl {
    url = "https://dl.google.com/japanese-ime/latest/GoogleJapaneseInput.dmg";
    # Google doesn't provide stable URLs with hashes, hash may change when updated
    sha256 = "sha256-j6vXsk9x7QphwKqFcgTzX+s7yR6ImcAjxhTxkpIUUgc=";
  };

  nativeBuildInputs = [
    undmg
    xar
    gzip
    cpio
  ];

  sourceRoot = ".";

  # Extract DMG, then .pkg, then payload
  unpackPhase = ''
    undmg $src
    mkdir -p pkg-extract
    cd pkg-extract
    ${xar}/bin/xar -xf ../GoogleJapaneseInput.pkg
    cd GoogleJapaneseInput.pkg
    ${gzip}/bin/zcat Payload | ${cpio}/bin/cpio -i
  '';

  installPhase = ''
    runHook preInstall

    # Copy extracted files preserving structure
    mkdir -p $out
    cp -R Library $out/
    cp -R Applications $out/

    runHook postInstall
  '';

  # Don't modify binaries to preserve Apple code signing
  dontFixup = true;

  meta = with lib; {
    description = "Google Japanese Input Method Editor";
    homepage = "https://www.google.co.jp/ime/";
    license = licenses.unfree;
    platforms = platforms.darwin;
    maintainers = with maintainers; [
      cffnpwr
    ];
  };
}
