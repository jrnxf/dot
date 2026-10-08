import { expect, test } from 'claude-code/testing'
import type { On } from 'claude-code'
import type { Engine } from 'claude-code/testing'

import { literal, openBlockStart, RESET } from './stream'

const ESC = '\x1b'
const ALL = { options: { inlineReplies: 'all' } }
const REPLY = { plugin: 'leaf', surface: 'terminal', component: 'AssistantMessage' } as const
const BAND = { plugin: 'leaf', surface: 'terminal', component: 'AbovePrompt' } as const
const viewport = (columns: number) => ({ columns, rows: 40 })

// A leaf that draws each line of the markdown as one bold line naming the width it was asked for.
// Like the real one, it draws the start of a document as it draws that start alone, until the
// markdown says LOOSE: then the first line changes, as a list does when it turns loose.
const drawn = (markdown: string, width: number) =>
  markdown
    .trimEnd()
    .split('\n')
    .map((line, i) => (line === '' ? '' : `${ESC}[1m${width}|${i === 0 && markdown.includes('LOOSE') ? 'loose ' : ''}${line}${ESC}[0m`))
const shownAs = (markdown: string, width: number, from = 0) => literal(drawn(markdown, width).slice(from)) + '\n'

// The engine beneath the mod: leaf, which can stop working or be slow, and the reply it draws unaided.
function world(on: On) {
  const seen = {
    runs: [] as { width: number; stdin: string }[],
    engineTexts: [] as string[],
    isBroken: false,
    // Set to hold every leaf run until it is called.
    release: undefined as Promise<void> | undefined,
  }
  on('process.run', async ($, e) => {
    const width = Number(e.argv[2]?.slice('ansi:'.length))
    const stdin = e.init?.stdin ?? ''
    seen.runs.push({ width, stdin })
    await seen.release
    if (seen.isBroken) return { deny: 'Executable not found in $PATH: "leaf"' }

    return {
      value: { exitCode: 0, stdout: drawn(stdin, width).join('\n') + '\n', stderr: '', isStdoutTruncated: false, isStderrTruncated: false },
    }
  })
  on('classic.MessageDisplay', () => ({}))
  on('ui.render', ($, e) => {
    const { Text } = $.ui.resolve(e)
    if (e.component === 'AssistantMessage') seen.engineTexts.push(e.props.text)

    return <Text>Drawn by Claude Code</Text>
  })

  return seen
}

let index = 0
const batch = async ($: Engine, delta: string, final = false, message_id = 'm1') => {
  const answer = await $.classic.MessageDisplay({ turn_id: 't1', message_id, index: index++, final, delta })

  // No answer is Claude Code showing the batch as it came.
  return answer.displayContent ?? delta
}

// The transcript's width reaches the mod with the band above the prompt, drawn again on a resize.
const resize = async ($: Engine, columns: number) => {
  const ui = await $.ui.mount({
    ...BAND,
    props: { hasSurvey: false, isWorking: true, maxRows: 10, bodyColumns: columns, scroll: { offset: 0, bodyRows: 10 }, view: {} },
    viewport: viewport(columns),
  })
  await ui.unmount()
}

const settle = async ($: Engine, text: string, columns = 62) => {
  const ui = await $.ui.mount({ ...REPLY, props: { text, isFirstOfReply: true }, viewport: viewport(columns) })
  const isEngine = (await ui.find({ type: 'Text', text: /^Drawn by Claude Code$/ })) !== undefined
  await ui.unmount()

  return isEngine
}

test('the open block starts after the last blank line, and a blank line inside a code fence is not one', () => {
  expect(openBlockStart('one\ntwo\n')).toBe(0)
  expect(openBlockStart('one\n\ntwo\nthree\n')).toBe('one\n\n'.length)
  // The last line has not ended, so it is not yet a block of its own.
  expect(openBlockStart('one\n\ntwo\n\nthr')).toBe('one\n\n'.length)

  const fenced = 'intro\n\n```c\nint a;\n\nint b;\n'
  expect(openBlockStart(fenced)).toBe('intro\n\n'.length)
  expect(openBlockStart(fenced + '```\n\nafter\n')).toBe((fenced + '```\n\n').length)
})

test('a code fence is closed only by its own mark, at least as long, with nothing after it', () => {
  const open = 'intro\n\n````md\n```js\n\nx\n```\n\nstill code\n'
  expect(openBlockStart(open)).toBe('intro\n\n'.length)
  expect(openBlockStart(open + '~~~~\n\nstill code\n')).toBe('intro\n\n'.length)
  expect(openBlockStart(open + '````\n\nafter\n')).toBe((open + '````\n\n').length)
})

test("leaf's lines reach Claude Code's markdown with all punctuation escaped and every color code whole", () => {
  const line = `${ESC}[38;2;1;2;3m# a*b_c ${ESC}[0m[x](y) <t> \`q\` ~s~ |p| &amp; \\ https://a.b me@c.d 1. - +`

  expect(literal([line, '', '    indented'])).toBe(
    [
      `${RESET}${ESC}[38;2;1;2;3m\\# a\\*b\\_c ${ESC}[0m\\[x\\]\\(y\\) \\<t\\> \\\`q\\\` \\~s\\~ \\|p\\| \\&amp\\; \\\\ https\\:\\/\\/a\\.b me\\@c\\.d 1\\. \\- \\+`,
      // An empty line and an indented one must not end the paragraph or start a code block.
      RESET,
      `${RESET}    indented`,
    ].join('\n'),
  )
})

test('off, the default: a streaming reply is left to Claude Code and leaf is never run', async ($, on) => {
  const seen = world(on)

  expect(await batch($, '# Title\n\nBody\n')).toBe('# Title\n\nBody\n')
  expect(seen.runs).toEqual([])
})

test('all: each finished block streams in as leaf drew it, and a code block waits until it is whole', ALL, async ($, on) => {
  world(on)
  await resize($, 62)
  const reply = '# Title\n\nBody one\n\n```c\nint a;\n\nint b;\n```\n\nLast'

  const answers = [
    // The first block is still open: nothing to show.
    await batch($, '# Title\n'),
    await batch($, '\nBody one\n'),
    // The code block opens, which finishes the paragraph before it.
    await batch($, '\n```c\nint a;\n'),
    await batch($, '\nint b;\n'),
    await batch($, '```\n'),
    await batch($, '\n'),
    await batch($, 'Last', true),
  ]

  expect(answers).toEqual([
    '',
    shownAs('# Title', 60),
    literal(['', ...drawn('Body one', 60)]) + '\n',
    '',
    '',
    '',
    literal(['', ...drawn('```c\nint a;\n\nint b;\n```\n\nLast', 60)]) + '\n',
  ])
  // Batch by batch, the stream shows exactly what leaf draws for the whole reply.
  expect(answers.join('')).toBe(shownAs(reply, 60))
})

test('all: a block whose drawing the next lines change is held until they have arrived', ALL, async ($, on) => {
  world(on)
  await resize($, 62)

  expect(await batch($, '- a\n- b\n\n  LOOSE\n')).toBe('')
  expect(await batch($, '\nAfter\n')).toBe(shownAs('- a\n- b\n\n  LOOSE', 60))
})

test('all: batches that overlap are answered in order, each with its own lines', ALL, async ($, on) => {
  const seen = world(on)
  await resize($, 62)
  let release!: () => void
  seen.release = new Promise<void>(resolve => (release = resolve))

  const first = batch($, 'One\n\nTwo\n')
  const second = batch($, '\nThree\n')
  const third = batch($, '', true)
  release()

  expect(await first).toBe(shownAs('One', 60))
  expect(await second).toBe(literal(['', ...drawn('Two', 60)]) + '\n')
  expect(await third).toBe(literal(['', ...drawn('Three', 60)]) + '\n')
})

test('all: a resize mid-reply draws the next block at the new width and repeats nothing', ALL, async ($, on) => {
  world(on)
  await resize($, 62)
  expect(await batch($, 'One\n\nTwo\n')).toBe(shownAs('One', 60))

  await resize($, 42)
  expect(await batch($, '\nThree\n')).toBe(literal(['', ...drawn('Two', 40)]) + '\n')
  expect(await batch($, '', true)).toBe(literal(['', ...drawn('Three', 40)]) + '\n')
})

test('all: the settled row of a streamed reply is drawn by leaf from the markdown, at the row width', ALL, async ($, on) => {
  const seen = world(on)
  await resize($, 62)
  const reply = '# Title\n\nBody *one*\n'
  const shown = (await batch($, '# Title\n\nBody *one*\n')) + (await batch($, '', true))
  seen.runs.length = 0

  expect(await settle($, shown, 42)).toBe(false)
  expect(seen.runs).toEqual([{ width: 40, stdin: reply }])
})

test("all: a row holding the mod's own lines before the last batch landed is left to Claude Code", ALL, async ($, on) => {
  const seen = world(on)
  await resize($, 62)
  const shown = await batch($, '# Title\n\nBody\n')
  seen.runs.length = 0

  // leaf must not be handed its own drawing as if it were markdown.
  expect(await settle($, shown)).toBe(true)
  expect(seen.runs).toEqual([])
})

test('all: leaf failing mid-reply hands the rest over as markdown, and the settled row is the whole reply', ALL, async ($, on) => {
  const seen = world(on)
  await resize($, 62)
  const reply = '# Title\n\nBody one\n\nBody two\n\nLast'

  const first = await batch($, '# Title\n\nBody one\n')
  seen.isBroken = true
  const second = await batch($, '\nBody two\n')
  const last = await batch($, '\nLast', true)

  expect(first).toBe(shownAs('# Title', 60))
  // Nothing of the reply is lost: what leaf had not drawn is shown as it was written.
  expect(second).toBe('\nBody one\n\nBody two\n')
  expect(last).toBe('\nLast')

  expect(await settle($, first + second + last)).toBe(true)
  expect(seen.engineTexts.at(-1)).toBe(reply)
})

test('all: leaf missing from the first batch on shows the reply as it streams without it', ALL, async ($, on) => {
  const seen = world(on)
  seen.isBroken = true

  expect(await batch($, '# Title\n\nBody\n')).toBe('# Title\n\nBody\n')
  expect(await batch($, '\nMore\n', true)).toBe('\nMore\n')
})

test('all: two replies streaming at once keep their own text', ALL, async ($, on) => {
  world(on)
  await resize($, 62)

  expect(await batch($, 'One\n\nTwo\n', false, 'a')).toBe(shownAs('One', 60))
  expect(await batch($, 'Uno\n\nDos\n', false, 'b')).toBe(shownAs('Uno', 60))
  expect(await batch($, '', true, 'a')).toBe(literal(['', ...drawn('Two', 60)]) + '\n')
  expect(await batch($, '', true, 'b')).toBe(literal(['', ...drawn('Dos', 60)]) + '\n')
})
