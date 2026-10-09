import { expect, test } from 'claude-code/testing'
import type { Engine } from 'claude-code/testing'
import type { On, PaneOpenArgs, UiScrollInput } from 'claude-code'

const PANE = { plugin: 'mkd', surface: 'terminal', component: 'Pane', requestId: 'mkd' } as const
// A pane 60 columns wide showing 12 rows: the two pinned ones, then 10 of the reply.
const props = (placement: 'dock' | 'inline' = 'dock') => ({
  title: 'Markdown',
  isFocused: false,
  bodyColumns: 60,
  placement,
  scroll: { offset: 0, bodyRows: 12 },
  view: {},
})

// `/mkd` as the person types it at the prompt: of a wide fullscreen terminal unless said otherwise.
const mkd = (presentation = { isFullscreen: true, columns: 170 }) => ({
  command: 'mkd',
  args: '',
  origin: { kind: 'composer' as const },
  presentation,
})

const answer = (text: string, agentId?: string) =>
  ({ answer: text, durationMs: 1, isAborted: false, turnId: text, agentId }) as never

// The person's scroll of the pane, as the engine raises it before anything moves.
const scroll = (by: number, contentRows = 20): UiScrollInput => ({
  component: 'Pane',
  requestId: 'mkd',
  offset: Math.max(0, by),
  by,
  bodyRows: 12,
  contentRows,
  origin: { kind: 'person' },
})

const long = (rows: number) => Array.from({ length: rows }, (_, i) => `row ${i + 1}`).join('\n')

// The engine beneath the mod: its panes, the conversation, and a leaf that prints what it is given.
function world(on: On, leaf: 'prints' | 'fails' | 'missing' = 'prints') {
  const seen = {
    opens: [] as PaneOpenArgs[],
    isOpen: false,
    isPlaced: true,
    runs: [] as { argv: readonly string[]; stdin?: string }[],
    messages: [] as { role: 'user' | 'assistant'; text: string; toolUses: []; toolResults?: never[] }[],
  }
  on('ui.open', ($, e) => {
    seen.opens.push(e)
    seen.isOpen = true
    return { value: seen.isPlaced ? { isPlaced: true } : { isPlaced: false, reason: 'narrow' } }
  })
  on('ui.close', () => {
    seen.isOpen = false
    return { value: undefined }
  })
  on('ui.panes', () => ({
    value: seen.isOpen ? [{ id: 'mkd', title: 'Markdown', isShown: true, isFocused: false, isPlaced: seen.isPlaced }] : [],
  }))
  on('session.messages', () => ({ value: seen.messages }))
  on('process.run', ($, e) => {
    seen.runs.push({ argv: e.argv, stdin: e.init?.stdin })
    if (leaf === 'missing') return { deny: 'spawn leaf ENOENT' }
    const failed = leaf === 'fails'

    return {
      value: {
        exitCode: failed ? 2 : 0,
        stdout: failed ? '' : `${e.init?.stdin ?? ''}\n`,
        stderr: failed ? 'bad input' : '',
        isStdoutTruncated: false,
        isStderrTruncated: false,
      },
    }
  })
  on('turn.complete', ($, e) => ({ text: e.answer }))
  on('command.run', () => ({ text: '' }))

  return seen
}

// What the pane draws now: its pinned position line, and the reply's rows in the window.
async function drawn($: Engine, placement: 'dock' | 'inline' = 'dock') {
  const ui = await $.ui.mount({ ...PANE, props: props(placement) })
  const texts = (await ui.findAll({ type: 'Text' })).map(one => ({ text: one.text, wrap: one.props.wrap }))
  await ui.unmount()

  return {
    head: texts.find(one => /^Reply \d+ of \d+/.test(one.text))?.text.trim(),
    rows: texts.filter(one => one.wrap === 'truncate-end').map(one => one.text),
    all: texts.map(one => one.text),
  }
}

// The person's press of one of the pane's two buttons, by its key.
async function press($: Engine, key: 'previous' | 'next') {
  const ui = await $.ui.mount({ ...PANE, props: props() })
  await ui.press({ key })
  await ui.unmount()
}

test('/mkd opens the pane on the last reply, drawn by leaf at the pane width, and a second /mkd closes it', async ($, on) => {
  const seen = world(on)
  await $.turn.complete(answer('# One'))
  await $.turn.complete(answer('# Two'))

  expect((await $.command.run(mkd())).text).toBe('Markdown panel shown')
  expect(seen.opens).toEqual([{ id: 'mkd', title: 'Markdown' }])
  expect(await drawn($)).toMatchObject({ head: 'Reply 2 of 2', rows: ['# Two'] })
  expect(seen.runs).toEqual([{ argv: ['leaf', '--inline', 'ansi:59'], stdin: '# Two' }])

  expect((await $.command.run(mkd())).text).toBe('Markdown panel hidden')
  expect(seen.isOpen).toBe(false)
  expect(seen.opens).toHaveLength(1)

  await $.command.run(mkd())
  expect(seen.isOpen).toBe(true)
  expect(seen.opens).toHaveLength(2)
})

test('a pane the person closed is opened by the next /mkd, not closed again', async ($, on) => {
  const seen = world(on)
  await $.turn.complete(answer('# One'))
  await $.command.run(mkd())
  seen.isOpen = false

  expect((await $.command.run(mkd())).text).toBe('Markdown panel shown')
  expect(seen.isOpen).toBe(true)
})

test('a fullscreen terminal under 110 columns is asked to widen and nothing opens, as /diff answers', async ($, on) => {
  const seen = world(on)
  await $.turn.complete(answer('# One'))

  expect((await $.command.run(mkd({ isFullscreen: true, columns: 109 }))).text).toMatch(/at least 110 columns/)
  expect(seen.opens).toEqual([])

  await $.command.run(mkd({ isFullscreen: true, columns: 110 }))
  expect(seen.opens).toHaveLength(1)
})

test('a pane the engine leaves waiting undrawn is withdrawn, so no later resize seats it', async ($, on) => {
  const seen = world(on)
  seen.isPlaced = false

  expect((await $.command.run(mkd())).text).toMatch(/at least 110 columns/)
  expect(seen.isOpen).toBe(false)
})

test('on the main screen /mkd opens a focused dialog as tall as the reply, which Escape closes', async ($, on) => {
  const seen = world(on)
  await $.turn.complete(answer(long(5)))

  expect((await $.command.run(mkd({ isFullscreen: false, columns: 80 }))).text).toBeUndefined()
  expect(seen.opens).toEqual([{ id: 'mkd', title: 'Markdown', focus: true, closeOnEscape: true, rows: 7 }])

  // A longer reply arrives: the dialog is fitted to it and still closes on Escape, the keyboard left alone.
  await drawn($, 'inline')
  await $.turn.complete(answer(long(9)))
  expect(seen.opens[1]).toEqual({ id: 'mkd', title: 'Markdown', closeOnEscape: true, rows: 11 })

  // Paged back to the shorter reply, it shrinks to that one.
  const ui = await $.ui.mount({ ...PANE, props: props('inline') })
  await ui.press({ key: 'previous' })
  await ui.unmount()
  expect(seen.opens[2]).toEqual({ id: 'mkd', title: 'Markdown', closeOnEscape: true, rows: 7 })

  expect((await $.command.run(mkd({ isFullscreen: false, columns: 80 }))).text).toBe('Markdown dialog dismissed')
})

test('previous and next page through the replies and stop at either end', async ($, on) => {
  world(on)
  for (const text of ['# One', '# Two', '# Three']) await $.turn.complete(answer(text))
  await $.command.run(mkd())
  await drawn($)

  await press($, 'previous')
  expect(await drawn($)).toMatchObject({ head: 'Reply 2 of 3', rows: ['# Two'] })
  await press($, 'previous')
  await press($, 'previous')
  expect(await drawn($)).toMatchObject({ head: 'Reply 1 of 3', rows: ['# One'] })

  await press($, 'next')
  await press($, 'next')
  await press($, 'next')
  expect(await drawn($)).toMatchObject({ head: 'Reply 3 of 3', rows: ['# Three'] })
})

test('an open pane on the newest reply shows each new one; paged back, it stays where the person reads', async ($, on) => {
  world(on)
  await $.turn.complete(answer('# One'))
  await $.command.run(mkd())

  await $.turn.complete(answer('# Two'))
  expect(await drawn($)).toMatchObject({ head: 'Reply 2 of 2', rows: ['# Two'] })

  await press($, 'previous')
  await $.turn.complete(answer('# Three'))
  expect(await drawn($)).toMatchObject({ head: 'Reply 1 of 3', rows: ['# One'] })
})

test('/mkd opens on the last reply again, wherever the pane stood when it closed', async ($, on) => {
  world(on)
  await $.turn.complete(answer('# One'))
  await $.turn.complete(answer(long(40)))
  await $.command.run(mkd())
  await drawn($)
  await $.ui.scroll(scroll(1))
  await press($, 'previous')
  await $.command.run(mkd())
  await $.turn.complete(answer('# Three'))

  await $.command.run(mkd())
  expect(await drawn($)).toMatchObject({ head: 'Reply 3 of 3', rows: ['# Three'] })
})

test('a reply never opens the pane, and a subagent\'s is not a reply', async ($, on) => {
  const seen = world(on)
  await $.turn.complete(answer('# One'))
  await $.turn.complete(answer('# From a subagent', 'agent-1'))
  expect(seen.opens).toEqual([])

  await $.command.run(mkd())
  expect(await drawn($)).toMatchObject({ head: 'Reply 1 of 1', rows: ['# One'] })
})

test('before any reply the pane says so without running leaf, then shows the first one', async ($, on) => {
  const seen = world(on)

  expect((await $.command.run(mkd())).text).toBe('Markdown panel shown')
  expect((await drawn($)).all).toEqual(['No reply yet: the next one shows here.'])
  expect(seen.runs).toEqual([])

  await $.turn.complete(answer('# One'))
  expect(await drawn($)).toMatchObject({ head: 'Reply 1 of 1', rows: ['# One'] })
})

test('in a resumed session /mkd pages through each turn\'s last words, read from the conversation', async ($, on) => {
  const seen = world(on)
  const row = (role: 'user' | 'assistant', text: string, toolResults?: never[]) => ({ role, text, toolUses: [] as [], toolResults })
  seen.messages = [
    row('user', 'first ask'),
    row('assistant', 'Reading the file.'),
    row('user', '', [{} as never]),
    row('assistant', '# One'),
    row('user', 'second ask'),
    row('assistant', '# Two'),
  ]

  await $.command.run(mkd())
  expect(await drawn($)).toMatchObject({ head: 'Reply 2 of 2', rows: ['# Two'] })
  await press($, 'previous')
  expect(await drawn($)).toMatchObject({ head: 'Reply 1 of 2', rows: ['# One'] })
})

test('/clear closes the pane and forgets the old conversation\'s replies', async ($, on) => {
  const seen = world(on)
  await $.turn.complete(answer('# One'))
  await $.command.run(mkd())

  await $.command.run({ ...mkd(), command: 'clear' })
  expect(seen.isOpen).toBe(false)

  await $.command.run(mkd())
  expect((await drawn($)).all).toEqual(['No reply yet: the next one shows here.'])
})

test('the person\'s scrolls move the reply under the pinned head and leave the engine\'s window still', async ($, on) => {
  world(on)
  await $.turn.complete(answer(long(40)))
  await $.command.run(mkd())
  const top = async () => {
    const pane = await drawn($)
    expect(pane.head).toBe('Reply 1 of 1')
    expect(pane.rows).toHaveLength(10)

    return pane.rows[0]
  }
  expect(await top()).toBe('row 1')

  // A wheel tick or an arrow: three rows.
  expect(await $.ui.scroll(scroll(1))).toEqual({})
  expect(await top()).toBe('row 4')
  // A page key: the window's ten rows.
  await $.ui.scroll(scroll(12))
  expect(await top()).toBe('row 14')
  // End, then one more tick: the last ten rows, and no further.
  await $.ui.scroll(scroll(20))
  expect(await top()).toBe('row 31')
  await $.ui.scroll(scroll(1))
  expect(await top()).toBe('row 31')
  await $.ui.scroll(scroll(-1))
  expect(await top()).toBe('row 28')
  // Home, then one more tick: the top, and no further.
  await $.ui.scroll(scroll(-20))
  await $.ui.scroll(scroll(-1))
  expect(await top()).toBe('row 1')
})

test('paging to another reply starts it from its top', async ($, on) => {
  world(on)
  await $.turn.complete(answer(long(40)))
  await $.turn.complete(answer(long(30)))
  await $.command.run(mkd())
  await drawn($)
  await $.ui.scroll(scroll(12))

  await press($, 'previous')
  expect((await drawn($)).rows[0]).toBe('row 1')
})

test('a leaf that fails is said in the pane, under the head that still pages', async ($, on) => {
  world(on, 'fails')
  await $.turn.complete(answer('# One'))
  await $.turn.complete(answer('# Two'))
  await $.command.run(mkd())

  const pane = await drawn($)
  expect(pane.head).toBe('Reply 2 of 2')
  expect(pane.all).toContain('leaf failed: bad input')
  await press($, 'previous')
  expect((await drawn($)).head).toBe('Reply 1 of 2')
})

test('a missing leaf is said in the pane and run again at the next draw', async ($, on) => {
  const seen = world(on, 'missing')
  await $.turn.complete(answer('# One'))
  await $.command.run(mkd())

  expect((await drawn($)).all.some(text => /leaf could not run/.test(text))).toBe(true)
  await drawn($)
  expect(seen.runs).toHaveLength(2)
})

test('the pane body paints the conversation background on its root Box', async ($, on) => {
  world(on)
  await $.turn.complete(answer('# One'))
  await $.command.run(mkd())
  const ui = await $.ui.mount({ ...PANE, props: props() })
  const root = (await ui.findAll({ type: 'Box' }))[0]
  await ui.unmount()

  expect(root?.props.backgroundColor).toBe('#141414')
})
