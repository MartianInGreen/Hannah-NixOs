{ appimageTools, fetchurl, makeDesktopItem, lib }:
let
  pname = "waveterm";
  version = "0.7.6";

  src = fetchurl {
    url = "https://github.com/wavetermdev/waveterm/releases/download/v${version}/Wave-linux-x86_64-${version}.AppImage";
    sha256 = "25a7051b68c184bbe5fa13241d01be55f2a80c97757205364b782496849e8790";
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    # icon = fetchurl {
    #   url = "https://github.com/wavetermdev/waveterm/blob/main/public/logos/wave-logo.png";
    #   sha256 = "aa86f6effeb80bd5cf06d5e0871839fe0d2a45a88e50ea6e1582f59fbfda101d"; # Replace with actual sha256
    # };
    desktopName = "Waveterm";
    genericName = "Terminal Emulator";
    categories = [ "System" "TerminalEmulator" ];
  };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications
  '';
  meta = with lib; {
    description = "A terminal for the 21st century";
    homepage = "https://www.waveterm.dev/";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ "MartianHannah" ];
  };
}