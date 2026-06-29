import assert from 'node:assert';
import fs from 'node:fs';
import path from 'node:path';

const ROOT_DIR = path.resolve(import.meta.dirname, '../..');
const SCRIPT_DIR = path.join(ROOT_DIR, 'skills/cadence-clarify/scripts');
const helper = fs.readFileSync(path.join(SCRIPT_DIR, 'helper.js'), 'utf8');
const frame = fs.readFileSync(path.join(SCRIPT_DIR, 'frame-template.html'), 'utf8');

let passed = 0;
let failed = 0;

function test(name, fn) {
  try {
    fn();
    console.log(`  PASS: ${name}`);
    passed += 1;
  } catch (error) {
    console.log(`  FAIL: ${name}`);
    console.log(`    ${error.message}`);
    failed += 1;
  }
}

console.log('\n--- helper.js contract ---');

test('exposes the Dev Cadence browser API', () => {
  assert(helper.includes('window.devCadenceVisual'));
  assert(helper.includes('send: sendEvent'));
  assert(helper.includes("choice: (value, metadata = {}) => sendEvent({ type: 'choice'"));
});

test('captures data-choice clicks and records the selected choice', () => {
  assert(helper.includes("document.addEventListener('click'"));
  assert(helper.includes("target.closest('[data-choice]')"));
  assert(helper.includes("type: 'click'"));
  assert(helper.includes('choice: target.dataset.choice'));
  assert(helper.includes('window.selectedChoice = el.dataset.choice'));
});

test('updates the selection indicator for single and multiple selections', () => {
  assert(helper.includes("document.getElementById('indicator-text')"));
  assert(helper.includes("selected.length === 1"));
  assert(helper.includes("selected.length + ' selected</span>"));
  assert(helper.includes('return to terminal to continue'));
});

test('supports single-select and multiselect containers', () => {
  assert(helper.includes("container.dataset.multiselect !== undefined"));
  assert(helper.includes("querySelectorAll('.option, .card')"));
  assert(helper.includes("el.classList.toggle('selected')"));
  assert(helper.includes("el.classList.add('selected')"));
});

test('connects to the current page WebSocket and reloads on server reload', () => {
  assert(helper.includes("const WS_URL = 'ws://' + window.location.host"));
  assert(helper.includes('new WebSocket(WS_URL)'));
  assert(helper.includes("data.type === 'reload'"));
  assert(helper.includes('window.location.reload()'));
});

console.log('\n--- frame-template.html contract ---');

test('brands the visual companion as Dev Cadence', () => {
  assert(frame.includes('<title>Dev Cadence Visual Companion</title>'));
  assert(frame.includes('<h1>Dev Cadence Visual Companion</h1>'));
});

test('contains the frame slots used by server.cjs and helper.js', () => {
  assert(frame.includes('<!-- CONTENT -->'));
  assert(frame.includes('id="visual-content"'));
  assert(frame.includes('class="status"'));
  assert(frame.includes('class="indicator-bar"'));
  assert(frame.includes('id="indicator-text"'));
});

test('keeps built-in option and card selection styles', () => {
  assert(frame.includes('.option.selected'));
  assert(frame.includes('.card.selected'));
  assert(frame.includes('--selected-bg'));
  assert(frame.includes('--selected-border'));
});

console.log(`\n--- Results: ${passed} passed, ${failed} failed ---`);
if (failed > 0) process.exit(1);
