import assert from "node:assert/strict";
import { test } from "node:test";

const current = { provider: "test", id: "planner", name: "Planner" };
const cheap = { provider: "test", id: "worker", name: "Worker" };
const strong = { provider: "other", id: "worker", name: "Stronger worker" };
let caseId = 0;

async function harness({ answers = [], available = [current, cheap, strong], switchFails = false, cancelSession = false, mode = "tui" } = {}) {
  const { default: extension } = await import(`../extensions/plannotator-handoff.ts?case=${caseId++}`);
  const notifications = [];
  const selections = [];
  const calls = [];
  const prompts = [];
  let hooks;
  let approval;
  let command;
  let activeTools = ["plannotator_submit_plan"];
  let model = current;
  let thinking = "high";
  let generation = 0;
  let sessions = 0;
  const ctx = {
    mode,
    get model() { return model; },
    modelRegistry: {
      getAvailable: () => available,
      find: (provider, id) => available.find((item) => item.provider === provider && item.id === id),
    },
    ui: {
      notify: (message, level) => notifications.push({ message, level }),
      select: async (title, options) => {
        selections.push({ title, options });
        const answer = answers.shift();
        return typeof answer === "number" ? options[answer] : answer;
      },
    },
    sessionManager: { getSessionFile: () => "parent.jsonl" },
    sendUserMessage: async (prompt, options) => prompts.push({ prompt, options }),
    newSession: async ({ parentSession, withSession }) => {
      assert.equal(parentSession, "parent.jsonl");
      sessions++;
      if (cancelSession) return { cancelled: true };
      install();
      await hooks.session_start({}, ctx);
      await withSession(ctx);
      return { cancelled: false };
    },
  };
  function install() {
    const ownGeneration = ++generation;
    hooks = {};
    const assertFresh = () => assert.equal(ownGeneration, generation, "must use the replacement Pi instance");
    extension({
      on: (name, handler) => { hooks[name] = handler; },
      events: { on: (_name, handler) => { approval = handler; } },
      registerCommand: (_name, definition) => { command = definition.handler; },
      getActiveTools: () => activeTools,
      getThinkingLevel: () => thinking,
      setThinkingLevel: (level) => {
        assertFresh();
        calls.push(["thinking", level]);
        thinking = level;
      },
      setModel: async (selected) => {
        assertFresh();
        calls.push(["model", selected]);
        if (switchFails) return false;
        model = selected;
        return true;
      },
      sendUserMessage: (text, options) => {
        assertFresh();
        assert.equal(text, "/plannotator-new-session");
        assert.equal(options.expandPromptTemplates, true);
      },
    });
  }
  install();
  return {
    calls, notifications, selections, prompts,
    get sessions() { return sessions; },
    guide() {
      const event = { systemPromptOptions: { sections: { existing: "Keep this" } } };
      hooks.before_agent_start(event, ctx);
      return event.systemPromptOptions.sections;
    },
    disablePlanning() { activeTools = []; },
    async approve(planContent = "Implementation model: test/worker\nRoutine edits.") {
      approval({ cwd: "/project", planFilePath: "PLAN.md", planContent, feedback: "Keep tests" });
      await command("", ctx);
    },
    async restart() {
      install();
      await hooks.session_start({}, ctx);
    },
  };
}

test("planning guidance lists available models and leaves unrelated prompt sections intact", async () => {
  const h = await harness({ available: [cheap] });
  assert.equal(h.guide().existing, "Keep this");
  assert.match(h.guide().plannotator_implementation_model, /Implementation model: provider\/model-id/);
  assert.match(h.guide().plannotator_implementation_model, /test\/worker \(Worker\)/);
  assert.doesNotMatch(h.guide().plannotator_implementation_model, /test\/planner/);
  h.disablePlanning();
  assert.equal(h.guide().plannotator_implementation_model, undefined);
});

test("recommendation is first; replacement model is set before thinking and implementation", async () => {
  const h = await harness({ answers: [0, "medium"] });
  await h.approve("Implementation model: `test/worker`\r\nRoutine edits.");
  assert.equal(h.selections[0].options[0], "test/worker (Recommended)");
  assert.deepEqual(h.calls, [["model", cheap], ["thinking", "medium"]]);
  assert.equal(h.prompts.length, 1);
  assert.match(h.prompts[0].prompt, /Reviewer notes:\nKeep tests/);
  assert.equal(h.prompts[0].options.expandPromptTemplates, false);
});

test("user can override the recommendation with another provider's model", async () => {
  const h = await harness({ answers: ["other/worker", 0] });
  await h.approve();
  assert.deepEqual(h.calls, [["model", strong], ["thinking", "high"]]);
  assert.equal(h.prompts.length, 1);
});

test("user can inherit the current model instead of the recommendation", async () => {
  const h = await harness({ answers: [1, 0] });
  await h.approve();
  assert.deepEqual(h.calls, [["model", current], ["thinking", "high"]]);
});

test("unavailable recommendation warns and falls back to inheriting current model", async () => {
  const h = await harness({ answers: [0, 0] });
  await h.approve("Implementation model: missing/model");
  assert.match(h.selections[0].options[0], /^Inherit current/);
  assert.ok(h.notifications.some(({ level }) => level === "warning"));
  assert.deepEqual(h.calls[0], ["model", current]);
});

test("old plans without a recommendation still offer a model picker", async () => {
  const h = await harness({ answers: ["test/worker", 0] });
  await h.approve("# Old plan\n- [ ] Implement it");
  assert.ok(h.selections[0].options.includes("test/worker"));
  assert.equal(h.notifications.some(({ level }) => level === "warning"), false);
  assert.deepEqual(h.calls[0], ["model", cheap]);
});

for (const answers of [[undefined], [0, undefined]]) {
  test(`cancelling picker ${answers.length} leaves the session unchanged`, async () => {
    const h = await harness({ answers });
    await h.approve();
    assert.equal(h.sessions, 0);
    assert.deepEqual(h.calls, []);
    assert.deepEqual(h.prompts, []);
  });
}

test("cancelled session replacement clears pending settings", async () => {
  const h = await harness({ answers: [0, "low"], cancelSession: true });
  await h.approve();
  await h.restart();
  assert.deepEqual(h.calls, []);
  assert.deepEqual(h.prompts, []);
});

test("failed model switch does not start implementation or leak into another session", async () => {
  const h = await harness({ answers: [0, "low"], switchFails: true });
  await h.approve();
  assert.deepEqual(h.prompts, []);
  assert.ok(h.notifications.some(({ level }) => level === "error"));
  const callCount = h.calls.length;
  await h.restart();
  assert.equal(h.calls.length, callCount);
});

test("non-interactive handoffs do not prompt or replace sessions", async () => {
  const h = await harness({ mode: "print" });
  await h.approve();
  assert.deepEqual(h.selections, []);
  assert.equal(h.sessions, 0);
});
