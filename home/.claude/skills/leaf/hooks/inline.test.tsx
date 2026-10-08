import { expect, test } from 'claude-code/testing'
import type { On } from 'claude-code'
import type { Engine } from 'claude-code/testing'

const ESC = '\x1b'
const REPLY = { plugin: 'leaf', surface: 'terminal', component: 'AssistantMessage' } as const
const props = (text: string) => ({ text, isFirstOfReply: true })
const viewport = (columns: number) => ({ columns, rows: 40 })

// The engine beneath the mod: leaf itself, which can fail or never answer, and the reply it draws unaided.
function world(on: On, outcome: 'ok' | 'fails' | 'missing' = 'ok') {
  const seen = { runs: [] as { argv: readonly string[]; stdin?: string; timeoutMs?: number }[] }
  on('process.run', ($, e) => {
    seen.runs.push({ argv: e.argv, stdin: e.init?.stdin, timeoutMs: e.init?.timeoutMs })
    if (outcome === 'missing') return { deny: 'Executable not found in $PATH: "leaf"' }
    const stdout = `${ESC}[38;2;140;190;255;1mDrawn by leaf${ESC}[0m\n`
    return {
      value: { exitCode: outcome === 'ok' ? 0 : 3, stdout, stderr: '', isStdoutTruncated: false, isStderrTruncated: false },
    }
  })
  on('ui.render', ($, e) => {
    const { Text } = $.ui.resolve(e)
    return <Text>Drawn by Claude Code</Text>
  })

  return seen
}

const draw = async ($: Engine, text: string, columns = 62) => {
  const ui = await $.ui.mount({ ...REPLY, props: props(text), viewport: viewport(columns) })
  const isLeaf = (await ui.find({ type: 'Text', text: /^Drawn by leaf$/ })) !== undefined
  const isEngine = (await ui.find({ type: 'Text', text: /^Drawn by Claude Code$/ })) !== undefined
  await ui.unmount()

  return { isLeaf, isEngine }
}

test('off, the default: leaf is never run and the reply draws as usual', async ($, on) => {
  const seen = world(on)

  expect(await draw($, '# Hi')).toEqual({ isLeaf: false, isEngine: true })
  expect(seen.runs).toEqual([])
})

test('inlineReplies off, set by hand, is the same as the default', { options: { inlineReplies: 'off' } }, async ($, on) => {
  const seen = world(on)

  expect(await draw($, '# Hi')).toEqual({ isLeaf: false, isEngine: true })
  expect(seen.runs).toEqual([])
})

test('all: the reply is piped to leaf at the transcript width less the bullet', { options: { inlineReplies: 'all' } }, async ($, on) => {
  const seen = world(on)

  expect(await draw($, '# Hi')).toEqual({ isLeaf: true, isEngine: false })
  expect(seen.runs).toEqual([{ argv: ['leaf', '--inline', 'ansi:60'], stdin: '# Hi', timeoutMs: 5_000 }])
})

test('all: leaf exiting non-zero leaves the reply to Claude Code', { options: { inlineReplies: 'all' } }, async ($, on) => {
  world(on, 'fails')

  expect(await draw($, '# Hi')).toEqual({ isLeaf: false, isEngine: true })
})

test('all: leaf missing leaves the reply to Claude Code', { options: { inlineReplies: 'all' } }, async ($, on) => {
  world(on, 'missing')

  expect(await draw($, '# Hi')).toEqual({ isLeaf: false, isEngine: true })
})

test('all: a reply is rendered once per text and width, even when it fails', { options: { inlineReplies: 'all' } }, async ($, on) => {
  const seen = world(on)

  await draw($, '# Cached')
  await draw($, '# Cached')
  expect(seen.runs).toHaveLength(1)

  await draw($, '# Cached', 42)
  await draw($, '# Another')
  expect(seen.runs.map(run => [run.argv[2], run.stdin])).toEqual([
    ['ansi:60', '# Cached'],
    ['ansi:40', '# Cached'],
    ['ansi:60', '# Another'],
  ])
})

test('all: a failed render is kept too, so a broken leaf is not run again for the same reply', { options: { inlineReplies: 'all' } }, async ($, on) => {
  const seen = world(on, 'fails')

  await draw($, '# Hi')
  await draw($, '# Hi')
  expect(seen.runs).toHaveLength(1)
})
