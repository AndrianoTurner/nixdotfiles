import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { test } from "node:test";

const root = fileURLToPath(new URL("../../../../../..", import.meta.url));
const directory = "modules/home-manager/users/andriano/pi";
const read = (path) => readFileSync(`${root}/${path}`, "utf8");
const generated = JSON.parse(execFileSync("nix", [
  "eval", "--json", "--file", `${directory}/_agents.nix`,
], { cwd: root, encoding: "utf8" }));

// This parser deliberately accepts only the generated scalar frontmatter.
const agents = Object.entries(generated).map(([name, text]) => {
  const match = /^---\n([\s\S]*?)\n---\n([\s\S]*)$/.exec(text);
  assert.ok(match, `${name}: frontmatter`);
  const fields = Object.fromEntries(match[1].split("\n").map((line) => {
    const entry = /^([A-Za-z]+): (.+)$/.exec(line);
    assert.ok(entry, `${name}: scalar field ${line}`);
    return [entry[1], entry[2]];
  }));
  return { name, fields, body: match[2].trim() };
});

const expected = {
  scout: ["deepseek-flash", "low"],
  "implementer-fast": ["gpt-6-luna", "high"],
  "implementer-hard": ["gpt-6.1-sol", "high"],
  reviewer: ["gpt-6.1-sol", "xhigh"],
  checker: ["gpt-6-luna", "minimal"],
};

test("exactly five explicit provider-agnostic roles; no worker alias", () => {
  assert.deepEqual(Object.keys(generated).sort(), Object.keys(expected).sort());
  assert.equal(new Set(agents.map(({ fields }) => fields.name)).size, 5);
  for (const { name, fields } of agents) {
    assert.equal(fields.name, name);
    assert.deepEqual([fields.model, fields.thinking], expected[name]);
    assert.doesNotMatch(fields.model, /[/:]/);
    assert.equal(fields.aliases, undefined);
    assert.ok(fields.description.length > 0);
  }
});

test("roles inherit global/project policy and skills in fresh asynchronous contexts", () => {
  for (const { fields } of agents) {
    assert.equal(fields.systemPromptMode, "append");
    for (const field of ["inheritProjectContext", "inheritGlobalContext", "inheritSkills", "async", "advertise"]) {
      assert.equal(fields[field], "true", field);
    }
    assert.equal(fields.defaultContext, "fresh");
    assert.equal(fields.allowNestedSubagents, "false");
  }
});

test("only implementers can write, and both use the complete shared contract", () => {
  const contract = read(`${directory}/agents/worker.md`).trim();
  for (const { name, fields, body } of agents) {
    const writer = name.startsWith("implementer-");
    const tools = fields.tools.split(", ");
    assert.deepEqual(tools, ["read", "grep", "find", "ls", "bash", "contact_supervisor", ...(writer ? ["edit", "write"] : [])]);
    assert.equal(fields.acceptanceRole, writer ? "writer" : "read-only");
    if (writer) assert.equal(body, contract);
    else assert.match(body, /Do not modify/);
    assert.match(body, /Do not delegate|or delegate/);
    assert.match(body, /Bash|scripts/);
    assert.match(body, /Load the `nix` skill/);
    assert.match(body, /Never use `path:\.`/);
    assert.match(body, /normal, complete prose/);
  }
  assert.match(contract, /Finish all agreed requirements, tests, integration, validation, and error/);
  assert.match(contract, /Inspect your final diff/);
});

test("shared instructions, discoverable skill, and deployment wiring exist", () => {
  const policy = read(`${directory}/AGENTS.md`);
  const skill = read("modules/home-manager/features/cli/pi-skills/nix/SKILL.md");
  assert.match(skill, /^---\nname: nix\ndescription: .+\n---\n/);
  assert.doesNotMatch(skill, /homepc|freedompc/);
  assert.match(policy, /Never use `path:\.`/);
  assert.match(policy, /scripts, nested commands, or delegated children/);
  assert.match(policy, /normal, complete prose/);
  assert.match(policy, /do not silently switch the resolved provider\/model/);
  assert.match(read(`${directory}/APPEND_SYSTEM.md`), /Writing exception:/);
  const module = read(`${directory}/default.nix`);
  assert.match(module, /import \.\/_agents\.nix/);
  assert.match(module, /"\.pi\/agent\/AGENTS\.md"\.source = \.\/AGENTS\.md/);
  assert.doesNotMatch(module, /recursive = true/);
  assert.match(read("modules/home-manager/features/cli/pi.nix"), /\.\/pi-skills\/nix/);
});

// These are static policy coverage checks, not proof of model obedience.
const skill = read("modules/home-manager/features/cli/pi-skills/nix/SKILL.md");
const local = read("AGENTS.md") + read(".pi/skills/nixos-checks/SKILL.md");
for (const [scenario, text, requirements] of [
  ["package build", skill, [/nix build \.#<package>/, /Confirm the output exists/]],
  ["project dev shell", skill, [/nix develop \.#<shell> -c <command>/]],
  ["untracked input", skill, [/Untracked build inputs are invisible/, /ask when staging is not authorized/, /Never stage secrets or unrelated files/]],
  ["path-flake workaround", skill, [/Never use `path:\.`/, /Do not substitute `path:<checkout>`/, /scripts, nested commands, and delegated children/]],
  ["wrong-host build", local, [/only the host you are on \(`homepc`\)/, /unless the user names them/]],
  ["all-host check", local, [/Do not run it by default/, /other hosts'/]],
  ["unauthorized activation", skill + local, [/Activation requires explicit user authorization/, /unless the user explicitly asks/]],
]) {
  test(`command-choice policy: ${scenario}`, () => {
    for (const requirement of requirements) assert.match(text, requirement);
  });
}
