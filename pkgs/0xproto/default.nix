{ lib, stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation rec {
  pname = "0xProto";
  version = "1.001";
  versionNonPeriod = builtins.replaceStrings [ "." ] [ "_" ] version;

  src = fetchzip {
    url = "https://github.com/0xType/0xProto/releases/download/${version}/0xProto_${versionNonPeriod}.zip";
    sha256 = "0i7y2c2g72lcz00xl3d57gyn3ckx9ic8nn5bi7pjs20vmwj6mfwd";
  };

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
      {
        name = "0xType";
        github = "0xType";
      }
    ];
    platforms = platforms.all;
  };
}
