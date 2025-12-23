{
  spotify,
  stdenv,
  fetchurl,
}:

# Fix hash mismatch for Darwin Spotify packages
# Aligns with upstream PR: https://github.com/NixOS/nixpkgs/pull/470535
# Updates to version 1.2.78.418 with corrected Wayback Machine URLs
if stdenv.hostPlatform.isDarwin then
  spotify.overrideAttrs (oldAttrs: {
    version = "1.2.78.418";

    src =
      if stdenv.hostPlatform.isAarch64 then
        fetchurl {
          url = "https://web.archive.org/web/20251212105149/https://download.scdn.co/SpotifyARM64.dmg";
          hash = "sha256-/rrThZOpjzaHPX1raDe5X8PqtJeTI4GDS5sXSfthXTQ=";
        }
      else
        fetchurl {
          url = "https://web.archive.org/web/20251212105140/https://download.scdn.co/Spotify.dmg";
          hash = "sha256-N2tQTS9vHp93cRI0c5riVZ/8FSaq3ovDqh5K9aU6jV0=";
        };
  })
else
  # For Linux platforms (x86_64-linux, aarch64-linux),
  # use the original package from nixpkgs (fetched from Snapcraft)
  spotify
