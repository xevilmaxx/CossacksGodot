// Lane-parent helper: durable subagent control via the OpenCode CLI.
// Usage:
//   node rustport/.lane/spawn.js create <title> <promptFile> [parentID] [modelVariant]
//   node rustport/.lane/spawn.js prompt <sessionID> <promptFile>
//   node rustport/.lane/spawn.js get <sessionID>
//   node rustport/.lane/spawn.js wait <sessionID>
//   node rustport/.lane/spawn.js inbox
const { spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const EXE = 'C:\\Users\\Maxym.Oboyshev\\AppData\\Roaming\\npm\\node_modules\\@opencode\\cli\\bin\\opencode.exe';
const ME = 'ses_df83996f2ffeR7UWC6RR73aACk';

function api(method, route, body) {
  const args = ['api', method, route];
  if (body !== undefined) args.push('--data', JSON.stringify(body));
  const r = spawnSync(EXE, args, { encoding: 'utf8', maxBuffer: 16 * 1024 * 1024 });
  if (r.error) throw r.error;
  if (r.status !== 0) {
    throw new Error(`api ${method} ${route} failed (${r.status}): ${r.stderr}\n${r.stdout}`);
  }
  try { return JSON.parse(r.stdout); } catch { return r.stdout; }
}
function parse(x) { return x && x.data ? x.data : x; }
const HOST_FACTS = '\n\n---\nHOST FACTS (binding, owner directive 2026-11-23):\n' +
  '- This host is Windows. The Python command is `python` (3.14) — NEVER `python3`\n' +
  '  (Microsoft-Store alias trap). Verify with `python --version`.\n' +
  '- Blender (if ever needed) is at "C:\\Program Files\\Blender Foundation\\Blender 5.2\\blender.exe"\n' +
  '  — it is NOT on PATH. This lane does not need Blender.\n' +
  '- Preferred child model is opencode-go/hy4-flash-free; opencode/hy4-flash-free is\n' +
  '  quota-blocked ("Free usage limit reached").\n' +
  '- Never run Godot or the Godot runner in this lane.\n';
function readPrompt(f) { return fs.readFileSync(path.resolve(f), 'utf8') + HOST_FACTS; }

const [action, a, b, c, d, e] = process.argv.slice(2);
try {
  let out;
  if (action === 'create') {
    const title = a;
    const text = readPrompt(b);
    const parentID = c || ME;
    // Owner directive 2026-11-23: prefer opencode-go pool; opencode/hy4-flash-free
    // is quota-blocked ("Free usage limit reached").
    const modelRef = (e === 'esc')
      ? { id: 'muse-spark-1.3-contributor', providerID: 'opencode-go', variant: 'high' }
      : { id: 'hy4-flash-free', providerID: 'opencode-go', variant: d || 'high' };
    const sess = parse(api('post', '/api/session', {
      parentID,
      agent: 'general',
      model: modelRef,
      title,
      permissions: [
        { action: 'subagent', resource: '*', effect: 'allow' },
        { action: 'browser', resource: '*', effect: 'allow' },
        { action: 'skill', resource: 'browser', effect: 'allow' },
      ],
    }));
    const pr = api('post', `/api/session/${encodeURIComponent(sess.id)}/prompt`, { text });
    out = { sessionID: sess.id, parentID: sess.parentID, promptStatus: pr && pr.status !== undefined ? pr.status : 'sent' };
  } else if (action === 'prompt') {
    const text = readPrompt(b);
    out = api('post', `/api/session/${encodeURIComponent(a)}/prompt`, { text });
  } else if (action === 'get') {
    out = parse(api('get', `/api/session/${encodeURIComponent(a)}`));
  } else if (action === 'wait') {
    out = api('post', `/api/experimental/session/${encodeURIComponent(a)}/wait`);
  } else if (action === 'inbox') {
    out = api('get', `/api/session/${encodeURIComponent(ME)}/inbox`);
  } else {
    throw new Error('unknown action: ' + action);
  }
  console.log(JSON.stringify(out, null, 2));
} catch (e) {
  console.error(String(e && e.message || e));
  process.exit(1);
}
