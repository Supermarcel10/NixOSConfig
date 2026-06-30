{ pkgs, deps, wine, wineprefix-preparer }:

pkgs.writeShellApplication {
  name = "setup-on1-photo-raw";
  runtimeInputs = [
    pkgs.unzip
    wine
    wineprefix-preparer
  ];
  text = ''
    if [ $# -ne 1 ]; then
      echo "Usage: setup-on1-photo-raw <path-to-on1-installer.exe>"
      echo ""
      echo "Example:"
      echo "  setup-on1-photo-raw ~/Downloads/ON1_Photo_RAW_2026.4.exe"
      exit 1
    fi

    INSTALLER="$1"
    WINEPREFIX="$HOME/.local/share/on1-photo-raw/wine-prefix"
    WINE="${wine}/bin/wine"

    export WINEPREFIX
    export WINE

    if [ ! -f "$INSTALLER" ]; then
      echo "Error: Installer not found: $INSTALLER"
      exit 1
    fi

    if [ -d "$WINEPREFIX" ]; then
      echo "WARNING: A Wine prefix already exists at $WINEPREFIX"
      echo "If a previous setup failed, you should delete it first:"
      echo "  rm -rf \"$WINEPREFIX\""
      echo ""
      read -p "Continue anyway? [y/N] " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
      fi
    fi

    echo "Creating Wine prefix at $WINEPREFIX..."
    mkdir -p "$WINEPREFIX"

    echo "Initializing Wine prefix (this may take a moment)..."
    "$WINE" wineboot --init

    echo "Waiting for Wine prefix to be ready..."
    for i in {1..30}; do
      if "$WINE" cmd.exe /c echo '%AppData%' >/dev/null 2>&1; then
        echo "Prefix is ready."
        break
      fi
      echo "  ($i/30) Still initializing..."
      sleep 2
    done

    if ! "$WINE" cmd.exe /c echo '%AppData%' >/dev/null 2>&1; then
      echo "Error: Wine prefix failed to initialize. Try deleting it and retrying:"
      echo "  rm -rf \"$WINEPREFIX\""
      exit 1
    fi

    echo "Preparing prefix with DXVK/VKD3D-Proton..."
    wineprefix-preparer

    echo "Re-initializing prefix after wineserver restart..."
    "$WINE" wineboot --init
    sleep 2
    for i in {1..30}; do
      if "$WINE" cmd.exe /c echo '%AppData%' >/dev/null 2>&1; then
        echo "Prefix is ready."
        break
      fi
      echo "  ($i/30) Waiting for prefix to be ready after wineserver restart..."
      sleep 2
    done

    if ! "$WINE" cmd.exe /c echo '%AppData%' >/dev/null 2>&1; then
      echo "Error: Wine prefix failed to re-initialize after wineserver restart."
      exit 1
    fi

    echo "Setting up WinMetadata..."
    mkdir -p "$WINEPREFIX/drive_c/windows/system32/WinMetadata"
    unzip -j -q -o "${deps.winMetadata}" -d "$WINEPREFIX/drive_c/windows/system32/WinMetadata"

    echo "Installing Visual C++ Redistributable 2022 (x64)..."
    "$WINE" "${deps.vcrun2022_x64}" /install /quiet /norestart || true

    echo "Installing Visual C++ Redistributable 2022 (x86)..."
    "$WINE" "${deps.vcrun2022_x86}" /install /quiet /norestart || true

    echo "Setting Windows version to 11..."
    "$WINE" reg add 'HKEY_CURRENT_USER\Software\Wine' /v Version /d 'win11' /f
    "$WINE" reg add 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' /v CurrentVersion /d '10.0' /f
    "$WINE" reg add 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' /v CurrentBuild /d '22000' /f
    "$WINE" reg add 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' /v ProductName /d 'Windows 11' /f

    echo "Installing ON1 Photo RAW 2026.4..."
    "$WINE" "$INSTALLER" TargetDir="C:\Program Files\ON1\ON1 Photo RAW 2026.4"

    echo ""
    echo "Setup complete! You can now launch ON1 Photo RAW with:"
    echo "  on1-photo-raw"
  '';
}
