# Herdr Annotate

Annotate Full is Nix-managed: plugin commit `a9973b43c1fc90044a9f15755e310e12b8465abb`
(manifest 0.9.9), annotation runtime 0.2.3, and plannotator-tui 0.9.9.
`pkgs/herdr-annotate/default.nix` pins all downloads by hash, patches the Linux
executables for NixOS, and removes upstream download hooks. Normal builds and
registration do not download anything; only Nix's fixed-output fetchers do.

## Keys

Press **Ctrl+A**, release it, then press the second key below.

| Second key | Action |
| --- | --- |
| `a` | Annotate selected/copied text |
| `Shift+A` | Copy annotations as context |
| `Ctrl+Y` | Copy annotations, then archive |
| `Ctrl+V` | Paste into the focused prompt **without submitting**, then archive |
| `m` | Manage notes and archives |
| `Ctrl+D` | Review documents in the focused folder |
| `Shift+O` | Choose a recent Pi reply to review |
| `Ctrl+O` | Review the newest reply |
| `t` | Review recent terminal output |

`Ctrl+A, d` still detaches; `Ctrl+A, o` still opens the notification target.
Herdr reserves `Ctrl+A, Ctrl+A` for a literal Ctrl+A, so copy-and-archive uses
Ctrl+Y instead. These bindings were checked against Herdr 0.9.5's inherited
defaults, not just this module's explicit settings. Direct send-and-archive
remains unbound: inspect pasted feedback before submitting it. Other upstream
actions remain available through Herdr's plugin action interface.

Native reviews supplement the existing external Plannotator browser approval
flow. Browser integration, Alacritty, Pi configuration, and session/model handoff
are unchanged; no embedded browser or Kitty graphics is required.

## Activation, updates, and removal

Building does not activate anything. At the next **user-triggered** Home Manager
activation, the configured Herdr binary links the immutable store directory after
the write boundary. Dry runs skip linking and all writes. Herdr continues to own
the mutable registry, plugin configuration, and notes.

The helper in `modules/home-manager/features/cli/herdr-link.py` accepts an absent
registration, the exact current package path, or the exact previously managed
path recorded in `$XDG_STATE_HOME/herdr/nix-annotate-root`. It preserves a disabled
registration and writes that receipt only after a verified successful link.
Malformed registries, duplicate registrations, foreign paths, or unexpected
metadata fail activation instead of being silently replaced. Inspect a foreign
installation and explicitly unlink it if you want Nix to replace it. Do not run
plugin-management commands concurrently with activation: Herdr's link operation
has no compare-and-swap ownership guard.

Update the source/release pins and hashes in `pkgs/herdr-annotate/default.nix`,
rebuild, then activate when ready. Do **not** use `herdr plugin update annotate`;
Nix owns these files. A managed rollback relinks the older package without deleting
notes. Removing the module alone does not unregister the mutable link. Before
removal, with a Herdr server running, run:

```console
herdr plugin unlink annotate
```

Unlinking preserves configuration and notes; already-running plugin panes should
be closed separately. Unlink before removing the package or garbage-collecting
its old store path to avoid a dangling registration.

## State and privacy

With default XDG paths:

- Registry: `~/.config/herdr/plugins.json` (not an immutable Home Manager file).
- Plugin settings: `~/.config/herdr/plugins/config/annotate/`.
- Notes and archives: `~/.local/state/herdr/plugins/annotate/`, including
  `annotations.jsonl` and `archives.jsonl`.
- Management receipt: `~/.local/state/herdr/nix-annotate-root`.

Back up notes as user data. They and the clipboard can contain sensitive terminal
output; never capture credentials or secrets. Plugins run unsandboxed as your
user. The existing desktop `wl-clipboard` supplies clipboard support. This setup
targets the local desktop; upstream SSH selection limitations remain.

## Verification

From the repository root, build only this host; none of these commands activates:

```sh
nix build .#herdr-annotate
nix build .#checks.x86_64-linux.format
nix eval .#nixosConfigurations.homepc.config.system.build.toplevel.drvPath
nix build .#nixosConfigurations.homepc.config.system.build.toplevel --no-link
```

To repeat the isolated integration checks (Python 3.11+), keep the evaluated
metadata outside the repository. The tests create private HOME/XDG directories
and socket paths, start and stop their own headless server, and never register a
plugin in the live user's registry:

```sh
work=$(mktemp -d)
plugin=$(nix build .#herdr-annotate --no-link --print-out-paths)
nix build '.#nixosConfigurations.homepc.config.home-manager.users.andriano.xdg.configFile."herdr/config.toml".source' --no-link
nix eval --json .#nixosConfigurations.homepc.config.home-manager.users.andriano \
  --apply 'hm: {
    activation = hm.home.activation.herdrAnnotate.data;
    config = toString hm.xdg.configFile."herdr/config.toml".source;
    configHome = hm.xdg.configHome;
    stateHome = hm.xdg.stateHome;
  }' > "$work/hm.json"
herdr=$(nix eval --raw .#nixosConfigurations.homepc.config.home-manager.users.andriano.home.packages \
  --apply 'ps: toString (builtins.head (builtins.filter (p: (p.pname or "") == "herdr") ps))')
python3 tests/herdr-annotate.py "$herdr/bin/herdr" "$plugin" "$work/hm.json"
rm -r "$work"
```

Package install checks cover both executable versions, launcher execution,
permissions, version stamps, manifest actions, and the absence of build hooks.
Integration tests cover offline/online repeated linking, action discovery,
generated config validation, dry runs, disabled-state preservation, managed
upgrades/rollback, foreign-install refusal, malformed registries, link errors,
and preservation of disposable settings/notes.

### Manual checks — pending

After applying the configuration yourself, use non-sensitive sample text and a
disposable Pi conversation to check:

- Selection capture; manager editing and archive/restore.
- Markdown/document review and recent/newest Pi reply review.
- Terminal-output review.
- Paste-and-archive inserts feedback but does not submit it; submit only after inspection.
- Existing Plannotator browser approvals and session/model handoff still work.

These interactive checks have not been exercised by the automated verification.
