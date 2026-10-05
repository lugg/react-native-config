const assert = require('node:assert/strict');
const { execFileSync, spawnSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const test = require('node:test');

const generator = path.resolve(__dirname, '../windows/code/generate-header.js');
const hasCompiler = spawnSync('clang++', ['--version']).status === 0;
const fixtures = [
  ['ASCII', 'plain-value-09'],
  ['QUOTE', 'He said "hello"'],
  ['BACKSLASH', String.raw`C:\folder\file`],
  ['BACKSLASH_QUOTE', String.raw`backslash\"quote`],
  ['JSON', '{"enabled":true}'],
  ['UNICODE', 'café 中文'],
  ['ASTRAL', 'hello 😀'],
  ['TAB', 'a\tb'],
  ['NUL', 'before\0after'],
  ['OCTAL_DIGIT', '\u0001' + '7a'],
  ['TRIGRAPH', '??/??='],
  ['EMPTY', ''],
];

for (const standard of ['c++17', 'c++20']) {
  for (const [name, value] of fixtures) {
    test(`${standard}: ${name}`, { skip: !hasCompiler }, () => {
      const root = fs.mkdtempSync(path.join(os.tmpdir(), 'rnc-string-'));
      try {
        fs.writeFileSync(path.join(root, '.env'), value === '' ? 'VALUE=\n' : `VALUE='${value}'\n`);
        const out = path.join(root, 'out');
        fs.mkdirSync(out);
        execFileSync(process.execPath, [generator, path.join(root, 'native'), out], {
          env: { ...process.env, ENVFILE: '.env' },
          stdio: 'pipe',
        });
        const main = path.join(root, 'main.cpp');
        fs.writeFileSync(main, `
#include <iomanip>
#include <iostream>
#include "RNCConfigValues.h"
#define REACT_CONSTANT(name)
struct ModuleConstants {
#include "RNCConfigValuesModule.inc.g.h"
};
void printBytes(const std::string& value) {
  for (unsigned char byte : value) {
    std::cout << std::hex << std::setfill('0') << std::setw(2) << static_cast<unsigned>(byte);
  }
  std::cout << "\\n";
}
int main() {
  printBytes(ReactNativeConfig::VALUE);
  printBytes(ModuleConstants::VALUE);
}
`);
        const executable = path.join(root, process.platform === 'win32' ? 'values.exe' : 'values');
        execFileSync('clang++', [`-std=${standard}`, '-Werror', '-I', path.join(out, 'Generated Files'), main, '-o', executable], {
          stdio: 'pipe',
        });
        const actual = execFileSync(executable, { encoding: 'utf8' }).replace(/\r\n/g, '\n');
        const expected = Buffer.from(value, 'utf8').toString('hex');
        assert.equal(actual, `${expected}\n${expected}\n`);
      } finally {
        fs.rmSync(root, { recursive: true, force: true });
      }
    });
  }
}
