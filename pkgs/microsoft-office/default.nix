{
  lib,
  stdenvNoCC,
  fetchurl,
  xar,
  gzip,
  cpio,
}:

let
  version = "16.102.25101223";

  src = fetchurl {
    url = "https://officecdnmac.microsoft.com/pr/C1297A47-86C4-4C1F-97FA-950631F94777/MacAutoupdate/Microsoft_365_and_Office_${version}_Installer.pkg";
    sha256 = "sha256-3NBXGkxkHoMcbbMxwTbspRR5ERnB/8MEA8EdeqrZ35U=";
  };

  mkOfficeApp =
    {
      pname,
      appName,
      pkgName,
      meta,
    }:
    stdenvNoCC.mkDerivation {
      inherit pname version src;

      nativeBuildInputs = [
        xar
        gzip
        cpio
      ];

      unpackPhase = ''
        xar -xf $src
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/Applications

        # Extract Main App
        if [ -d "${pkgName}" ]; then
          cd "${pkgName}"
          ${gzip}/bin/zcat Payload | ${cpio}/bin/cpio -id 2>/dev/null
          mv "${appName}" $out/Applications/
          cd ..
        else
          echo "Error: ${pkgName} not found"
          exit 1
        fi

        appPath="$out/Applications/${appName}"

        # Helper function to extract and install components
        install_component() {
          local pkg_dir="$1"
          local dest_dir="$2"
          local pattern="$3"
          
          if [ -d "$pkg_dir" ]; then
            echo "Processing $pkg_dir..."
            cd "$pkg_dir"
            # Extract payload silently
            ${gzip}/bin/zcat Payload | ${cpio}/bin/cpio -id 2>/dev/null
            
            # Find and copy matching files/directories
            mkdir -p "$dest_dir"
            find . -name "$pattern" -print0 | while IFS= read -r -d "" file; do
              cp -R "$file" "$dest_dir/"
            done
            
            # Cleanup extracted files to save space for next steps
            # (We only need to remove the extracted content, not the pkg itself yet)
            # Actually, simpler to just cd back and let the temporary dir be cleaned up at the end
            cd ..
          fi
        }

        # Extract and inject Frameworks
        # We look for any .framework directory inside the payload
        install_component "Office_frameworks.pkg" "$appPath/Contents/Frameworks" "*.framework"
        # Also need to copy dylibs if any are loose (like libmbupdx2009.dylib seen in previous lists)
        if [ -d "Office_frameworks.pkg" ]; then
           cd "Office_frameworks.pkg"
           ${gzip}/bin/zcat Payload | ${cpio}/bin/cpio -id 2>/dev/null
           find . -name "*.dylib" -print0 | while IFS= read -r -d "" file; do
             cp "$file" "$appPath/Contents/Frameworks/"
           done
           cd ..
        fi

        # Extract and inject Proofing Tools
        install_component "Office_proofing.pkg" "$appPath/Contents/SharedSupport/Proofing Tools" "*.proofingtool"

        # Extract and inject Fonts
        # Microsoft Office looks for fonts in Contents/Resources/DFonts
        if [ -d "Office_fonts.pkg" ]; then
          echo "Installing Fonts for ${appName}..."
          cd "Office_fonts.pkg"
          ${gzip}/bin/zcat Payload | ${cpio}/bin/cpio -id 2>/dev/null
          
          mkdir -p "$appPath/Contents/Resources/DFonts"
          find . \( -name "*.ttf" -o -name "*.otf" -o -name "*.ttc" \) -print0 | while IFS= read -r -d "" file; do
            cp "$file" "$appPath/Contents/Resources/DFonts/"
          done
          cd ..
        fi

        runHook postInstall
      '';

      dontFixup = true;

      meta =
        with lib;
        {
          homepage = "https://www.microsoft.com/microsoft-365";
          license = licenses.unfree;
          platforms = platforms.darwin;
          maintainers = with maintainers; [ cffnpwr ];
        }
        // meta;
    };

in
{
  meta = {
    platforms = lib.platforms.darwin;
  };

  word = mkOfficeApp {
    pname = "microsoft-word";
    appName = "Microsoft Word.app";
    pkgName = "Microsoft_Word_Internal.pkg";
    meta.description = "Microsoft Word";
  };

  excel = mkOfficeApp {
    pname = "microsoft-excel";
    appName = "Microsoft Excel.app";
    pkgName = "Microsoft_Excel_Internal.pkg";
    meta.description = "Microsoft Excel";
  };

  powerpoint = mkOfficeApp {
    pname = "microsoft-powerpoint";
    appName = "Microsoft PowerPoint.app";
    pkgName = "Microsoft_PowerPoint_Internal.pkg";
    meta.description = "Microsoft PowerPoint";
  };

  outlook = mkOfficeApp {
    pname = "microsoft-outlook";
    appName = "Microsoft Outlook.app";
    pkgName = "Microsoft_Outlook_Internal.pkg";
    meta.description = "Microsoft Outlook";
  };

  onenote = mkOfficeApp {
    pname = "microsoft-onenote";
    appName = "Microsoft OneNote.app";
    pkgName = "Microsoft_OneNote_Internal.pkg";
    meta.description = "Microsoft OneNote";
  };

  onedrive = mkOfficeApp {
    pname = "microsoft-onedrive";
    appName = "OneDrive.app";
    pkgName = "OneDrive.pkg";
    meta.description = "Microsoft OneDrive";
  };
}
