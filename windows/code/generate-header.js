const fs = require('fs')
const path = require('path')
const readline = require('readline')

const envFile = path.join(process.argv[2], '..', process.env['ENVFILE'] || '.env')
const outDir = path.join(process.argv[3], 'Generated Files')

console.log(`Generating files in ${outDir} from ${envFile} env file`)

if (!fs.existsSync(outDir)) {
  fs.mkdirSync(outDir)
}

if (fs.existsSync(envFile)) {
  const vars = []
  const regex = /^\s*(?:export\s+|)([\w\d\.\-_]+)\s*=\s*['"]?(.*?)?['"]?\s*$/
  readline.createInterface({
    input: fs.createReadStream(envFile),
    console: false
  }).on('line', (line)=>{
    const matches = line.match(regex)
    if (matches)
      vars.push({key: matches[1], value: matches[2]})
  }).on('close', ()=> {
    generateFiles(vars)
  });
} else {
  console.warn(`waring: env file ${envFile} does not exit`)
  generateFiles([])
}

function generateFiles(vars) {
  // Native code
  let nativeCode = '';
  // React Native Module code: attribute-based constants block
  let rnCode = '';
  // Snippets for building a JS object with all constants
  let objectBuilder = '';
  nativeCode += '#include<string>\n'
  nativeCode += 'namespace ReactNativeConfig {\n'
  for (let {key, value} of vars) {
    const escaped = escapeString(value)
    nativeCode += `  inline static std::string ${key} = ${escaped};\n`
    rnCode += `REACT_CONSTANT(${key});\n`
    rnCode += `static inline const std::string ${key} = ${escaped};\n`;
    objectBuilder += `  obj["${key}"] = ReactNativeConfig::${key};\n`;
  }
  nativeCode +='}\n'
  updateFile(nativeCode, path.join(outDir, 'RNCConfigValues.h'))
  updateFile(rnCode, path.join(outDir, 'RNCConfigValuesModule.inc.g.h'))
  updateFile(objectBuilder, path.join(outDir, 'RNCConfigValuesObject.inc.g.h'))
}

// Keep printable ASCII readable and encode all other UTF-8 bytes numerically.
function escapeString(string = '') {
  const bytes = Buffer.from(string, 'utf8');
  let escaped = '"';
  for (const byte of bytes) {
    // Quotes and backslashes affect C++ syntax; question marks can form trigraphs.
    if (byte >= 0x20 && byte <= 0x7e && byte !== 0x22 && byte !== 0x5c && byte !== 0x3f) {
      escaped += String.fromCharCode(byte);
    } else {
      // Three digits prevent an adjacent digit from extending the escape.
      escaped += '\\' + byte.toString(8).padStart(3, '0');
    }
  }
  escaped += '"';
  // An explicit byte count preserves embedded NULs as part of the string.
  return `std::string(${escaped}, ${bytes.length})`;
}

// Make sure to not alter mtime of a file if its content did not change
function updateFile(content, filename) {
  if (!fs.existsSync(filename) || fs.readFileSync(filename) != content) {
    fs.writeFileSync(filename, content)
    console.log(`Written ${filename}`)
  } else {
    console.log(`Skipped ${filename} since content was not changed`)
  }
}
