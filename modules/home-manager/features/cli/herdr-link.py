"""Register the Nix-built plugin without adopting unrelated user installations."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile


def link(herdr, plugin, config_home, state_home):
    if os.environ.get("DRY_RUN"):
        print("Would link Nix-managed Herdr Annotate (dry run).")
        return

    root = str(Path(plugin).resolve(strict=True))
    registry = Path(config_home) / "herdr/plugins.json"
    receipt = Path(state_home) / "herdr/nix-annotate-root"

    def registration():
        entries = json.loads(registry.read_text()) if registry.exists() or registry.is_symlink() else []
        if not isinstance(entries, list) or any(not isinstance(e, dict) for e in entries):
            raise ValueError("invalid Herdr plugin registry")
        matches = [e for e in entries if e.get("plugin_id") == "annotate"]
        if len(matches) > 1:
            raise ValueError("duplicate Annotate registrations")
        return matches[0] if matches else None

    current = registration()
    enabled = True
    if current is not None:
        previous = receipt.read_text().strip() if receipt.exists() else None
        old_root = current.get("plugin_root")
        if (
            not isinstance(old_root, str)
            or old_root not in (root, previous)
            or current.get("manifest_path") != old_root + "/herdr-plugin.toml"
            or current.get("source") != {"kind": "local"}
            or not isinstance(current.get("enabled"), bool)
        ):
            raise ValueError(
                "refusing to replace an unmanaged Annotate installation; "
                "inspect it and explicitly unlink it before activating again"
            )
        enabled = current["enabled"]

    # Herdr owns locking and registry writes. Do not run plugin management concurrently.
    subprocess.run(
        [herdr, "plugin", "link", root, "--enabled" if enabled else "--disabled"],
        check=True,
        env={**os.environ, "XDG_CONFIG_HOME": config_home, "XDG_STATE_HOME": state_home},
    )
    linked = registration()
    if (
        linked is None
        or linked.get("plugin_root") != root
        or linked.get("manifest_path") != root + "/herdr-plugin.toml"
        or linked.get("enabled") is not enabled
    ):
        raise ValueError("Herdr did not persist the expected Annotate registration")

    receipt.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=".nix-annotate-root-", dir=receipt.parent)
    try:
        with os.fdopen(fd, "w") as handle:
            handle.write(root + "\n")
        os.replace(temporary, receipt)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


if __name__ == "__main__":
    try:
        link(*sys.argv[1:])
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        sys.exit(f"Herdr Annotate activation failed: {error}")
