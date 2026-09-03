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

  // Imports (CBO proxy)
  const importMatches = code.match(/^\s*import\s.+$/gm) || [];
  const imports = new Set();
  for (const imp of importMatches) {
    const m = imp.match(/from\s+['"]([^'"]+)['"]/);
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

// Walk src/, excluding test/fixture files
const srcRoot = path.join(process.cwd(), 'src');
const allFiles = walk(srcRoot, ['.js', '.jsx'], [
  '__tests__',
  '__fixtures__',
  'test',
  'node_modules',
  'dist',
  'build',
  '.cache',
]);

// Also collect test files separately
const testRoot = path.join(process.cwd(), 'src');
const testFiles = walk(testRoot, ['.test.js', '.test.jsx'], [
  'node_modules',
  'dist',
  'build',
]);

// Filter out test files from source
const sourceFiles = allFiles.filter(f => !f.includes('.test.'));

const results = sourceFiles.map(sf => {
  const source = analyzeSource(sf);
  const testPath = findTestFile(sf);
  const test = testPath ? analyzeTest(testPath) : null;
  const relSource = path.relative(process.cwd(), sf);
  const relTest = testPath ? path.relative(process.cwd(), testPath) : null;

  // Combined risk score
  const sourceRisk =
    Math.max(0, source.lineCount - 300) / 50 +
    Math.max(0, source.heuristicCCN - 30) +
    Math.max(0, source.importCount - 8) * 0.5 +
    Math.max(0, source.functionCount - 10) * 0.3;
  const testRisk = test
    ? Math.max(0, test.mountCount - 1) * 3 +
      Math.max(0, test.mockCount - 2) * 2 +
      Math.max(0, test.lineCount - 200) / 20
    : test === null ? 0.5 : 0; // untested source gets a small penalty
  const hasTest = test !== null;
  const totalRisk = sourceRisk + testRisk + (hasTest ? 0 : 2); // untested slight bump

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

console.log('=== TOP 40 SOURCE+TEST RISK (unified kill list) ===\n');
console.log('rank | source | lines | imp | fn | CCN(h) | test | mounts | mocks | risk');
console.log('-'.repeat(130));
let rank = 1;
for (const r of results.slice(0, 40)) {
  if (r.totalRisk < 1) continue;
  const f = r.relSource.padEnd(55);
  const t = (r.relTest || '(no test)').padEnd(35);
  console.log(
    `${String(rank).padStart(4)} | ${f} | ${String(r.source.lineCount).padStart(5)} | ${String(r.source.importCount).padStart(3)} | ${String(r.source.functionCount).padStart(3)} | ${String(r.source.heuristicCCN).padStart(6)} | ${t} | ${r.test ? String(r.test.mountCount).padStart(6) : '  -  '} | ${r.test ? String(r.test.mockCount).padStart(5) : '  -  '} | ${r.totalRisk.toFixed(1).padStart(5)}`
  );
  rank++;
}

console.log('\n=== ALL HIGH-RISK (>10 risk) ===\n');
for (const r of results) {
  if (r.totalRisk < 10) continue;
  console.log(`${r.relSource}  src_lines=${r.source.lineCount} src_ccn=${r.source.heuristicCCN} src_imp=${r.source.importCount}  test=${r.relTest || '(none)'}  test_mounts=${r.test?.mountCount ?? '-'}  total_risk=${r.totalRisk.toFixed(1)}`);
}
