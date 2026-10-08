import { expect, test } from 'claude-code/testing'
import type { On } from 'claude-code'

const ESC = '\x1b'
const PANE = { plugin: 'leaf', surface: 'terminal', component: 'Pane', requestId: 'leaf' } as const
const props = (offset = 0, bodyRows = 10) => ({
  title: 'leaf',
  isFocused: false,
  bodyColumns: 60,
  placement: 'dock' as const,
  scroll: { offset, bodyRows },
  view: {},
})

// `/leaf <args>` as the person types it at the prompt of a fullscreen terminal.
const leaf = (args: string) => ({
  command: 'leaf',
  args,
  origin: { kind: 'composer' as const },
  presentation: { isFullscreen: true, columns: 170 },
})

// The engine beneath the mod: its panes, the paths that exist, and leaf itself.
function world(
  on: On,
  stdout = `${ESC}[38;2;140;190;255;1mTitle${ESC}[0m\nbody\n`,
  exitCode = 0,
  isStdoutTruncated = false,
) {
  const kinds: Record<string, 'file' | 'dir' | 'other'> = { 'notes.md': 'file', docs: 'dir', 'dangling.md': 'other' }
  const seen = {
    opens: [] as string[],
    isOpen: false,
    runs: [] as { argv: readonly string[]; stdin?: string }[],
  }
  on('ui.open', ($, e) => {
    seen.opens.push(e.title ?? e.id)
    seen.isOpen = true
    return { value: { isPlaced: true } }
  })
  on('ui.panes', () => ({
    value: seen.isOpen ? [{ id: 'leaf', title: 'leaf', isShown: true, isFocused: false, isPlaced: true }] : [],
  }))
  on('fs.stat', ($, e) => {
    const kind = kinds[e.path.slice(e.path.lastIndexOf('/') + 1)]

    return kind === undefined ? { deny: 'no such file' } : { value: { kind, size: 1, mtimeMs: 0, isLink: kind === 'other' } }
  })
  on('process.run', ($, e) => {
    seen.runs.push({ argv: e.argv, stdin: e.init?.stdin })
    return { value: { exitCode, stdout, stderr: exitCode === 0 ? '' : 'bad input', isStdoutTruncated, isStderrTruncated: false } }
  })
  on('tool.call', () => ({ result: { text: 'ok', isError: false, isReadOnly: false } }))
  on('turn.complete', ($, e) => ({ text: e.answer }))

  return seen
}

test('/leaf <file> opens the pane and draws what leaf rendered at the pane width', async ($, on) => {
  const seen = world(on)

  const ran = await $.command.run(leaf('notes.md'))
  expect(ran.text).toBe('Showing notes.md')
  expect(seen.opens).toEqual(['notes.md'])

  const ui = await $.ui.mount({ ...PANE, props: props() })
  expect(seen.runs).toEqual([{ argv: ['leaf', '--inline', 'ansi:60', 'notes.md'], stdin: undefined }])
  expect((await ui.find({ type: 'Text', text: /^Title$/ }))?.children[0]).toMatchObject({
    props: { color: '#8cbeff', bold: true },
  })
  expect(await ui.find({ type: 'Text', text: /^body$/ })).toBeDefined()
  await ui.unmount()
})

test('/leaf <file> names a missing file and opens nothing', async ($, on) => {
  const seen = world(on)

  expect((await $.command.run(leaf('gone.md'))).text).toBe('No such file: gone.md')
  expect(seen.opens).toEqual([])
})

test('/leaf <path> refuses a folder and a link that leads nowhere, and opens nothing', async ($, on) => {
  const seen = world(on)

  expect((await $.command.run(leaf('docs'))).text).toBe('Not a file: docs')
  expect((await $.command.run(leaf('dangling.md'))).text).toBe('Not a file: dangling.md')
  expect(seen.opens).toEqual([])
})

test('bare /leaf answers with the usage line and shows nothing, even after a document', async ($, on) => {
  const seen = world(on)
  await $.command.run(leaf('notes.md'))

  expect((await $.command.run(leaf(''))).text).toBe('Usage: /leaf <file.md>, /leaf reply')
  expect(seen.opens).toEqual(['notes.md'])
})

test('/leaf reply pipes the last reply to leaf, and says so when there is none', async ($, on) => {
  const seen = world(on)

  expect((await $.command.run(leaf('reply'))).text).toBe('No reply to show yet.')
  expect(seen.opens).toEqual([])

  await $.turn.complete({ answer: '# Hello', durationMs: 1, isAborted: false, turnId: 't1' } as never)
  expect((await $.command.run(leaf('reply'))).text).toBe('Showing the last reply.')
  const ui = await $.ui.mount({ ...PANE, props: props() })
  expect(seen.runs).toEqual([{ argv: ['leaf', '--inline', 'ansi:60'], stdin: '# Hello' }])
  await ui.unmount()
})

test('a markdown file Claude writes never opens the pane', async ($, on) => {
  const seen = world(on)

  await $.tool.call({ tool: 'Write', tool_use_id: 'w1', file_path: '/repo/plan.md', content: '# Plan' } as never)
  expect(seen.opens).toEqual([])
})

test('an open pane follows the markdown files Claude writes and edits, and no other file', async ($, on) => {
  const seen = world(on)
  await $.command.run(leaf('notes.md'))

  await $.tool.call({ tool: 'Write', tool_use_id: 'w1', file_path: '/repo/plan.md', content: '# Plan' } as never)
  await $.tool.call({ tool: 'Edit', tool_use_id: 'e1', file_path: '/repo/todo.md', old_string: 'a', new_string: 'b' } as never)
  await $.tool.call({ tool: 'Write', tool_use_id: 'w2', file_path: '/repo/main.rs', content: 'fn main() {}' } as never)
  expect(seen.opens).toEqual(['notes.md', 'plan.md', 'todo.md'])

  const ui = await $.ui.mount({ ...PANE, props: props() })
  expect(seen.runs.at(-1)?.argv).toEqual(['leaf', '--inline', 'ansi:60', '/repo/todo.md'])
  await ui.unmount()
})

test('a pane the person closed stops following and is not opened again', async ($, on) => {
  const seen = world(on)
  await $.command.run(leaf('notes.md'))
  seen.isOpen = false

  await $.tool.call({ tool: 'Write', tool_use_id: 'w1', file_path: '/repo/plan.md', content: '# Plan' } as never)
  expect(seen.opens).toEqual(['notes.md'])
})

test('struck text is drawn struck', async ($, on) => {
  world(on, `${ESC}[9mdone${ESC}[0m\n`)
  await $.command.run(leaf('notes.md'))

  const ui = await $.ui.mount({ ...PANE, props: props() })
  expect((await ui.find({ type: 'Text', text: /^done$/ }))?.children[0]).toMatchObject({ props: { strikethrough: true } })
  await ui.unmount()
})

test('a long document is drawn whole: every row is reachable by scrolling', async ($, on) => {
  const total = 2000
  world(on, Array.from({ length: total }, (_, i) => `row ${i + 1}`).join('\n') + '\n')
  await $.command.run(leaf('notes.md'))

  const top = await $.ui.mount({ ...PANE, props: props(0) })
  expect(await top.find({ type: 'Text', text: /^row 1$/ })).toBeDefined()
  expect(await top.find({ type: 'Text', text: /^row 2000$/ })).toBeUndefined()
  await top.unmount()

  const end = await $.ui.mount({ ...PANE, props: props(total - 10) })
  expect(await end.find({ type: 'Text', text: /^row 2000$/ })).toBeDefined()
  expect(await end.find({ type: 'Text', text: /^row 1$/ })).toBeUndefined()
  await end.unmount()
})

test('a render cut at the output limit loses its broken last row and ends by saying so', async ($, on) => {
  world(on, `row 1\nrow 2\nrow 3 ${ESC}[38;2;14`, 0, true)
  await $.command.run(leaf('notes.md'))

  const ui = await $.ui.mount({ ...PANE, props: props() })
  const rows = (await ui.findAll({ type: 'Text' })).filter(row => row.props.wrap === 'truncate-end').map(row => row.text)
  expect(rows).toEqual(['row 1', 'row 2', 'leaf wrote more than 4 MiB: the render is cut here.'])
  await ui.unmount()
})

test('a leaf that fails is said in the pane', async ($, on) => {
  world(on, '', 2)
  await $.command.run(leaf('notes.md'))

  const ui = await $.ui.mount({ ...PANE, props: props() })
  expect(await ui.find({ type: 'Text', text: 'leaf failed: bad input' })).toBeDefined()
  await ui.unmount()
})
