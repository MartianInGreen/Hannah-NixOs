{ lib
, stdenv
, fetchurl
, dpkg
, makeWrapper
, dotnet-runtime
, autoPatchelfHook
, zlib
, lttng-ust
, icu
, gtk4
, libadwaita
, webkitgtk_6_0
}:

stdenv.mkDerivation rec {
  pname = "devtoys";
  version = "2.0.4.0";

  src = fetchurl {
    url = "https://github.com/DevToys-app/DevToys/releases/download/v${version}/devtoys_linux_x64.deb";
    sha256 = "b29ca658c8f8601ef6c6d20b12fa2b201b42a4542b02870651a73e037f8b36a3";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    dotnet-runtime
    stdenv.cc.cc.lib
    zlib
    lttng-ust
    icu
    gtk4
    libadwaita
    webkitgtk_6_0
  ];

  autoPatchelfIgnoreMissingDeps = [ "liblttng-ust.so.0" ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/devtoys $out/bin $out/share/applications
    cp -r opt/devtoys/* $out/opt/devtoys
    cp -r usr/share/applications/devtoys.desktop $out/share/applications/

    substituteInPlace $out/share/applications/devtoys.desktop \
      --replace "/opt/devtoys/devtoys/DevToys.Linux" "$out/bin/devtoys"

    makeWrapper $out/opt/devtoys/devtoys/DevToys.Linux $out/bin/devtoys \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ stdenv.cc.cc.lib zlib lttng-ust icu gtk4 libadwaita webkitgtk_6_0 ]} \
      --prefix PATH : ${lib.makeBinPath [ dotnet-runtime ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Swiss Army knife for developers";
    homepage = "https://github.com/DevToys-app/DevToys";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ ];
  };
}
