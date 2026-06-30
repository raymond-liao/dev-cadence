import assert from 'node:assert';
import crypto from 'node:crypto';
import fs from 'node:fs';
import http from 'node:http';
import net from 'node:net';
import os from 'node:os';
import path from 'node:path';
import { spawn } from 'node:child_process';

const ROOT_DIR = path.resolve(import.meta.dirname, '../..');
const SERVER_PATH = path.join(ROOT_DIR, 'skills/cadence-clarify/scripts/server.cjs');
const TEST_DIR = fs.mkdtempSync(path.join(os.tmpdir(), 'dev-cadence-visual-test-'));
const CONTENT_DIR = path.join(TEST_DIR, 'content');
const STATE_DIR = path.join(TEST_DIR, 'state');
const OPEN_LOG = path.join(TEST_DIR, 'open.log');

let server = null;
let stdout = '';
let stderr = '';
let passed = 0;
let failed = 0;
let port = null;

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
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

function cleanup() {
  if (server && server.exitCode === null && server.signalCode === null) {
    server.kill();
  }
  fs.rmSync(TEST_DIR, { recursive: true, force: true });
}

async function waitForServerStarted() {
  const deadline = Date.now() + 5000;
  while (Date.now() < deadline) {
    const line = stdout.split('\n').find((entry) => entry.includes('server-started'));
    if (line) return JSON.parse(line);
    await sleep(50);
  }
  throw new Error(`server did not start. stdout=${stdout} stderr=${stderr}`);
}

function startServer() {
  server = spawn('node', [SERVER_PATH], {
    env: {
      ...process.env,
      DEV_CADENCE_VISUAL_PORT: String(port),
      DEV_CADENCE_VISUAL_HOST: '127.0.0.1',
      DEV_CADENCE_VISUAL_URL_HOST: 'localhost',
      DEV_CADENCE_VISUAL_DIR: TEST_DIR,
      DEV_CADENCE_VISUAL_OWNER_PID: String(process.pid),
      DEV_CADENCE_VISUAL_OPEN: '1',
      DEV_CADENCE_VISUAL_OPEN_CMD: `node -e "require('fs').appendFileSync(process.argv[1], process.argv[2] + '\\n')" ${JSON.stringify(OPEN_LOG)}`
    },
    stdio: ['ignore', 'pipe', 'pipe']
  });
  server.stdout.on('data', (data) => { stdout += data.toString(); });
  server.stderr.on('data', (data) => { stderr += data.toString(); });
}

function httpGet(pathname) {
  return new Promise((resolve, reject) => {
    const req = http.get({ hostname: '127.0.0.1', port, path: pathname }, (res) => {
      const chunks = [];
      res.on('data', (chunk) => chunks.push(chunk));
      res.on('end', () => {
        resolve({
          status: res.statusCode,
          headers: res.headers,
          body: Buffer.concat(chunks).toString('utf8')
        });
      });
    });
    req.on('error', reject);
  });
}

function encodeClientTextFrame(text) {
  const payload = Buffer.from(text);
  const mask = crypto.randomBytes(4);
  let header;

  if (payload.length < 126) {
    header = Buffer.alloc(2);
    header[0] = 0x81;
    header[1] = 0x80 | payload.length;
  } else if (payload.length < 65536) {
    header = Buffer.alloc(4);
    header[0] = 0x81;
    header[1] = 0x80 | 126;
    header.writeUInt16BE(payload.length, 2);
  } else {
    header = Buffer.alloc(10);
    header[0] = 0x81;
    header[1] = 0x80 | 127;
    header.writeBigUInt64BE(BigInt(payload.length), 2);
  }

  const masked = Buffer.alloc(payload.length);
  for (let i = 0; i < payload.length; i += 1) {
    masked[i] = payload[i] ^ mask[i % 4];
  }

  return Buffer.concat([header, mask, masked]);
}

function decodeServerFrame(buffer) {
  if (buffer.length < 2) return null;

  const opcode = buffer[0] & 0x0F;
  const masked = (buffer[1] & 0x80) !== 0;
  let payloadLength = buffer[1] & 0x7F;
  let offset = 2;

  if (masked) throw new Error('server frames must not be masked');

  if (payloadLength === 126) {
    if (buffer.length < 4) return null;
    payloadLength = buffer.readUInt16BE(2);
    offset = 4;
  } else if (payloadLength === 127) {
    if (buffer.length < 10) return null;
    payloadLength = Number(buffer.readBigUInt64BE(2));
    offset = 10;
  }

  const totalLength = offset + payloadLength;
  if (buffer.length < totalLength) return null;

  return {
    opcode,
    payload: buffer.slice(offset, totalLength),
    bytesConsumed: totalLength
  };
}

function openWebSocket() {
  return new Promise((resolve, reject) => {
    const socket = net.createConnection({ host: '127.0.0.1', port });
    const key = crypto.randomBytes(16).toString('base64');
    let handshake = Buffer.alloc(0);
    let frameBuffer = Buffer.alloc(0);
    const messageWaiters = [];

    function drainMessages() {
      while (frameBuffer.length > 0) {
        const frame = decodeServerFrame(frameBuffer);
        if (!frame) return;
        frameBuffer = frameBuffer.slice(frame.bytesConsumed);
        if (frame.opcode === 0x01) {
          const message = frame.payload.toString('utf8');
          const waiter = messageWaiters.shift();
          if (waiter) waiter.resolve(message);
        }
      }
    }

    socket.once('connect', () => {
      socket.write(
        'GET / HTTP/1.1\r\n' +
        'Host: 127.0.0.1\r\n' +
        'Upgrade: websocket\r\n' +
        'Connection: Upgrade\r\n' +
        `Sec-WebSocket-Key: ${key}\r\n` +
        'Sec-WebSocket-Version: 13\r\n\r\n'
      );
    });

    socket.on('data', (chunk) => {
      if (handshake !== null) {
        handshake = Buffer.concat([handshake, chunk]);
        const end = handshake.indexOf('\r\n\r\n');
        if (end < 0) return;
        const header = handshake.slice(0, end).toString('utf8');
        frameBuffer = handshake.slice(end + 4);
        handshake = null;
        assert(header.startsWith('HTTP/1.1 101'), `expected WebSocket 101, got: ${header}`);
        resolve({
          sendText(value) {
            socket.write(encodeClientTextFrame(value));
          },
          sendJson(value) {
            socket.write(encodeClientTextFrame(JSON.stringify(value)));
          },
          waitForJson(timeoutMs = 2000) {
            return new Promise((messageResolve, messageReject) => {
              let timer = null;
              const waiter = {
                resolve(message) {
                  clearTimeout(timer);
                  messageResolve(JSON.parse(message));
                }
              };
              timer = setTimeout(() => {
                const index = messageWaiters.indexOf(waiter);
                if (index >= 0) messageWaiters.splice(index, 1);
                messageReject(new Error('timed out waiting for WebSocket message'));
              }, timeoutMs);
              messageWaiters.push(waiter);
              drainMessages();
            });
          },
          close() {
            socket.end();
          }
        });
        drainMessages();
        return;
      }

      frameBuffer = Buffer.concat([frameBuffer, chunk]);
      drainMessages();
    });

    socket.on('error', reject);
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
    failed += 1;
  }
}

async function main() {
  process.on('exit', cleanup);
  port = await getFreePort();
  startServer();
  const info = await waitForServerStarted();

  await test('outputs usable server-started metadata', async () => {
    assert.strictEqual(info.type, 'server-started');
    assert.strictEqual(info.port, port);
    assert.strictEqual(info.host, '127.0.0.1');
    assert.strictEqual(info.url, `http://localhost:${port}`);
    assert.strictEqual(info.screen_dir, CONTENT_DIR);
    assert.strictEqual(info.state_dir, STATE_DIR);
    assert(fs.existsSync(path.join(STATE_DIR, 'server-info')));
  });

  await test('serves waiting page with injected helper when no screen exists', async () => {
    const response = await httpGet('/');
    assert.strictEqual(response.status, 200);
    assert(response.headers['content-type'].includes('text/html'));
    assert(response.body.includes('Dev Cadence Visual Companion'));
    assert(response.body.includes('Waiting for the agent to push a screen'));
    assert(response.body.includes('window.devCadenceVisual'));
  });

  await test('auto-opens the browser URL only when the first screen is added', async () => {
    const screenPath = path.join(CONTENT_DIR, 'auto-open.html');
    fs.rmSync(OPEN_LOG, { force: true });

    fs.writeFileSync(screenPath, '<h2>Auto Open</h2>');
    await sleep(300);

    assert.deepStrictEqual(fs.readFileSync(OPEN_LOG, 'utf8').trim().split('\n'), [`http://localhost:${port}`]);

    fs.writeFileSync(path.join(CONTENT_DIR, 'auto-open-2.html'), '<h2>Second Screen</h2>');
    await sleep(300);

    assert.deepStrictEqual(fs.readFileSync(OPEN_LOG, 'utf8').trim().split('\n'), [`http://localhost:${port}`]);
  });

  await test('wraps content fragments in the Dev Cadence frame', async () => {
    fs.writeFileSync(path.join(CONTENT_DIR, 'fragment.html'), '<h2>Choose direction</h2><div class="options"><div class="option" data-choice="a">A</div></div>');
    await sleep(300);

    const response = await httpGet('/');
    assert.strictEqual(response.status, 200);
    assert(response.body.includes('<div class="header">'));
    assert(response.body.includes('Dev Cadence Visual Companion'));
    assert(response.body.includes('indicator-text'));
    assert(response.body.includes('Choose direction'));
    assert(!response.body.includes('<!-- CONTENT -->'));
  });

  await test('serves full HTML documents without frame wrapping', async () => {
    fs.writeFileSync(path.join(CONTENT_DIR, 'full-doc.html'), '<!DOCTYPE html><html><body><h1>Custom full document</h1></body></html>');
    await sleep(300);

    const response = await httpGet('/');
    assert.strictEqual(response.status, 200);
    assert(response.body.includes('Custom full document'));
    assert(response.body.includes('window.devCadenceVisual'));
    assert(!response.body.includes('<div class="indicator-bar">'));
    assert(!response.body.includes('<div id="visual-content">'));
  });

  await test('serves static files from content directory only', async () => {
    fs.writeFileSync(path.join(CONTENT_DIR, 'style.css'), 'body { color: red; }');
    const response = await httpGet('/files/style.css');
    assert.strictEqual(response.status, 200);
    assert(response.headers['content-type'].includes('text/css'));
    assert(response.body.includes('color: red'));
  });

  await test('rejects empty file names and dotfiles under /files/', async () => {
    fs.writeFileSync(path.join(CONTENT_DIR, '._secret.html'), 'dotfile body should not be served');

    const emptyResponse = await httpGet('/files/');
    assert.strictEqual(emptyResponse.status, 404);

    const dotfileResponse = await httpGet('/files/._secret.html');
    assert.strictEqual(dotfileResponse.status, 404);
    assert(!dotfileResponse.body.includes('dotfile body'));
  });

  await test('does not serve symlinks escaping content directory', async () => {
    const linkPath = path.join(CONTENT_DIR, 'linked-server-info.txt');
    try {
      fs.unlinkSync(linkPath);
    } catch {
      // absent
    }
    try {
      fs.symlinkSync(path.join(STATE_DIR, 'server-info'), linkPath);
    } catch (error) {
      console.log(`  SKIP DETAIL: symlink unavailable: ${error.message}`);
      return;
    }

    const response = await httpGet('/files/linked-server-info.txt');
    assert.strictEqual(response.status, 404);
    assert(!response.body.includes('server-started'));
  });

  await test('ignores dotfile screens when choosing the newest screen', async () => {
    fs.writeFileSync(path.join(CONTENT_DIR, 'real-screen.html'), '<h2>Real Screen Content</h2>');
    await sleep(100);
    fs.writeFileSync(path.join(CONTENT_DIR, '._real-screen.html'), 'resource fork body');
    await sleep(300);

    const response = await httpGet('/');
    assert.strictEqual(response.status, 200);
    assert(response.body.includes('Real Screen Content'));
    assert(!response.body.includes('resource fork body'));
  });

  await test('writes choice events from WebSocket clients to state/events', async () => {
    const eventsFile = path.join(STATE_DIR, 'events');
    fs.rmSync(eventsFile, { force: true });

    const ws = await openWebSocket();
    ws.sendJson({ type: 'click', choice: 'b', text: 'Option B' });
    await sleep(300);
    ws.close();

    assert(fs.existsSync(eventsFile), 'state/events should exist');
    const lines = fs.readFileSync(eventsFile, 'utf8').trim().split('\n');
    const event = JSON.parse(lines.at(-1));
    assert.strictEqual(event.choice, 'b');
    assert.strictEqual(event.text, 'Option B');
    assert(stdout.includes('"source":"user-event"'));
  });

  await test('does not write non-choice WebSocket events to state/events', async () => {
    const eventsFile = path.join(STATE_DIR, 'events');
    fs.rmSync(eventsFile, { force: true });

    const ws = await openWebSocket();
    ws.sendJson({ type: 'hover', text: 'No choice' });
    await sleep(300);
    ws.close();

    assert(!fs.existsSync(eventsFile));
  });

  await test('broadcasts reload for new HTML screens only', async () => {
    const ws = await openWebSocket();
    fs.writeFileSync(path.join(CONTENT_DIR, 'reload-me.html'), '<h2>Reload</h2>');
    const message = await ws.waitForJson();
    ws.close();

    assert.strictEqual(message.type, 'reload');
  });

  await test('does not broadcast reload for non-HTML files or dotfile screens', async () => {
    const ws = await openWebSocket();
    const wait = ws.waitForJson(500).then(
      (message) => {
        throw new Error(`unexpected WebSocket message: ${JSON.stringify(message)}`);
      },
      (error) => {
        if (!error.message.includes('timed out')) throw error;
      }
    );

    fs.writeFileSync(path.join(CONTENT_DIR, 'ignore.txt'), 'not a screen');
    fs.writeFileSync(path.join(CONTENT_DIR, '._ignore.html'), 'resource fork');
    await wait;
    ws.close();
  });

  await test('does not auto-open when a browser client is already connected', async () => {
    const existingClientDir = fs.mkdtempSync(path.join(os.tmpdir(), 'dev-cadence-visual-existing-client-'));
    const existingContentDir = path.join(existingClientDir, 'content');
    const existingStateDir = path.join(existingClientDir, 'state');
    const existingOpenLog = path.join(existingClientDir, 'open.log');
    const existingPort = await getFreePort();
    const existingServer = spawn('node', [SERVER_PATH], {
      env: {
        ...process.env,
        DEV_CADENCE_VISUAL_PORT: String(existingPort),
        DEV_CADENCE_VISUAL_HOST: '127.0.0.1',
        DEV_CADENCE_VISUAL_URL_HOST: 'localhost',
        DEV_CADENCE_VISUAL_DIR: existingClientDir,
        DEV_CADENCE_VISUAL_OWNER_PID: String(process.pid),
        DEV_CADENCE_VISUAL_OPEN: '1',
        DEV_CADENCE_VISUAL_OPEN_CMD: `node -e "require('fs').appendFileSync(process.argv[1], process.argv[2] + '\\n')" ${JSON.stringify(existingOpenLog)}`
      },
      stdio: ['ignore', 'pipe', 'pipe']
    });
    let existingStdout = '';
    let existingStderr = '';
    existingServer.stdout.on('data', (data) => { existingStdout += data.toString(); });
    existingServer.stderr.on('data', (data) => { existingStderr += data.toString(); });
    try {
      const deadline = Date.now() + 5000;
      while (!existingStdout.includes('server-started') && Date.now() < deadline) {
        await sleep(50);
      }
      assert(existingStdout.includes('server-started'), `server did not start. stdout=${existingStdout} stderr=${existingStderr}`);

      await new Promise((resolve, reject) => {
        const socket = net.createConnection({ host: '127.0.0.1', port: existingPort });
        socket.once('connect', () => {
          const key = crypto.randomBytes(16).toString('base64');
          socket.write(
            'GET / HTTP/1.1\r\n' +
            'Host: 127.0.0.1\r\n' +
            'Upgrade: websocket\r\n' +
            'Connection: Upgrade\r\n' +
            `Sec-WebSocket-Key: ${key}\r\n` +
            'Sec-WebSocket-Version: 13\r\n\r\n'
          );
        });
        socket.once('data', () => {
          fs.writeFileSync(path.join(existingContentDir, 'has-client.html'), '<h2>Has Client</h2>');
          setTimeout(() => {
            socket.end();
            resolve();
          }, 300);
        });
        socket.on('error', reject);
      });

      assert(!fs.existsSync(existingOpenLog), 'auto-open should be skipped when a client is already connected');
      assert(fs.existsSync(existingStateDir));
    } finally {
      if (existingServer.exitCode === null && existingServer.signalCode === null) {
        existingServer.kill();
      }
      fs.rmSync(existingClientDir, { recursive: true, force: true });
    }
  });

  await test('clears prior events when a new screen is added', async () => {
    const eventsFile = path.join(STATE_DIR, 'events');
    fs.writeFileSync(eventsFile, '{"choice":"old"}\n');

    fs.writeFileSync(path.join(CONTENT_DIR, 'new-screen.html'), '<h2>New Screen</h2>');
    await sleep(300);

    assert(!fs.existsSync(eventsFile), 'state/events should be removed for a new screen');
  });

  await test('ignores malformed WebSocket JSON without crashing', async () => {
    const ws = await openWebSocket();
    ws.sendText('not json at all {{{');
    await sleep(100);
    ws.close();

    const response = await httpGet('/');
    assert.strictEqual(response.status, 200);
  });

  cleanup();
  console.log(`\n--- Results: ${passed} passed, ${failed} failed ---`);
  if (failed > 0) process.exit(1);
}

main().catch((error) => {
  cleanup();
  console.error(error);
  process.exit(1);
});
