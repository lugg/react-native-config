const assert = require('node:assert/strict');
const { execFileSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const test = require('node:test');
const fixtures = require('./fixtures/inline_comments.json');

const generator = path.resolve(__dirname, '../windows/code/generate-header.js');

test('generated C++ constants preserve the comment fixture values', async (t) => {
  try {
    execFileSync('clang++', ['--version'], { stdio: 'pipe' });
  } catch {
    t.skip('clang++ is unavailable');
    return;
  }

  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'rnc-constants-'));
  try {
    fs.writeFileSync(path.join(root, '.env'), fixtures.map(fixture => fixture.line).join('\n'));
    const out = path.join(root, 'out');
    fs.mkdirSync(out);
    execFileSync(process.execPath, [generator, path.join(root, 'native'), out], {
      env: { ...process.env, ENVFILE: '.env' },
      stdio: 'pipe',
    });
    const main = path.join(root, 'main.cpp');
    fs.writeFileSync(main, [
      '#include <iostream>',
      '#include "RNCConfigValues.h"',
      '#define REACT_CONSTANT(name)',
      'struct ModuleConstants {',
      '#include "RNCConfigValuesModule.inc.g.h"',
      '};',
      'int main() {',
      ...fixtures.flatMap(fixture => [
        `std::cout << ReactNativeConfig::${fixture.key} << "\\n";`,
        `std::cout << ModuleConstants::${fixture.key} << "\\n";`,
      ]),
      '}',
    ].join('\n'));
    const executable = path.join(root, process.platform === 'win32' ? 'constants.exe' : 'constants');
    execFileSync('clang++', ['-std=c++17', '-Werror', '-I', path.join(out, 'Generated Files'), main, '-o', executable], {
      stdio: 'pipe',
    });
    const actual = execFileSync(executable, { encoding: 'utf8' }).replace(/\r\n/g, '\n').split('\n');
    assert.equal(actual.pop(), '');
    assert.equal(actual.length, fixtures.length * 2);
    for (const [index, fixture] of fixtures.entries()) {
      await t.test(fixture.key, () => {
        assert.equal(actual[index * 2], fixture.value, 'namespace constant');
        assert.equal(actual[index * 2 + 1], fixture.value, 'module constant');
      });
    }
  } finally {
    fs.rmSync(root, { recursive: true, force: true });
  }
});
