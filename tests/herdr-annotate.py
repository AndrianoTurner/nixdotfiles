"""Disposable integration checks; arguments: HERDR PLUGIN HM_METADATA_JSON."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time
import tomllib
import unittest

HERDR, PLUGIN, METADATA = sys.argv[1:]
HM = json.loads(Path(METADATA).read_text())
HELPER = Path(__file__).resolve().parents[1] / "modules/home-manager/features/cli/herdr-link.py"
sys.argv = sys.argv[:1]


class AnnotateIntegration(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="herdr-annotate-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.config = self.root / "config"
        self.state = self.root / "state"
        self.registry = self.config / "herdr/plugins.json"
        self.receipt = self.state / "herdr/nix-annotate-root"
        self.env = {k: v for k, v in os.environ.items() if not k.startswith("HERDR_") and k != "DRY_RUN"}
        self.env.update({
            "HOME": str(self.root / "home"),
            "XDG_CONFIG_HOME": str(self.config),
            "XDG_STATE_HOME": str(self.state),
            "XDG_DATA_HOME": str(self.root / "data"),
            "XDG_RUNTIME_DIR": str(self.root / "run"),
            "HERDR_SOCKET_PATH": str(self.root / "herdr.sock"),
        })
        for key in ["HOME", "XDG_RUNTIME_DIR"]:
            Path(self.env[key]).mkdir(mode=0o700)

    def run_command(self, args, *, success=True, env=None):
        result = subprocess.run(args, env=env or self.env, text=True, capture_output=True, timeout=15)
        self.assertEqual(result.returncode == 0, success, result.stdout + result.stderr)
        return result.stdout + result.stderr

    def link(self, plugin=PLUGIN, *, success=True, env=None, herdr=HERDR):
        return self.run_command(
            [sys.executable, str(HELPER), herdr, plugin, str(self.config), str(self.state)],
            success=success, env=env,
        )

    def entries(self):
        return json.loads(self.registry.read_text())

    def write_entries(self, entries):
        self.registry.write_text(json.dumps(entries))

    def test_registration_config_and_repeated_link(self):
        self.link()
        before = self.entries()
        self.link()
        self.assertEqual(before, self.entries())
        self.assertEqual(self.receipt.read_text().strip(), str(Path(PLUGIN).resolve()))
        listed = self.run_command([HERDR, "plugin", "list", "--json", "--plugin", "annotate"])
        self.assertIn("paste-archive", listed)
        shutil.copyfile(HM["config"], self.config / "herdr/config.toml")
        output = self.run_command([HERDR, "config", "check"])
        self.assertNotIn("reserved keybinding", output)
        self.assertNotIn("conflict", output.lower())
        config = tomllib.loads(Path(HM["config"]).read_text())
        self.assertEqual(config["keys"]["prefix"], "ctrl+a")
        self.assertEqual(config["keys"]["detach"], "prefix+d")
        commands = config["keys"]["command"]
        self.assertEqual(len(commands), 9)
        self.assertEqual(len({c["key"] for c in commands}), 9)
        self.assertIn(("prefix+ctrl+y", "annotate.copy-archive"), [(c["key"], c["command"]) for c in commands])
        self.assertNotIn("annotate.send-archive", [c["command"] for c in commands])
        self.assertTrue(all(c["key"] not in ["prefix+o", "prefix+d", "prefix+ctrl+a"] for c in commands))

    def test_server_action_list_and_repeated_online_link(self):
        self.link()
        config = self.config / "herdr/config.toml"
        config.write_text(Path(HM["config"]).read_text() + "\n[update]\nversion_check = false\nmanifest_check = false\n")
        log = self.root / "server.log"
        with log.open("w") as output:
            server = subprocess.Popen([HERDR, "server"], env=self.env, cwd=self.root, stdout=output, stderr=output)
        try:
            deadline = time.monotonic() + 10
            while time.monotonic() < deadline and server.poll() is None:
                result = subprocess.run([HERDR, "plugin", "action", "list", "--plugin", "annotate"], env=self.env, capture_output=True, text=True, timeout=2)
                if result.returncode == 0:
                    break
                time.sleep(0.1)
            else:
                self.fail("Isolated Herdr server did not become ready: " + log.read_text())
            actions = {(a["plugin_id"], a["action_id"]) for a in json.loads(result.stdout)["result"]["actions"]}
            for action in ["capture", "copy-context", "copy-archive", "paste-archive", "manage", "open", "last", "last-newest", "terminal"]:
                self.assertIn(("annotate", action), actions)
            self.link()
            self.link()
        finally:
            try:
                self.run_command([HERDR, "server", "stop"])
                server.wait(timeout=10)
            finally:
                if server.poll() is None:
                    server.kill()
                    server.wait(timeout=5)

    def test_upgrade_rollback_disabled_and_mutable_data(self):
        self.link()
        config_note = self.config / "herdr/plugins/config/annotate/sentinel"
        state_note = self.state / "herdr/plugins/annotate/annotations.jsonl"
        for path in [config_note, state_note]:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("disposable test note\n")
        entries = self.entries()
        entries[0]["enabled"] = False
        self.write_entries(entries)
        upgrade = self.root / "upgraded-plugin"
        shutil.copytree(PLUGIN, upgrade)
        for plugin in [str(upgrade), PLUGIN]:
            self.link(plugin)
            self.assertFalse(self.entries()[0]["enabled"])
            self.assertEqual(self.entries()[0]["plugin_root"], str(Path(plugin).resolve()))
            for path in [config_note, state_note]:
                self.assertEqual(path.read_text(), "disposable test note\n")

    def test_foreign_install_is_not_adopted_even_with_old_receipt(self):
        self.link()
        foreign = self.root / "foreign-plugin"
        shutil.copytree(PLUGIN, foreign)
        self.run_command([HERDR, "plugin", "link", str(foreign)])
        before = self.registry.read_bytes()
        receipt = self.receipt.read_bytes()
        self.assertIn("unmanaged", self.link(success=False))
        self.assertEqual(self.registry.read_bytes(), before)
        self.assertEqual(self.receipt.read_bytes(), receipt)
        self.receipt.unlink()
        self.assertIn("unmanaged", self.link(success=False))
        self.assertEqual(self.registry.read_bytes(), before)

    def test_corrupt_duplicate_or_changed_registration_is_not_replaced(self):
        self.link()
        original = self.entries()
        for contents in ["{", "{}", "[null]", json.dumps(original * 2)]:
            with self.subTest(contents=contents):
                self.registry.write_text(contents)
                self.link(success=False)
                self.assertEqual(self.registry.read_text(), contents)
        for key, value in [("manifest_path", "/foreign/manifest"), ("source", {"kind": "git"}), ("enabled", "yes")]:
            with self.subTest(key=key):
                entries = json.loads(json.dumps(original))
                entries[0][key] = value
                self.write_entries(entries)
                before = self.registry.read_bytes()
                self.link(success=False)
                self.assertEqual(self.registry.read_bytes(), before)

    def test_dry_run_skips_helper_and_actual_activation_entry(self):
        env = {**self.env, "DRY_RUN": "1"}
        self.assertIn("dry run", self.link(plugin="/nonexistent", herdr="/nonexistent", env=env))
        activation = HM["activation"].replace(HM["configHome"], str(self.config)).replace(HM["stateHome"], str(self.state))
        self.assertNotIn(HM["configHome"], activation)
        self.assertNotIn(HM["stateHome"], activation)
        self.assertIn("dry run", self.run_command(["bash", "-c", activation], env=env))
        self.assertFalse(self.registry.exists())
        self.assertFalse(self.receipt.exists())
        self.assertFalse(self.config.exists())
        self.assertFalse(self.state.exists())

    def test_link_failure_is_reported_without_receipt(self):
        output = self.link(herdr="/nonexistent", success=False)
        self.assertIn("Herdr Annotate activation failed", output)
        self.assertFalse(self.receipt.exists())
        self.assertFalse(self.registry.exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
