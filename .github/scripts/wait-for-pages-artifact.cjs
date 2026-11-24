'use strict';

// deploy-pages reads a different artifact service. Two stable REST observations
// give uploads time to settle; they do not guarantee that service is available.
module.exports = async function waitForPagesArtifact({
  github, context, core, name, artifactId,
  attempts = 24, delayMs = 5000,
  sleep = ms => new Promise(resolve => setTimeout(resolve, ms))
}) {
  const id = Number(artifactId);
  if (!Number.isSafeInteger(id) || id <= 0 ||
      !Number.isSafeInteger(context.runId) || context.runId <= 0 ||
      !/^[a-f0-9]{40}$/.test(context.sha) ||
      !/^github-pages-\d+-\d+$/.test(name) ||
      !Number.isInteger(attempts) || attempts < 2 || attempts > 24 ||
      !Number.isFinite(delayMs) || delayMs < 0 || delayMs > 5000) {
    throw new Error('Invalid Pages artifact visibility parameters.');
  }
  let stable = 0;
  for (let attempt = 1; attempt <= attempts; attempt++) {
    const {data} = await github.rest.actions.listWorkflowRunArtifacts({
      ...context.repo, run_id: context.runId, name, per_page: 100
    });
    const matches = data.artifacts.filter(artifact => artifact.name === name);
    if (matches.length > 1) throw new Error('Multiple artifacts have this attempt\'s Pages name.');
    if (matches.length === 1) {
      const artifact = matches[0];
      if (artifact.id !== id || artifact.workflow_run?.id !== context.runId ||
          artifact.workflow_run?.head_sha !== context.sha) {
        throw new Error('Pages artifact identity does not match this upload and commit.');
      }
      if (artifact.expired || !(artifact.size_in_bytes > 0)) {
        throw new Error('Pages artifact is expired or empty.');
      }
      stable++;
      if (stable === 2) {
        core.info(`Pages artifact ${id} is visible in two consecutive checks.`);
        return id;
      }
    } else {
      stable = 0;
    }
    if (attempt < attempts) await sleep(delayMs);
  }
  throw new Error(`Pages artifact ${id} did not become stably visible after ${attempts} checks.`);
};
