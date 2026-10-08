{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:
stdenvNoCC.mkDerivation rec {
  pname = "agent-browser-bin";
  version = "0.38.2";

  src = fetchurl {
    url = "https://github.com/vercel-labs/agent-browser/releases/download/v${version}/agent-browser-linux-x64";
    hash = "sha256-pUt2UZLbd0Zm8FE/qLVFoph1O28p5zvN9KHnjxjnwOE=";
  };

  nativeBuildInputs = [autoPatchelfHook];
  dontUnpack = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/agent-browser"
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/agent-browser" --version | grep -F "${version}"
    runHook postInstallCheck
  '';

  meta = {
    description = "Browser automation CLI for AI agents (prebuilt binary)";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = lib.licenses.asl20;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    mainProgram = "agent-browser";
    platforms = ["x86_64-linux"];
  };
}
