# fork by cffnpwr
# original: https://github.com/NixOS/nixpkgs/blob/7735258f8a8b809af52fc79ffe273040f0ee26a3/pkgs/by-name/te/teams/package.nix
{
  lib,
  stdenvNoCC,
  fetchurl,
  xar,
  pbzx,
  cpio,
}:

let
  pname = "teams";
  versions = {
    darwin = "25275.2602.4021.9366";
  };
  hashes = {
    darwin = "sha256-Nb2K5ARNdVvqGdwIvCiVP0hAMuaJH4/u6KN8s3r9QEI=";
  };
  meta = with lib; {
    description = "Microsoft Teams";
    homepage = "https://teams.microsoft.com";
    downloadPage = "https://teams.microsoft.com/downloads";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    maintainers = with maintainers; [ tricktron ];
    platforms = [
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "teams";
  };
in
stdenvNoCC.mkDerivation {
  inherit pname meta;
  version = versions.darwin;

  src = fetchurl {
    url = "https://statics.teams.cdn.office.net/production-osx/${versions.darwin}/MicrosoftTeams.pkg";
    hash = hashes.darwin;
  };

  nativeBuildInputs = [
    xar
    pbzx
    cpio
  ];

  unpackPhase = ''
    runHook preUnpack

    xar -xf $src

    runHook postUnpack
  '';

  # Prevent fixup phase to preserve signature
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    workdir=$(pwd)
    APP_DIR=$out/Applications
    mkdir -p $APP_DIR
    cd $APP_DIR
    pbzx -n "$workdir/MicrosoftTeams_app.pkg/Payload" | cpio -idm

    runHook postInstall
  '';
}
