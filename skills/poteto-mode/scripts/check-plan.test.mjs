import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import test from 'node:test';

const root = path.resolve(import.meta.dirname, '../../../..');
const script = path.join(import.meta.dirname, 'check-plan.mjs');
const plan = `# Minimal program

One unit checks a background heartbeat.

## How to read this

One box is one unit of work. Every box names the evidence that checks it. Check a box only when its evidence exists.
The program runs .agents/skills/poteto-mode/playbooks/autonomous-run.md.
Tests alone are not sufficient verification. A change is verified only when its unit, live, and perf boxes are all checked.

## Program checklist

### Arm the program

- [ ] Arm the 50-minute tick with a background \`sleep 3000\`.
- [ ] Read \`git show main:.agents/skills/poteto-mode/playbooks/autonomous-run.md\`.
- [ ] Post a status message when the tick finds a change.

### Spawn owners

- [ ] Start one owner.

### Landing mechanics

- [ ] Run the checks.

### Verdict and merge

- [ ] Merge after the verdict.

### Boot recipe

- [ ] Start the lane.

## Check the heartbeat (WAKE)

**Depends on.** None.

**Files.**

- [ ] Edit the heartbeat.

**Build.**

- [ ] Arm the background sleep.

**You see.**

- [ ] A tick wakes the session.

**Verify, unit.** Tests alone are not sufficient verification. A change is verified only when its unit, live, and perf boxes are all checked.

- [ ] Run the heartbeat test.

**Verify, live.** Tests alone are not sufficient verification. A change is verified only when its unit, live, and perf boxes are all checked. Four lanes on \`gpt-6.1-sol\` at the unit's head commit.

- [ ] Lane 1. Check the first tick. Save \`first.png\`. Pass when the row exists.
- [ ] Lane 2. Check re-arming. Save \`rearm.png\`. Pass when the next tick runs.
- [ ] Lane 3. Check waiting. Save \`waiting.png\`. Pass when the heartbeat stops.
- [ ] Lane 4. Check resuming. Save \`resume.png\`. Pass when the heartbeat restarts.

**Verify, perf.** Tests alone are not sufficient verification. A change is verified only when its unit, live, and perf boxes are all checked.

- [ ] Metric. Tick duration.
- [ ] Probe. Time one tick.
- [ ] Baseline. Record trunk first.
- [ ] Rule. Finish within the interval.

**Review gate.** None. WAKE is not review-gated.

**Merge.**

- [ ] Merge after a clean verdict.

## Close the program

- [ ] Every box has evidence.

## Appendix A. Prototype evidence

The first tick wrote its row.
`;

function check(file) {
  return spawnSync(process.execPath, [script, file], { cwd: root, encoding: 'utf8' });
}

function checkFixture(t, text) {
  const folder = mkdtempSync(path.join(tmpdir(), 'check-plan-'));
  t.after(() => rmSync(folder, { recursive: true, force: true }));
  const file = path.join(folder, 'plan.md');
  writeFileSync(file, text);
  return check(file);
}

test('accepts a minimal plan with a background sleep heartbeat', (t) => {
  const result = checkFixture(t, plan);
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /^1 unit sections, 0 problems$/m);
});

test('rejects a plan that uses a real loop instead of background sleep', (t) => {
  const result = checkFixture(t, plan.replace('background `sleep 3000`', 'a real `/loop`'));
  assert.equal(result.status, 1, result.stderr);
  assert.match(result.stderr, /Program checklist lacks "background `sleep"/);
});

test('accepts the kinds root reflect plan', () => {
  const result = check('docs/work/reflect-kinds-2026-10-08/root.md');
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /^3 unit sections, 0 problems$/m);
});
