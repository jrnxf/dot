// A reply drawn by leaf while it streams: which part of it is ready to draw, and how leaf's lines
// are handed to Claude Code, whose own markdown drawing reads everything a stream shows.

const SGR = /(\x1b\[[0-9;]*m)/
const FENCE = /^\s*(`{3,}|~{3,})(.*)$/

// What every line the mod hands to the stream starts with. A reply's own markdown never holds it.
export const RESET = '\x1b[0m'

// Where the block still being written starts: the last whole line that follows a blank line and is
// not inside a code fence. Everything before it is finished; 0 when the reply is still its first block.
export function openBlockStart(raw: string) {
  let fence: string | undefined
  let start = 0
  let isAfterBlank = false
  let at = 0
  for (let eol = raw.indexOf('\n'); eol !== -1; eol = raw.indexOf('\n', at)) {
    const line = raw.slice(at, eol)
    const mark = FENCE.exec(line)
    if (fence !== undefined) {
      // Only a fence of the same mark, at least as long and with nothing after it, closes a code block.
      if (mark !== null && mark[1]![0] === fence[0] && mark[1]!.length >= fence.length && mark[2]!.trim() === '') fence = undefined
    } else if (line.trim() === '') isAfterBlank = true
    else {
      if (isAfterBlank) start = at
      isAfterBlank = false
      if (mark !== null) fence = mark[1]
    }
    at = eol + 1
  }

  return start
}

// leaf's output as lines, with no empty rows after the last drawn one.
export const ansiLines = (stdout: string) => {
  const body = stdout.replace(/\n+$/, '')

  return body === '' ? [] : body.split('\n')
}

export const isPrefix = (head: readonly string[], whole: readonly string[]) =>
  head.length <= whole.length && head.every((line, i) => line === whole[i])

// leaf's lines as text Claude Code's markdown leaves alone: all punctuation escaped, since a mark, a
// tag, an entity and a bare address are each read as markdown, and every line, an empty one too,
// opened by a reset code, so indents stay and no line starts or ends a markdown block.
export const literal = (lines: readonly string[]) =>
  lines
    .map(
      line =>
        RESET +
        line
          .split(SGR)
          .map((part, i) => (i % 2 === 1 ? part : part.replace(/[!-/:-@[-`{-~]/g, '\\$&')))
          .join(''),
    )
    .join('\n')
