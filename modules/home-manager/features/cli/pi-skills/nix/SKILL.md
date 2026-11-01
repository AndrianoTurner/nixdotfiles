---
name: nix
description: Choose safe, narrow Nix commands for flakes, packages, checks, and dev shells. Load before any Nix operation; follow repository-local host, staging, and activation rules.
---

# Nix operations

1. Identify the repository and flake root, Git status, local instructions, and
   intended package, app, check, or dev shell before choosing a command.
2. Never use `path:.` for the local checkout in any operation, including
   `nix run/build/develop`, `nix eval`, `nix flake check`, and lock operations.
   Do not substitute `path:<checkout>` or another explicit path-flake workaround.
   This also applies to scripts, nested commands, and delegated children.
3. For a Git-backed local flake, use the repository's canonical Git-flake
   command and intended attribute, for example `nix build .#<package>` or
   `nix develop .#<shell> -c <command>`. Confirm the output exists; do not invent
   names or assume every flake provides every output type.
4. Git flakes still copy selected source into the store; they do not mean zero
   copying. Explicit path flakes can include ignored/untracked material and
   cause unexpectedly broad copies.
5. Untracked build inputs are invisible to Git flakes. Identify only task-owned
   inputs and follow local staging rules, or ask when staging is not authorized.
   Never stage secrets or unrelated files. Never use a path flake to work around
   missing inputs.
6. Distinguish evaluation, package builds, dev environments, execution, and
   NixOS activation. A build is not activation. `nix run` can execute side effects
   and is not a generic validation command.
7. Prefer the narrow documented check. Do not broaden to every host/system,
   rewrite locks, enable impurity, or activate the system as an improvised fix.
   For NixOS, obtain host selection and canonical commands from local
   instructions; do not carry one repository's host policy into another.
8. Inspect failure causes before retrying. If targets are missing/ambiguous or
   non-Git sources are required, explain the blocker instead of inventing a
   copying workaround. Report executed checks separately from proposed/skipped
   checks. Activation requires explicit user authorization.
