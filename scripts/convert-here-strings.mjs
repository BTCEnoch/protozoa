#!/usr/bin/env node
/**
 * convert-here-strings.mjs
 * ---------------------------------------------------------------------------
 * Scans every PowerShell script (*.ps1) under the ./scripts directory and
 * converts double-quoted HERE-STRING blocks (@" ... "@) to single-quoted
 * equivalents (@' ... '@).  This prevents PowerShell from attempting to parse
 * embedded TypeScript / JSON content that contains single & double quotes and
 * eliminates the ubiquitous "parameter name 'and'" errors.
 *
 * Usage:
 *   node scripts/convert-here-strings.mjs        # apply changes in-place
 *   node scripts/convert-here-strings.mjs --dry  # preview only (no writes)
 *
 * The script is idempotent – running it multiple times will make no further
 * modifications after the first successful pass.
 * ---------------------------------------------------------------------------
 */
import fs from 'node:fs'
import path from 'node:path'
import process from 'node:process'

const ROOT = path.resolve(process.cwd(), 'scripts')
const DRY_RUN = process.argv.includes('--dry') || process.argv.includes('-d')

/**
 * Reads a text file and returns its line array (preserving CRLF when present).
 */
function readLines (file) {
  const raw = fs.readFileSync(file, 'utf8')
  // keep both \r\n and \n endings intact so we can re-join later
  const parts = raw.split(/\r?\n/)
  return { lines: parts, newline: raw.includes('\r\n') ? '\r\n' : '\n' }
}

/**
 * Determines if a line marks the start of a double-quoted HERE-STRING.
 */
function isStart (line) {
  return /^\s*\$[A-Za-z0-9_]+\s*=\s*@"\s*$/.test(line)
}

/**
 * Determines if a line marks the end of a double-quoted HERE-STRING.
 */
function isEnd (line) {
  return /^"@\s*$/.test(line)
}

/**
 * Transforms a .ps1 file in-memory; returns null when no change required.
 */
function transform (file) {
  const { lines, newline } = readLines(file)
  let changed = false
  let inHere = false

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]
    if (!inHere && isStart(line)) {
      lines[i] = line.replace(/@"\s*$/, "@'")
      inHere = true
      changed = true
      continue
    }
    if (inHere && isEnd(line)) {
      lines[i] = line.replace(/^"@/, "'@")
      inHere = false
      continue
    }
    if (inHere) {
      // escape single quotes
      const esc = line.replace(/'/g, "''")
      if (esc !== line) {
        lines[i] = esc
        changed = true
      }
    }
  }

  if (changed) {
    return lines.join(newline)
  }
  return null
}

function walk (dir, cb) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const res = path.resolve(dir, entry.name)
    if (entry.isDirectory()) {
      walk(res, cb)
    } else if (entry.isFile() && res.endsWith('.ps1') && res !== path.resolve(ROOT, 'convert-here-strings.mjs')) {
      cb(res)
    }
  }
}

let filesScanned = 0
let filesModified = 0
let blocksConverted = 0 // not tracked exactly but approximated by changed files

walk(ROOT, (file) => {
  filesScanned++
  const output = transform(file)
  if (output !== null) {
    filesModified++
    blocksConverted++
    if (!DRY_RUN) {
      fs.writeFileSync(file, output, 'utf8')
      console.log(`✓ converted ${path.relative(process.cwd(), file)}`)
    } else {
      console.log(`[dry] would convert ${path.relative(process.cwd(), file)}`)
    }
  }
})

console.log('\n―― conversion summary ――')
console.log(`files scanned   : ${filesScanned}`)
console.log(`files modified  : ${filesModified}`)
console.log(`blocks converted: ~${blocksConverted}`)
console.log(DRY_RUN ? '\nRun again without --dry to apply changes.' : '\nAll done!')