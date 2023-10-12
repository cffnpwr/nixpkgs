{ lib, stdenvNoCC, fetchzip, pkgs }:

let
  maintainers = import ../../maintainers.nix;
in
stdenvNoCC.mkDerivation rec {
  pname = "0xProto";
  version = "1.300";
  versionNonPeriod = builtins.replaceStrings [ "." ] [ "_" ] version;

  src = fetchzip {
    url = "https://github.com/0xType/0xProto/releases/download/${version}/0xProto_${versionNonPeriod}.zip";
    sha256 = "0i7y2c2g72lcz00xl3d57gyn3ckx9ic8nn5bi7pjs20vmwj6mfwd";
  };

  buildInputes = with pkgs; [
    nerd-font-patcher
  ];

  buildPhase = ''
    runHook preBuild

    nerd-font-patcher 0xProto-Regular.otf
    nerd-font-patcher 0xProto-Regular.ttf

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 *.otf -t $out/share/fonts/opentype
    install -Dm644 *.ttf -t $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with lib; {
    description = "Free and Open-source font for programming.";
    homepage = "https://github.com/0xType/0xProto";
    changelog = "https://github.com/0xType/0xProto/releases/tag/${version}";
    license = licenses.ofl;
    maintainers = [
      maintainers.cffnpwr
    ];
    platforms = platforms.all;
  };
}
