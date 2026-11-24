import assert from 'node:assert/strict';
import {test} from 'node:test';
import fs from 'node:fs';
import waitForArtifact from '../.github/scripts/wait-for-pages-artifact.cjs';

const name = 'github-pages-123-2', sha = 'a'.repeat(40);
const artifact = {id: 456, name, size_in_bytes: 1024, expired: false,
  workflow_run: {id: 123, head_sha: sha}};
function fixture(observations, overrides = {}) {
  let calls = 0, sleeps = 0;
  const options = {name, artifactId: '456', attempts: 4, delayMs: 0,
    context: {repo: {owner: 'owner', repo: 'repo'}, runId: 123, sha},
    core: {info() {}}, sleep: async () => { sleeps++; },
    github: {rest: {actions: {listWorkflowRunArtifacts: async args => {
      assert.deepEqual(args, {owner: 'owner', repo: 'repo', run_id: 123, name, per_page: 100});
      const result = observations[Math.min(calls++, observations.length - 1)];
      if (result instanceof Error) throw result;
      return {data: {artifacts: result}};
    }}}}, ...overrides};
  return {options, calls: () => calls, sleeps: () => sleeps};
}
test('delayed upload requires two consecutive observations of this exact artifact', async () => {
  const f = fixture([[], [artifact], [], [artifact], [artifact]], {attempts: 5});
  assert.equal(await waitForArtifact(f.options), 456);
  assert.equal(f.calls(), 5); assert.equal(f.sleeps(), 4);
});
test('previous attempts cannot cause ambiguity or count as readiness', async () => {
  const old = {...artifact, id: 111, name: 'github-pages-123-1'};
  const f = fixture([[old], [old, artifact], [old, artifact]]);
  assert.equal(await waitForArtifact(f.options), 456); assert.equal(f.calls(), 3);
});
test('missing artifact times out within the bounded number of checks', async () => {
  const f = fixture([[]]);
  await assert.rejects(waitForArtifact(f.options), /after 4 checks/);
  assert.equal(f.calls(), 4); assert.equal(f.sleeps(), 3);
});
for (const [label, changed, error] of [
  ['wrong upload', {...artifact, id: 789}, /identity/],
  ['wrong run', {...artifact, workflow_run: {...artifact.workflow_run, id: 124}}, /identity/],
  ['wrong commit', {...artifact, workflow_run: {...artifact.workflow_run, head_sha: 'b'.repeat(40)}}, /identity/],
  ['missing provenance', {...artifact, workflow_run: undefined}, /identity/],
  ['expired upload', {...artifact, expired: true}, /expired or empty/],
  ['empty upload', {...artifact, size_in_bytes: 0}, /expired or empty/]
]) test(`rejects ${label}`, async () => {
  const f = fixture([[changed]]);
  await assert.rejects(waitForArtifact(f.options), error); assert.equal(f.sleeps(), 0);
});
test('duplicate names fail instead of picking an arbitrary artifact', async () => {
  await assert.rejects(waitForArtifact(fixture([[artifact, {...artifact, id: 789}]]).options), /Multiple artifacts/);
});
test('API authorization and service errors propagate', async () => {
  const error = new Error('403 forbidden'), f = fixture([error]);
  await assert.rejects(waitForArtifact(f.options), value => value === error);
  assert.equal(f.calls(), 1); assert.equal(f.sleeps(), 0);
});
test('invalid configuration fails before polling', async () => {
  for (const invalid of [{artifactId: ''}, {name: 'github-pages'}, {attempts: 999}, {delayMs: 60000}]) {
    const f = fixture([[]], invalid);
    await assert.rejects(waitForArtifact(f.options), /Invalid Pages/); assert.equal(f.calls(), 0);
  }
});
test('workflow uploads, waits for, and deploys the same unique attempt name', () => {
  const workflow = fs.readFileSync(new URL('../.github/workflows/pages.yml', import.meta.url), 'utf8');
  assert.equal(workflow.match(/github-pages-\$\{\{ github\.run_id \}\}-\$\{\{ github\.run_attempt \}\}/g)?.length, 3);
  assert.match(workflow, /actions: read/);
  assert.match(workflow, /PAGES_ARTIFACT_ID: \$\{\{ steps\.pages-upload\.outputs\.artifact_id \}\}/);
  assert(workflow.indexOf('Wait for uploaded Pages artifact') > workflow.indexOf('actions/upload-pages-artifact@v3'));
  assert(workflow.indexOf('actions/deploy-pages@v4') > workflow.indexOf('Wait for uploaded Pages artifact'));
});
