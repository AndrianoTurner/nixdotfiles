{...}: let
  readOnlyPermissions = ''
    permission:
      "*": ask
      read: allow
      grep: allow
      find: allow
      ls: allow
      edit: deny
      write: deny
      bash:
        "*": ask
        "git status*": allow
        "git diff*": allow
        "git log*": allow
        "git show*": allow
        "git rev-parse*": allow
      external_directory:
        "*": deny
  '';

  checker = ''
    ---
    description: Run project checks with GPT-5.6 Luna
    tools: read, grep, find, ls, bash
    extensions: pi-permission-system
    skills: false
    thinking: minimal
    max_turns: 20
    run_in_background: true
    prompt_mode: append
    ${readOnlyPermissions}---

    You are the final verification agent. Inspect the repository instructions and
    the current working-tree diff, then identify and run the canonical checks that
    apply to the change. Do not modify source files or configuration. Report every
    command executed, its result, relevant diagnostics, and any validation that
    could not be performed. Finish with exactly CHECKS_PASSED or CHECKS_FAILED.
  '';

  reviewer = ''
    ---
    description: Review code with GPT-5.6 Sol
    tools: read, grep, find, ls, bash
    extensions: pi-permission-system
    skills: false
    thinking: xhigh
    max_turns: 30
    run_in_background: true
    prompt_mode: append
    ${readOnlyPermissions}---

    You are the final code-review agent. Inspect the current working-tree diff and
    enough surrounding code to evaluate correctness, regressions, security,
    maintainability, and missing tests. Do not modify files. Report only actionable
    findings, ordered by severity, with file paths and line numbers. Finish with
    exactly APPROVED or CHANGES_REQUESTED.
  '';
in {
  programs.pi.coding-agent.rules = ''
    For every task that changes source code or configuration, use the local parent
    model for implementation, then run the following independent final gate:

    1. Spawn `gpt-checker` with the explicit model parameter
       `openai-codex/gpt-5.6-luna`.
    2. Spawn `gpt-reviewer` with the explicit model parameter
       `openai-codex/gpt-5.6-sol`.
    3. Start both agents in parallel and wait for both results before completing.
       Never omit or substitute either explicit model parameter. The agent files
       intentionally do not pin a model so unavailable OAuth/model access fails
       instead of silently falling back to the local parent model.
    4. Fix all failed required checks and all actionable correctness, security,
       regression, and test-coverage findings. Minor style suggestions are optional
       when they are not required by repository conventions.
    5. If the fixes changed source or configuration, run both agents once more with
       the same explicit models. Do not start a third review cycle. Report remaining
       failures or findings and do not claim success while required checks fail or
       the reviewer returns CHANGES_REQUESTED.

    Do not invoke this gate for read-only questions, explanations, or planning that
    produces no source or configuration changes. The parent may run focused checks
    while implementing, but the GPT checker owns final validation. GPT agents must
    only inspect and report; they must never edit the working tree.
  '';

  home.file = {
    ".pi/agent/agents/gpt-checker.md".text = checker;
    ".pi/agent/agents/gpt-reviewer.md".text = reviewer;
    ".pi/agent/subagents.json".text = builtins.toJSON {
      maxConcurrent = 2;
      defaultJoinMode = "group";
      scopeModels = true;
      toolDescriptionMode = "compact";
    };
  };
}
