{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  makeWrapper,
  icu,
  openssl,
  fontconfig,
  libX11,
  libICE,
  libSM,
  libXext,
  libXi,
  libXrender,
  libxcb,
  zlib,
  lttng-ust_2_12,
}:
stdenv.mkDerivation rec {
  pname = "ilspy";

  releaseTag = "v11.0-rc";
  version = "11.0.0.9335-rc";

  src = fetchzip {
    url = "https://github.com/icsharpcode/ILSpy/releases/download/${releaseTag}/ILSpy_linux-x64_${version}.zip";
    hash = "sha256-AOYZO7N+BDQNZE7x5ZzNU8UffGQ1GZte5ySsNSgmIig=";
    stripRoot = false;
  };

  dontStrip = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    icu
    openssl
    fontconfig
    libX11
    libICE
    libSM
    libXext
    libXi
    libXrender
    libxcb
    zlib
    (lib.getLib lttng-ust_2_12)
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/ilspy $out/bin
    cp -r ./* $out/lib/ilspy/

    chmod +x $out/lib/ilspy/ILSpy
    makeWrapper $out/lib/ilspy/ILSpy $out/bin/ilspy \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
      icu
      openssl
      fontconfig
      libX11
      libICE
      libSM
      libXext
      libXi
      libXrender
      libxcb
      zlib
      lttng-ust_2_12
    ]}

    runHook postInstall
  '';

  meta = {
    description = "ILSpy .NET assembly browser and decompiler";
    homepage = "https://github.com/icsharpcode/ILSpy";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux"];
    mainProgram = "ilspy";
  };
}
