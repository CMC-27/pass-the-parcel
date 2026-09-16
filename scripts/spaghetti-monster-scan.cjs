// Spaghetti-monster metric pass — app source AND machinery.
//
// Roots: `src/` is the app surface (ECMAScript). It is absent in a repo with no
// application tree, and that is a clean no-op, never a crash — an absent tree
// means nothing to scan there, not a broken workspace. The machinery roots
// (`scripts/`, `.devops/skills/`, `.devops/agents/`, `.devops/templates/`) are
// the template's actual product surface, so they are scanned too, under the same
// thresholds as `src/`; without them the scanner never sees most of the code it
// exists to police. `.devops/backlog/REFACTORING.md` § Thresholds is the table.
//
// Metric fidelity: the CCN / import / export / JSX counters are ECMAScript-shaped
// regex approximations. On a non-ECMAScript file (`.ps1`, `.py`, `.md`) they are
// reported as `-` and that row's risk is line-count only — read `-` as "not
// measured", never as "clean". Line count is the load-bearing signal for the
// machinery pass.
const fs = require('node:fs');
const path = require('node:path');

function walk(dir, exts, ignore) {
  const out = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (ignore.some(p => entry.name === p || entry.name.startsWith(p))) continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      out.push(...walk(full, exts, ignore));
    } else if (exts.some(e => entry.name.endsWith(e))) {
      out.push(full);
    }
  }
  return out;
}

function analyzeSource(filePath) {
  const src = fs.readFileSync(filePath, 'utf8');
  const lines = src.split('\n');
  const lineCount = lines.length;

  const code = src
    .replace(/\/\*[\s\S]*?\*\//g, '')
    .replace(/\/\/.*$/gm, '');

  // Imports (CBO proxy) — ESM `import … from` plus CommonJS `require(…)`, so the
  // `.cjs` machinery entry point is not scored as having zero coupling.
  const importMatches = code.match(/^\s*import\s.+$/gm) || [];
  const imports = new Set();
  for (const imp of importMatches) {
    const m = imp.match(/from\s+['"]([^'"]+)['"]/);
    if (m) imports.add(m[1]);
  }
  for (const req of code.match(/require\s*\(\s*['"]([^'"]+)['"]\s*\)/g) || []) {
    const m = req.match(/['"]([^'"]+)['"]/);
    if (m) imports.add(m[1]);
  }

  // Export count
  const exportCount = (code.match(/^\s*export\s+(default\s+)?(const|function|class|async\s+function|\{)/gm) || []).length;

  // Function declarations / expressions / arrow
  const functionCount =
    (code.match(/^\s*(async\s+)?function\s+\w+/gm) || []).length +
    (code.match(/=\s*(async\s+)?\([^)]*\)\s*=>/g) || []).length +
    (code.match(/=\s*(async\s+)?\w+\s*=>/g) || []).length;

  // Cyclomatic heuristic
  const branchy =
    (code.match(/\bif\s*\(/g) || []).length +
    (code.match(/\belse\s+if\b/g) || []).length +
    (code.match(/\bcase\s+/g) || []).length +
    (code.match(/\bfor\s*\(/g) || []).length +
    (code.match(/\bwhile\s*\(/g) || []).length +
    (code.match(/\bcatch\s*\(/g) || []).length +
    (code.match(/&&/g) || []).length +
    (code.match(/\|\|/g) || []).length +
    (code.match(/\?[^.]/g) || []).length +
    (code.match(/\?\?/g) || []).length;
  const heuristicCCN = 1 + branchy;

  // JSX tag count (component size signal)
  const jsxCount = (code.match(/<[A-Z][A-Za-z0-9]*/g) || []).length;

  return {
    file: filePath,
    lineCount,
    importCount: imports.size,
    exportCount,
    functionCount,
    heuristicCCN,
    jsxCount,
  };
}

// Non-ECMAScript files (PowerShell / Python / Markdown / JSON) are measured on
// line count only — the CCN/import/export regexes above are ECMAScript-shaped and
// would report prose noise as complexity. `null` prints as `-` (not measured).
function analyzeByLines(filePath) {
  const src = fs.readFileSync(filePath, 'utf8');
  return {
    file: filePath,
    lineCount: src.split('\n').length,
    importCount: null,
    exportCount: null,
    functionCount: null,
    heuristicCCN: null,
    jsxCount: 0,
  };
}

function analyzeTest(filePath) {
  if (!filePath || !fs.existsSync(filePath)) return null;
  const src = fs.readFileSync(filePath, 'utf8');
  const lines = src.split('\n');
  const code = src
    .replace(/\/\*[\s\S]*?\*\//g, '')
    .replace(/\/\/.*$/gm, '');

  const importMatches = code.match(/^\s*import\s.+$/gm) || [];
  const imports = new Set();
  for (const imp of importMatches) {
    const m = imp.match(/from\s+['"]([^'"]+)['"]/);
    if (m) imports.add(m[1]);
  }

  const itCount = (code.match(/\bit\s*\(|test\s*\(/g) || []).length;
  const describeCount = (code.match(/\bdescribe\s*\(/g) || []).length;
  const mountCount =
    (code.match(/\brender\s*\(/g) || []).length +
    (code.match(/renderHook\s*\(/g) || []).length;
  const viMockCount = (code.match(/\bvi\.mock\s*\(/g) || []).length;

  return {
    file: filePath,
    lineCount: lines.length,
    importCount: imports.size,
    itCount,
    describeCount,
    mountCount,
    mockCount: viMockCount,
  };
}

function findTestFile(sourcePath) {
  const dir = path.dirname(sourcePath);
  const base = path.basename(sourcePath, path.extname(sourcePath));
  // Common patterns
  const candidates = [
    path.join(dir, `${base}.test.jsx`),
    path.join(dir, `${base}.test.js`),
    path.join(dir, '__tests__', `${base}.test.jsx`),
    path.join(dir, '__tests__', `${base}.test.js`),
  ];
  for (const c of candidates) {
    if (fs.existsSync(c)) return c;
  }
  return null;
}

// ---- Scan roots -------------------------------------------------------------
// `src/` is the app surface; the machinery roots are the template's product
// surface and are scanned under the same thresholds. A missing root is a clean
// one-line skip, never a crash.
const JS_EXTS = ['.js', '.jsx', '.cjs', '.mjs'];
const ROOTS = [
  { dir: 'src', exts: JS_EXTS, ignore: ['__tests__', '__fixtures__', 'test', 'node_modules', 'dist', 'build', '.cache'] },
  { dir: 'scripts', exts: ['.ps1', '.py', '.cjs', '.js'], ignore: ['node_modules'] },
  { dir: '.devops/skills', exts: ['.md'], ignore: [] },
  { dir: '.devops/agents', exts: ['.md'], ignore: [] },
  { dir: '.devops/templates', exts: ['.md', '.json'], ignore: ['node_modules'] },
];

const allFiles = [];
for (const root of ROOTS) {
  const rootPath = path.join(process.cwd(), root.dir);
  if (!fs.existsSync(rootPath)) {
    console.log(`no ${root.dir}/ tree in this workspace — skipping (nothing to scan there)`);
    continue;
  }
  allFiles.push(...walk(rootPath, root.exts, root.ignore));
}

if (allFiles.length === 0) {
  console.log('nothing to scan: no app-source or machinery root exists in this workspace');
  process.exit(0);
}

// Filter out test files from source
const sourceFiles = allFiles.filter(f => !f.includes('.test.'));
const isJs = f => JS_EXTS.some(e => f.endsWith(e));
const isAppSource = f => path.relative(process.cwd(), f).replace(/\\/g, '/').startsWith('src/');

const results = sourceFiles.map(sf => {
  const source = isJs(sf) ? analyzeSource(sf) : analyzeByLines(sf);
  const testPath = findTestFile(sf);
  const test = testPath ? analyzeTest(testPath) : null;
  const relSource = path.relative(process.cwd(), sf);
  const relTest = testPath ? path.relative(process.cwd(), testPath) : null;
  const appSource = isAppSource(sf);

  // Combined risk score. A `null` metric (non-ECMAScript file) contributes 0 —
  // such a row's risk is line-count only, which is the signal that matters for
  // the machinery pass.
  const sourceRisk =
    Math.max(0, source.lineCount - 300) / 50 +
    (source.heuristicCCN === null ? 0 : Math.max(0, source.heuristicCCN - 30)) +
    (source.importCount === null ? 0 : Math.max(0, source.importCount - 8) * 0.5) +
    (source.functionCount === null ? 0 : Math.max(0, source.functionCount - 10) * 0.3);
  const testRisk = test
    ? Math.max(0, test.mountCount - 1) * 3 +
      Math.max(0, test.mockCount - 2) * 2 +
      Math.max(0, test.lineCount - 200) / 20
    : appSource ? 0.5 : 0; // untested app source gets a small penalty
  const hasTest = test !== null;
  // The untested bump is an app-source signal — machinery files never sit beside
  // a sibling `.test.js`, so charging them for it would only add constant noise.
  const totalRisk = sourceRisk + testRisk + (appSource && !hasTest ? 2 : 0);

  return {
    relSource,
    relTest,
    source,
    test,
    sourceRisk,
    testRisk,
    totalRisk,
    hasTest,
  };
});

results.sort((a, b) => b.totalRisk - a.totalRisk);

// `null` metric → `-` ("not measured", never "clean").
const m = (v, width) => (v === null || v === undefined ? '-' : String(v)).padStart(width);

console.log('=== TOP 40 SOURCE+TEST RISK (unified kill list) ===\n');
console.log('roots: src/ (app) + scripts/, .devops/skills/, .devops/agents/, .devops/templates/ (machinery)');
console.log('non-ECMAScript rows (`imp`/`fn`/`CCN` shown as `-`) are ranked on line count only.\n');
console.log('rank | source | lines | imp | fn | CCN(h) | test | mounts | mocks | risk');
console.log('-'.repeat(130));
let rank = 1;
for (const r of results.slice(0, 40)) {
  if (r.totalRisk < 1) continue;
  const f = r.relSource.padEnd(55);
  const t = (r.relTest || '(no test)').padEnd(35);
  console.log(
    `${String(rank).padStart(4)} | ${f} | ${m(r.source.lineCount, 5)} | ${m(r.source.importCount, 3)} | ${m(r.source.functionCount, 3)} | ${m(r.source.heuristicCCN, 6)} | ${t} | ${r.test ? String(r.test.mountCount).padStart(6) : '  -  '} | ${r.test ? String(r.test.mockCount).padStart(5) : '  -  '} | ${r.totalRisk.toFixed(1).padStart(5)}`
  );
  rank++;
}

console.log('\n=== ALL HIGH-RISK (>10 risk) ===\n');
for (const r of results) {
  if (r.totalRisk < 10) continue;
  console.log(`${r.relSource}  lines=${r.source.lineCount} ccn=${r.source.heuristicCCN ?? '-'} imp=${r.source.importCount ?? '-'}  test=${r.relTest || '(none)'}  test_mounts=${r.test?.mountCount ?? '-'}  total_risk=${r.totalRisk.toFixed(1)}`);
}
