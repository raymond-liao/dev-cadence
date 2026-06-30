import assert from 'node:assert';
import fs from 'node:fs';
import http from 'node:http';
import net from 'node:net';
import os from 'node:os';
import path from 'node:path';
import { execFile, spawn } from 'node:child_process';

const ROOT_DIR = path.resolve(import.meta.dirname, '../..');
const START = path.join(ROOT_DIR, 'skills/cadence-clarify/scripts/start-server.sh');
const STOP = path.join(ROOT_DIR, 'skills/cadence-clarify/scripts/stop-server.sh');
const TEST_ROOT = fs.mkdtempSync(path.join(os.tmpdir(), 'dev-cadence-visual-life-'));

let passed = 0;
let failed = 0;
const cleanupCallbacks = [];

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function cleanup() {
  for (const callback of cleanupCallbacks.splice(0).reverse()) {
    try {
      callback();
    } catch {
      // best effort cleanup
    }
  }
  fs.rmSync(TEST_ROOT, { recursive: true, force: true });
}

function execFileAsync(file, args, options = {}) {
  return new Promise((resolve, reject) => {
    execFile(file, args, { encoding: 'utf8', ...options }, (error, stdout, stderr) => {
      if (error) {
        error.stdout = stdout;
        error.stderr = stderr;
        reject(error);
        return;
      }
      resolve({ stdout, stderr });
    });
  });
}

function getFreePort() {
  return new Promise((resolve, reject) => {
    const probe = net.createServer();
    probe.listen(0, '127.0.0.1', () => {
      const address = probe.address();
      probe.close(() => resolve(address.port));
    });
    probe.on('error', reject);
  });
}

function httpStatus(port) {
  return new Promise((resolve) => {
    const req = http.get({ hostname: '127.0.0.1', port, path: '/' }, (res) => {
      res.resume();
      res.on('end', () => resolve(res.statusCode));
    });
    req.on('error', () => resolve(0));
  });
}

async function waitForExit(child, timeoutMs = 2000) {
  if (child.exitCode !== null || child.signalCode !== null) return true;
  return new Promise((resolve) => {
    let settled = false;
    const finish = (exited) => {
      if (settled) return;
      settled = true;
      resolve(exited);
    };
    child.once('exit', () => finish(true));
    setTimeout(() => finish(false), timeoutMs);
  });
}

async function test(name, fn) {
  try {
    await fn();
    console.log(`  PASS: ${name}`);
    passed += 1;
  } catch (error) {
    console.log(`  FAIL: ${name}`);
    console.log(`    ${error.message}`);
    if (error.stdout || error.stderr) {
      console.log(`    stdout=${error.stdout || ''}`);
      console.log(`    stderr=${error.stderr || ''}`);
    }
    failed += 1;
  }
}

function parseJsonLine(output) {
  const line = output.trim().split('\n').find((entry) => entry.trim().startsWith('{'));
  assert(line, `expected JSON output, got: ${output}`);
  return JSON.parse(line);
}

async function stopSession(sessionDir) {
  return execFileAsync('bash', [STOP, sessionDir]);
}

process.on('exit', cleanup);

console.log('\n--- start-server.sh / stop-server.sh lifecycle ---');

await test('starts in background, returns session metadata, and stop preserves project sessions', async () => {
  const projectDir = path.join(TEST_ROOT, 'project-session');
  fs.mkdirSync(projectDir, { recursive: true });
  const port = await getFreePort();

  const { stdout } = await execFileAsync('bash', [
    START,
    '--project-dir', projectDir,
    '--host', '127.0.0.1',
    '--url-host', 'localhost',
    '--open',
    '--background'
  ], {
    env: {
      ...process.env,
      DEV_CADENCE_VISUAL_PORT: String(port)
    }
  });

  const info = parseJsonLine(stdout);
  cleanupCallbacks.push(() => {
    if (fs.existsSync(path.dirname(info.state_dir))) {
      execFile('bash', [STOP, path.dirname(info.state_dir)], () => {});
    }
  });

  assert.strictEqual(info.type, 'server-started');
  assert.strictEqual(info.port, port);
  assert.strictEqual(info.host, '127.0.0.1');
  assert.strictEqual(info.url, `http://localhost:${port}`);
  assert(info.screen_dir.startsWith(path.join(projectDir, '.dev-cadence/visual-companion')));
  assert.strictEqual(info.state_dir, path.join(path.dirname(info.screen_dir), 'state'));
  assert(fs.existsSync(path.join(info.state_dir, 'server.pid')));
  assert(fs.existsSync(path.join(info.state_dir, 'server-instance-id')));
  assert.strictEqual(await httpStatus(port), 200);

  const stop = await stopSession(path.dirname(info.state_dir));
  assert.deepStrictEqual(parseJsonLine(stop.stdout), { status: 'stopped' });
  assert(fs.existsSync(path.dirname(info.state_dir)), 'project sessions should be preserved');
  assert(!fs.existsSync(path.join(info.state_dir, 'server.pid')), 'pid file should be removed');
});

await test('stop deletes ephemeral /tmp sessions', async () => {
  const port = await getFreePort();
  const { stdout } = await execFileAsync('bash', [
    START,
    '--host', '127.0.0.1',
    '--url-host', 'localhost',
    '--background'
  ], {
    env: {
      ...process.env,
      DEV_CADENCE_VISUAL_PORT: String(port)
    }
  });

  const info = parseJsonLine(stdout);
  const sessionDir = path.dirname(info.state_dir);
  cleanupCallbacks.push(() => {
    if (fs.existsSync(sessionDir)) execFile('bash', [STOP, sessionDir], () => {});
  });
  assert(sessionDir.startsWith('/tmp/dev-cadence-visual-companion-'));
  assert.strictEqual(await httpStatus(port), 200);

  const stop = await stopSession(sessionDir);
  assert.deepStrictEqual(parseJsonLine(stop.stdout), { status: 'stopped' });
  assert(!fs.existsSync(sessionDir), 'ephemeral /tmp session should be deleted');
});

await test('stop reports not_running when no pid file exists', async () => {
  const sessionDir = path.join(TEST_ROOT, 'not-running');
  fs.mkdirSync(path.join(sessionDir, 'state'), { recursive: true });

  const stop = await stopSession(sessionDir);
  assert.deepStrictEqual(parseJsonLine(stop.stdout), { status: 'not_running' });
});

await test('stop does not kill an unrelated stale pid', async () => {
  const sessionDir = path.join(TEST_ROOT, 'stale-pid');
  const stateDir = path.join(sessionDir, 'state');
  fs.mkdirSync(stateDir, { recursive: true });

  const unrelated = spawn('sleep', ['30'], { stdio: 'ignore' });
  cleanupCallbacks.push(() => unrelated.kill('SIGKILL'));
  fs.writeFileSync(path.join(stateDir, 'server.pid'), String(unrelated.pid));
  fs.writeFileSync(path.join(stateDir, 'server-instance-id'), 'dcv-stale-test');

  const stop = await stopSession(sessionDir);
  assert.deepStrictEqual(parseJsonLine(stop.stdout), { status: 'stale_pid' });
  assert.strictEqual(await waitForExit(unrelated, 200), false, 'unrelated process should still be alive');
  unrelated.kill('SIGKILL');
});

console.log(`\n--- Results: ${passed} passed, ${failed} failed ---`);
cleanup();
if (failed > 0) process.exit(1);
