{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  gh,
  gitMinimal,
  makeWrapper,
  nodejs_22,
  openssh,
}:
buildNpmPackage rec {
  pname = "agent-office";
  version = "0.1.99";

  src = fetchFromGitHub {
    owner = "AgentSystemLabs";
    repo = "agent-office";
    tag = "v${version}";
    hash = "sha256-MLIklRjzy38jU5xRtbTrSKSF7Jdd2kD0amtzkOsTl8w=";
  };

  npmDepsHash = "sha256-xzGP/vBQ1nkedYFdTQ87Ou6+Fu/AtLu8VNTZiCQHRms=";

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall

    installRoot="$out/lib/node_modules/${pname}"
    mkdir -p "$installRoot" "$out/bin"
    cp -r dist node_modules package.json bin "$installRoot/"
    makeWrapper ${nodejs_22}/bin/node "$out/bin/agent-office" \
      --add-flags "$installRoot/bin/agent-office.js" \
      --prefix PATH : ${lib.makeBinPath [gitMinimal gh openssh]}

    runHook postInstall
  '';

  meta = {
    description = "A 3D office shared by teams and their coding agents";
    homepage = "https://github.com/AgentSystemLabs/agent-office";
    license = lib.licenses.mit;
    mainProgram = "agent-office";
    platforms = lib.platforms.linux;
  };
}
