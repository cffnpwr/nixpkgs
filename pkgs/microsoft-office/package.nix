{
  lib,
  stdenvNoCC,
  fetchurl,
  xar,
  gzip,
  cpio,
}:

stdenvNoCC.mkDerivation rec {
  pname = "microsoft-office";
  version = "16.102.25101223";

  src = fetchurl {
    url = "https://officecdnmac.microsoft.com/pr/C1297A47-86C4-4C1F-97FA-950631F94777/MacAutoupdate/Microsoft_365_and_Office_${version}_Installer.pkg";
    sha256 = "sha256-3NBXGkxkHoMcbbMxwTbspRR5ERnB/8MEA8EdeqrZ35U=";
  };

  nativeBuildInputs = [
    xar
    gzip
    cpio
  ];

  sourceRoot = ".";

  # Extract .pkg payload
  unpackPhase = ''
    mkdir -p pkg-extract
    cd pkg-extract
    ${xar}/bin/xar -xf $src

    # Extract all Payload files from sub-packages
    for pkg_dir in Microsoft_*_Internal.pkg Office*.pkg; do
      if [ -d "$pkg_dir" ] && [ -f "$pkg_dir/Payload" ]; then
        echo "Extracting $pkg_dir..."
        cd "$pkg_dir"
        ${gzip}/bin/zcat Payload | ${cpio}/bin/cpio -id 2>/dev/null
        cd ..
      fi
    done
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mkdir -p $out/Library/Frameworks

    # Copy Microsoft Office applications
    for app in Microsoft_*_Internal.pkg/*.app; do
      if [ -d "$app" ]; then
        echo "Installing $(basename "$app")..."
        cp -R "$app" $out/Applications/
      fi
    done

    # Copy shared frameworks
    if [ -d Office_frameworks.pkg/Frameworks ]; then
      echo "Installing frameworks..."
      cp -R Office_frameworks.pkg/Frameworks/* $out/Library/Frameworks/
    fi

    runHook postInstall
  '';

  # Skip fixup phase to preserve signature
  skipFixup = true;

  meta = with lib; {
    description = "Microsoft Office Suite (Word, Excel, PowerPoint, etc.)";
    homepage = "https://www.microsoft.com/microsoft-365";
    license = licenses.unfree;
    platforms = platforms.darwin;
    maintainers = with maintainers; [
      cffnpwr
    ];
  };
}
