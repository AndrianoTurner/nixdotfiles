{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  stdenv,
  bash,
  coreutils,
  python3,
}: let
  runtimeVersion = "0.2.3";
  tuiVersion = "0.9.9";
  runtime = fetchurl {
    url = "https://github.com/plannotator/herdr-annotate/releases/download/rust-lite-v${runtimeVersion}/herdr-annotate-x86_64-unknown-linux-gnu";
    hash = "sha256-BwNNKvDqHeEom+luWQy3XjF9TVmypjD74nrVxl9JnYE=";
  };
  tui = fetchurl {
    url = "https://github.com/plannotator/plannotator-tui/releases/download/v${tuiVersion}/plannotator-tui-x86_64-unknown-linux-gnu";
    hash = "sha256-BtQD4HQrWq8Wo0G6AQT4uFTx8K4TO3D2PRGICxSNThg=";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "herdr-annotate";
    version = "0.9.9";

    src = fetchurl {
      url = "https://codeload.github.com/plannotator/herdr-annotate/tar.gz/a9973b43c1fc90044a9f15755e310e12b8465abb";
      name = "herdr-annotate-source.tar.gz";
      hash = "sha256-R0MdqkoKdm5cFCrbBnEGkQmBmszhKY1Yh13WHzvqn5I=";
    };

    nativeBuildInputs = [autoPatchelfHook python3];
    buildInputs = [stdenv.cc.cc.lib];
    dontStrip = true;

    postPatch = ''
      # Registration must never run upstream's network-enabled download hooks.
      python3 - <<'PY'
      from pathlib import Path
      import re
      path = Path("herdr-plugin.toml")
      text = re.sub(r'\[\[build\]\]\n.*?(?=\n\[\[|\Z)', "", path.read_text(), flags=re.S)
      path.write_text(text)
      PY
      substituteInPlace herdr-plugin.toml \
        --replace-fail 'command = ["sh", "-c", "exec bash \"$HERDR_PLUGIN_ROOT/scripts/plannotator-tui.sh\" herdr pane"]' \
          'command = ["${bash}/bin/bash", "${placeholder "out"}/scripts/plannotator-tui.sh", "herdr", "pane"]'
      substituteInPlace scripts/plannotator-tui.sh \
        --replace-fail '$(dirname "$0")' '$(${coreutils}/bin/dirname "$0")'
      patchShebangs scripts/plannotator-tui.sh
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/scripts" "$out/bin"
      cp herdr-plugin.toml LICENSE README.md "$out/"
      install -m755 scripts/plannotator-tui.sh "$out/scripts/"
      install -m755 ${runtime} "$out/bin/herdr-annotate.exe"
      install -m755 ${tui} "$out/bin/plannotator-tui.exe"
      cp herdr-annotate.version plannotator-tui.version "$out/"
      cp herdr-annotate.version plannotator-tui.version "$out/bin/"
      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      "$out/bin/herdr-annotate.exe" --version | grep -Fx 'herdr-annotate ${runtimeVersion}'
      "$out/bin/plannotator-tui.exe" --version | grep -Fx 'plannotator-tui ${tuiVersion}'
      "$out/scripts/plannotator-tui.sh" --version | grep -Fx 'plannotator-tui ${tuiVersion}'
      python3 - <<'PY'
      import os
      from pathlib import Path
      import tomllib
      root = Path(os.environ["out"])
      manifest = tomllib.loads((root / "herdr-plugin.toml").read_text())
      assert manifest["id"] == "annotate" and manifest["version"] == "0.9.9"
      assert "build" not in manifest
      assert {"capture", "copy-context", "copy-archive", "paste-archive", "manage",
              "open", "last", "last-newest", "terminal"} <= {a["id"] for a in manifest["actions"]}
      for name, version in [("herdr-annotate", "${runtimeVersion}"), ("plannotator-tui", "${tuiVersion}")]:
          assert os.access(root / "bin" / (name + ".exe"), os.X_OK)
          for directory in [root, root / "bin"]:
              assert (directory / (name + ".version")).read_text().strip() == version
      assert os.access(root / "scripts/plannotator-tui.sh", os.X_OK)
      for entry in manifest["actions"] + manifest["panes"]:
          program = entry["command"][0]
          path = root / program if program.startswith("./") else Path(program)
          assert path.is_absolute() and os.access(path, os.X_OK), path
      PY
      runHook postInstallCheck
    '';

    meta = {
      description = "Annotate Full plugin for Herdr with native annotation and review runtimes";
      homepage = "https://github.com/plannotator/herdr-annotate";
      license = lib.licenses.mit;
      sourceProvenance = [lib.sourceTypes.fromSource lib.sourceTypes.binaryNativeCode];
      platforms = ["x86_64-linux"];
    };
  }
