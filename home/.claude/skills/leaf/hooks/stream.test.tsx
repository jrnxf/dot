import { expect, test } from 'claude-code/testing'
import type { On } from 'claude-code'
import type { Engine } from 'claude-code/testing'

import { literal, openEnd, RESET } from './stream'

const ESC = '\x1b'
const ALL = { options: { inlineReplies: 'all' } }
const REPLY = { plugin: 'leaf', surface: 'terminal', component: 'AssistantMessage' } as const
const BAND = { plugin: 'leaf', surface: 'terminal', component: 'AbovePrompt' } as const
const viewport = (columns: number) => ({ columns, rows: 40 })

// A leaf that draws each line of the markdown as one bold line naming the width it was asked for.
const drawn = (markdown: string, width: number) =>
  markdown
    .trimEnd()
    .split('\n')
    .map(line => (line === '' ? '' : `${ESC}[1m${width}|${line}${ESC}[0m`))
// Some of those lines, as the stream shows them.
const lines = (markdown: string, width: number, from: number, to?: number) => literal(drawn(markdown, width).slice(from, to)) + '\n'
const shownAs = (markdown: string, width: number) => lines(markdown, width, 0)

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

test('a block can still grow until a blank line ends it, and a heading is whole at once', () => {
  expect(openEnd('one\ntwo\n')).toEqual({ isOpen: true, start: 0 })
  expect(openEnd('one\n\ntwo\n')).toEqual({ isOpen: true, start: 'one\n\n'.length })
  expect(openEnd('one\n\ntwo\n\n')).toEqual({ isOpen: false, start: 'one\n\ntwo\n\n'.length })
  expect(openEnd('one\n\n## Two\n').isOpen).toBe(false)
})

test('a code block is open until its own fence closes it, blank lines and other fences inside or not', () => {
  const intro = 'intro\n\n'
  const open = intro + '````md\n```js\n\nx\n```\n\nstill code\n'
  expect(openEnd(open)).toEqual({ isOpen: true, start: intro.length })
  expect(openEnd(open + '~~~~\n')).toEqual({ isOpen: true, start: intro.length })
  expect(openEnd(open + '```` js\n')).toEqual({ isOpen: true, start: intro.length })
  expect(openEnd(open + '````\n').isOpen).toBe(false)
  expect(openEnd(open + '````\n\nafter\n')).toEqual({ isOpen: true, start: (open + '````\n\n').length })
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

test('all: lines stream in as leaf draws them, the last line of a block still growing held back', ALL, async ($, on) => {
  world(on)
  await resize($, 62)
  const reply = '# Title\n\nBody one\n\n```c\nint a;\n\nint b;\n```\n\nLast'

  const answers = [
    await batch($, '# Title\n'),
    // The paragraph can still grow: only the gap before it shows.
    await batch($, '\nBody one\n'),
    // The code block streams before its fence closes, less its last line.
    await batch($, '\n```c\nint a;\n'),
    await batch($, '\nint b;\n'),
    await batch($, '```\n'),
    await batch($, '\n'),
    await batch($, 'Last', true),
  ]

  expect(answers).toEqual([
    lines(reply, 60, 0, 1),
    lines(reply, 60, 1, 2),
    lines(reply, 60, 2, 5),
    lines(reply, 60, 5, 7),
    lines(reply, 60, 7, 9),
    '',
    lines(reply, 60, 9),
  ])
  // Batch by batch, the stream shows exactly what leaf draws for the whole reply.
  expect(answers.join('')).toBe(shownAs(reply, 60))
})

test('all: batches that overlap are answered in order, each with its own lines', ALL, async ($, on) => {
  const seen = world(on)
  await resize($, 62)
  let release!: () => void
  seen.release = new Promise<void>(resolve => (release = resolve))
  const reply = 'One\n\nTwo\n\nThree\n'

  const first = batch($, 'One\n\nTwo\n')
  const second = batch($, '\nThree\n')
  const third = batch($, '', true)
  release()

  expect(await first).toBe(lines(reply, 60, 0, 2))
  expect(await second).toBe(lines(reply, 60, 2, 4))
  expect(await third).toBe(lines(reply, 60, 4))
})

test('all: a resize mid-reply draws the next lines at the new width and repeats nothing', ALL, async ($, on) => {
  world(on)
  await resize($, 62)
  const reply = 'One\n\nTwo\n\nThree\n'
  expect(await batch($, 'One\n\nTwo\n')).toBe(lines(reply, 60, 0, 2))

  await resize($, 42)
  expect(await batch($, '\nThree\n')).toBe(lines(reply, 40, 2, 4))
  expect(await batch($, '', true)).toBe(lines(reply, 40, 4))
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

  expect(first).toBe(lines(reply, 60, 0, 2))
  // Nothing of the reply is lost: the block leaf had not drawn whole is shown as it was written.
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

  expect(await batch($, 'One\n\nTwo\n', false, 'a')).toBe(lines('One\n\nTwo', 60, 0, 2))
  expect(await batch($, 'Uno\n\nDos\n', false, 'b')).toBe(lines('Uno\n\nDos', 60, 0, 2))
  expect(await batch($, '', true, 'a')).toBe(lines('One\n\nTwo', 60, 2))
  expect(await batch($, '', true, 'b')).toBe(lines('Uno\n\nDos', 60, 2))
})
