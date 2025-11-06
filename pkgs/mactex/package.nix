{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "mactex-no-gui";
  version = "2025.0308";

  src = fetchurl {
    url = "https://mirror.ctan.org/systems/mac/mactex/mactex-${
      builtins.replaceStrings [ "." ] [ "" ] version
    }.pkg";
    sha256 = "be084f849e545d9e9511b791da07ca4f9f33d85d42bb69dade636e345421ab7c";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp $src $out/mactex.pkg

    # Create symlinks to MacTeX binaries (exclude conflicting commands)
    for bin in /Library/TeX/texbin/*; do
      basename_bin=$(basename "$bin")
      # Skip man command to avoid conflict with man-db
      if [ "$basename_bin" != "man" ]; then
        ln -s "$bin" "$out/bin/$basename_bin"
      fi
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Full TeX Live distribution without GUI applications";
    homepage = "https://www.tug.org/mactex/";
    license = licenses.free;
    platforms = platforms.darwin;
    maintainers = with maintainers; [
      cffnpwr
    ];
  };
}
