let
  roles = {
    scout = {
      model = "deepseek-flash";
      thinking = "low";
      description = "Read-only bounded reconnaissance and evidence handoff";
      body = ./agents/scout.md;
      writer = false;
    };
    implementer-fast = {
      model = "gpt-6-luna";
      thinking = "high";
      description = "Complete scoped implementation with a clear approach";
      body = ./agents/worker.md;
      writer = true;
    };
    implementer-hard = {
      model = "gpt-6.1-sol";
      thinking = "high";
      description = "Difficult debugging, ambiguity, and correctness-sensitive implementation";
      body = ./agents/worker.md;
      writer = true;
    };
    reviewer = {
      model = "gpt-6.1-sol";
      thinking = "xhigh";
      description = "Independent read-only review of a stable final diff";
      body = ./agents/reviewer.md;
      writer = false;
    };
    checker = {
      model = "gpt-6-luna";
      thinking = "minimal";
      description = "Run prescribed non-auto-fix checks on a stable change";
      body = ./agents/checker.md;
      writer = false;
    };
  };
in
  builtins.mapAttrs (name: role: ''
    ---
    name: ${name}
    description: ${role.description}
    model: ${role.model}
    thinking: ${role.thinking}
    tools: read, grep, find, ls, bash, contact_supervisor${
      if role.writer
      then ", edit, write"
      else ""
    }
    systemPromptMode: append
    inheritProjectContext: true
    inheritGlobalContext: true
    inheritSkills: true
    defaultContext: fresh
    async: true
    advertise: true
    allowNestedSubagents: false
    acceptanceRole: ${
      if role.writer
      then "writer"
      else "read-only"
    }
    ---

    ${builtins.readFile role.body}
  '')
  roles
