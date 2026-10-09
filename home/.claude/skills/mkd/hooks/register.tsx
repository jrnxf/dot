import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { MkdPlace, MkdReply } from '../types'
import { parseAnsi } from './ansi'
import type { Run } from './ansi'

// /mkd: the replies of the conversation, one at a time, drawn by leaf in a pane that opens,
// closes, takes the keyboard and scrolls as the built-in /diff pane does.
const PANE = 'mkd'
const TITLE = 'Markdown'
// The terminal width from which /diff docks its pane beside the transcript, and its line below that.
const DOCK_MIN_COLUMNS = 110
const RESIZE = `Resize your terminal to at least ${DOCK_MIN_COLUMNS} columns to show the markdown panel`
const NO_REPLY = 'No reply yet: the next one shows here.'
const CUT: Run[] = [{ text: 'leaf wrote more than 4 MiB: the render is cut here.', color: 'warning' }]
// The rows one wheel tick or arrow moves the reply, as /diff's body moves.
const WHEEL_ROWS = 3
// The pinned rows over the reply: its position with the two buttons, and a blank row.
const HEAD_ROWS = 2
// Blank rows kept under the window, so the tree is always taller than the body and the engine has
// rows to scroll: every scroll key then reaches `ui.scroll`, which moves the reply under the head.
const SCROLL_MARGIN_ROWS = 8
const MAX_REPLIES = 50
const replies = atom({ plugin: 'mkd', key: 'replies' } as const, [] as MkdReply[])
const place = atom({ plugin: 'mkd', key: 'place' } as const, { at: 0, top: 0 } as MkdPlace)

// The latest render, for one reply at one width; a reload starts it over.
let rendered: { key: string; lines: Run[][] | string } | undefined

// The pane as last drawn: its seat, its width, and the reply's rows against the window's.
// A reload forgets it until the next draw.
let seat: { placement: 'dock' | 'inline'; bodyColumns: number; visibleRows: number; total: number } | undefined

const isOpen = async ($: EngineInterface) => (await $.ui.panes()).some(pane => pane.id === PANE)

// The body keeps a blank column at its right edge, as /diff's does.
const widthOf = (bodyColumns: number) => Math.max(20, Math.min(bodyColumns - 1, 200))

const maxTopOf = (drawn: { visibleRows: number; total: number }) => Math.max(0, drawn.total - drawn.visibleRows)

// Replies are numbered by the clock, so a number is never given twice, a /clear between or not.
const withReply = (list: MkdReply[], text: string) =>
  [...list, { id: Math.max(Date.now(), (list.at(-1)?.id ?? 0) + 1), text }].slice(-MAX_REPLIES)

// Each turn's last words, from the conversation itself: what /mkd pages through in a resumed
// session, or when the mod loaded after the replies were given.
async function repliesOfSession($: EngineInterface) {
  const messages = await $.session.messages().catch(() => [])
  let list: MkdReply[] = []
  let answer = ''
  for (const message of messages) {
    if (message.role === 'assistant') {
      if (message.text.trim() !== '') answer = message.text
    } else if ((message.toolResults?.length ?? 0) === 0 && answer !== '') {
      list = withReply(list, answer)
      answer = ''
    }
  }

  return answer === '' ? list : withReply(list, answer)
}

async function renderLines($: EngineInterface, reply: MkdReply, width: number) {
  const key = `${reply.id}:${width}`
  if (rendered?.key === key) return rendered.lines

  const ran = await $.process
    .run(['leaf', '--inline', `ansi:${width}`], { stdin: reply.text, timeoutMs: 10_000 })
    .catch((error: unknown) => `leaf could not run (is it on PATH?): ${String(error).slice(0, 300)}`)
  // A run that rejects is never kept: the engine aborts the run of a draw it abandons, and that
  // must not replace what another draw of the same reply rendered.
  if (typeof ran === 'string') return ran

  let lines: Run[][] | string
  if (ran.exitCode !== 0) lines = `leaf failed: ${ran.stderr.trim().slice(0, 300)}`
  else if (!ran.isStdoutTruncated) lines = parseAnsi(ran.stdout)
  else lines = [...parseAnsi(ran.stdout.slice(0, ran.stdout.lastIndexOf('\n') + 1)), CUT]
  rendered = { key, lines }

  return lines
}

// The pane as the main screen seats it: /diff's dialog, as tall as what it shows.
async function dialogOf($: EngineInterface, shown: MkdReply | undefined, bodyColumns: number) {
  const lines = shown === undefined ? '' : await renderLines($, shown, widthOf(bodyColumns))

  return {
    id: PANE,
    title: TITLE,
    closeOnEscape: true,
    rows: HEAD_ROWS + (typeof lines === 'string' ? 1 : Math.max(1, lines.length)),
  } as const
}

// The dialog is as tall as the reply it shows: a new one fits it again. Escape still closes it,
// and the keyboard stays where it is.
async function fit($: EngineInterface, shown: MkdReply) {
  if (seat?.placement !== 'inline' || !(await isOpen($))) return
  await $.ui.open(await dialogOf($, shown, seat.bodyColumns)).catch(() => undefined)
}

// Every reply joins the list, pane open or not. A pane on the newest reply moves to the new one;
// a pane the person paged back in stays where they are reading.
async function keep($: EngineInterface, text: string) {
  const before = await read($, replies)
  const list = withReply(before, text)
  const newest = list[list.length - 1]
  await update($, replies, () => list)
  const { at } = await read($, place)
  if (newest === undefined || (at !== before.at(-1)?.id && list.some(one => one.id === at))) return
  await update($, place, () => ({ at: newest.id, top: 0 }))
  await fit($, newest)
}

// The reply before (-1) or after (1) the one shown, from its top; at either end nothing moves.
async function page($: EngineInterface, by: -1 | 1) {
  const list = await read($, replies)
  const { at } = await read($, place)
  const next = list[list.findIndex(one => one.id === at) + by]
  if (next === undefined) return
  await update($, place, () => ({ at: next.id, top: 0 }))
  await fit($, next)
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'mkd',
      description: 'Toggle the markdown panel showing the last reply',
    })

    return next(e)
  })

  // /mkd toggles the pane as /diff toggles its own, and opens on the last reply.
  on('command.run', { command: 'mkd' }, async ($, e) => {
    const { isFullscreen, columns } = e.presentation
    if (await isOpen($)) {
      await $.ui.close({ id: PANE })
      return { text: isFullscreen ? 'Markdown panel hidden' : 'Markdown dialog dismissed' }
    }
    if (isFullscreen && columns < DOCK_MIN_COLUMNS) return { text: RESIZE }

    let list = await read($, replies)
    if (list.length === 0) {
      list = await repliesOfSession($)
      await update($, replies, () => list)
    }
    const newest = list[list.length - 1]
    await update($, place, () => ({ at: newest?.id ?? 0, top: 0 }))
    // The inline frame takes four of the terminal's columns.
    const opened = await $.ui.open(
      isFullscreen ? { id: PANE, title: TITLE } : { ...(await dialogOf($, newest, columns - 4)), focus: true },
    )
    if (!opened.isPlaced) {
      await $.ui.close({ id: PANE }).catch(() => undefined)
      return { text: RESIZE }
    }

    return isFullscreen ? { text: 'Markdown panel shown' } : {}
  })

  // The person's scrolls move the reply under the pinned head, as /diff's body moves: a wheel tick
  // or an arrow three rows, a page key the window, Home and End an end. The engine's window stays.
  on('ui.scroll', { requestId: PANE }, async ($, e, next) => {
    const drawn = seat
    if (e.origin.kind !== 'person' || drawn === undefined) return next(e)

    const size = Math.abs(e.by)
    const maxTop = maxTopOf(drawn)
    const isEnd = size >= e.contentRows && e.contentRows > e.bodyRows
    const step = isEnd ? maxTop : size >= e.bodyRows ? drawn.visibleRows : size * WHEEL_ROWS
    await update($, place, now => ({
      ...now,
      top: Math.max(0, Math.min(maxTop, Math.min(now.top, maxTop) + Math.sign(e.by) * step)),
    }))

    return {}
  })

  // A new conversation has other replies: the pane closes with the old ones, as /diff's does.
  on('command.run', { command: ['clear', 'resume'] }, async ($, e, next) => {
    const ran = await next(e)
    await $.ui.close({ id: PANE }).catch(() => undefined)
    await update($, replies, () => [])
    await update($, place, () => ({ at: 0, top: 0 }))

    return ran
  })

  on('turn.complete', async ($, e, next) => {
    if (e.agentId === undefined && e.answer.trim() !== '') await keep($, e.answer)

    return next(e)
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text, Button } = $.ui.resolve(e)
    const list = await read($, replies)
    const { at, top } = await read($, place)
    const index = list.findIndex(one => one.id === at)
    const shown = list[index]
    const visibleRows = Math.max(1, e.props.scroll.bodyRows - HEAD_ROWS)
    const drawn = { placement: e.props.placement, bodyColumns: e.props.bodyColumns, visibleRows }
    if (shown === undefined) {
      seat = { ...drawn, total: 0 }
      return <Text dimColor>{NO_REPLY}</Text>
    }

    const lines = await renderLines($, shown, widthOf(e.props.bodyColumns))
    seat = { ...drawn, total: typeof lines === 'string' ? 0 : lines.length }
    const first = Math.min(top, maxTopOf(seat))
    const rows = typeof lines === 'string' ? [] : lines.slice(first, first + visibleRows)

    return (
      <Box flexDirection="column">
        <Box flexDirection="row" flexShrink={0} marginBottom={1}>
          <Text dimColor>
            Reply {index + 1} of {list.length}
            {'  '}
          </Text>
          <Button key="previous" plain hotkey="p" dimColor={index === 0} onPress={() => void page($, -1)}>
            previous
          </Button>
          <Text>{'  '}</Text>
          <Button key="next" plain hotkey="n" dimColor={index === list.length - 1} onPress={() => void page($, 1)}>
            next
          </Button>
        </Box>
        {typeof lines === 'string' && <Text color="error">{lines}</Text>}
        {rows.map(runs => (
          <Text wrap="truncate-end">
            {runs.length === 0 ? ' ' : runs.map(({ text, ...style }) => <Text {...style}>{text}</Text>)}
          </Text>
        ))}
        <Box height={visibleRows - rows.length + SCROLL_MARGIN_ROWS} flexShrink={0} />
      </Box>
    )
  })
}
