{ pkgs, lib }:
pkgs.stdenvNoCC.mkDerivation {
  pname = "mozc-config-proto";
  version = "2.31.5851.102";

  src = pkgs.fetchFromGitHub {
    owner = "google";
    repo = "mozc";
    rev = "d703e61";
    sha256 = "sha256-3Vk7+JaUy0F8YSqXZGX56k1tWW827O1ZS0zJdX51kpc=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mozc
    cp src/protocol/config.proto $out/share/mozc/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Protocol Buffers definition for Mozc configuration";
    homepage = "https://github.com/google/mozc";
    license = licenses.bsd3;
    platforms = platforms.all;
  };
}
