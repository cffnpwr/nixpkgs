{ lib, stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation rec {
  pname = "Koruri";
  version = "20210720";

  src = fetchzip {
    url = "https://github.com/Koruri/Koruri/archive/refs/tags/${version}.zip";
    sha256 = "0yadd6rcyf940c441zr1m90srhz9xjsak281bvn6p6br7nsm9gyc";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 *.ttf -t $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with lib; {
    description = "Japanese TrueType font obtained by mixing M+ FONTS and Open Sans.";
    homepage = "https://github.com/Koruri/Koruri";
    changelog = "https://github.com/Koruri/Koruri/releases/tag/${version}";
    license = licenses.asl20;
    maintainers = [
      {
        name = "lindwurm";
        github = "lindwurm";
      }
    ];
    platforms = platforms.all;
  };
}
