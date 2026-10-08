import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { LeafDoc } from '../types'
import { parseAnsi } from './ansi'
import type { Run } from './ansi'
import { ansiLines, literal, openEnd, RESET } from './stream'

const PANE = 'leaf'
const USAGE = 'Usage: /leaf <file.md>, /leaf reply'
const CUT: Run[] = [{ text: 'leaf wrote more than 4 MiB: the render is cut here.', color: 'warning' }]
const doc = atom({ plugin: 'leaf', key: 'doc' } as const, { kind: 'none' } as LeafDoc)
const reply = atom({ plugin: 'leaf', key: 'reply' } as const, '')

const isMarkdown = (path: string) => /\.(md|markdown|mdx)$/i.test(path)
const basename = (path: string) => path.slice(path.lastIndexOf('/') + 1)

// The latest render, for one document revision at one width; a reload starts it over.
let rendered: { key: string; lines: Run[][] | string } | undefined

async function show($: EngineInterface, next: LeafDoc, title: string) {
  await update($, doc, () => next)
  await $.ui.open({ id: PANE, title })
}

// While the pane is open it follows the markdown files Claude writes or edits; it never opens by itself.
async function follow($: EngineInterface, path: string) {
  if (!isMarkdown(path)) return
  if (!(await $.ui.panes()).some(pane => pane.id === PANE)) return
  await show($, { kind: 'file', path, rev: Date.now() }, basename(path))
}

// While the pane shows a reply it follows each new one; the last /leaf command decides reply or file.
async function followReply($: EngineInterface, text: string) {
  if ((await read($, doc)).kind !== 'reply') return
  if (!(await $.ui.panes()).some(pane => pane.id === PANE)) return
  await show($, { kind: 'reply', text, rev: Date.now() }, 'Last reply')
}

async function renderLines($: EngineInterface, current: Exclude<LeafDoc, { kind: 'none' }>, width: number) {
  const key = `${current.rev}:${width}`
  if (rendered?.key === key) return rendered.lines

  const argv = ['leaf', '--inline', `ansi:${width}`]
  const ran = await (current.kind === 'file'
    ? $.process.run([...argv, current.path], { timeoutMs: 10_000 })
    : $.process.run(argv, { stdin: current.text, timeoutMs: 10_000 })
  ).catch((error: unknown) => `leaf could not run (is it on PATH?): ${String(error).slice(0, 300)}`)
  // A run that rejects is never kept: the engine aborts the run of a draw it abandons, and that
  // must not replace what another draw of the same revision rendered.
  if (typeof ran === 'string') return ran

  let lines: Run[][] | string
  if (ran.exitCode !== 0) lines = `leaf failed: ${ran.stderr.trim().slice(0, 300)}`
  else if (!ran.isStdoutTruncated) lines = parseAnsi(ran.stdout)
  else lines = [...parseAnsi(ran.stdout.slice(0, ran.stdout.lastIndexOf('\n') + 1)), CUT]
  rendered = { key, lines }

  return lines
}

// leaf's drawing of a reply at a width, or undefined when leaf is missing, failed or wrote too much.
const leafReply = ($: EngineInterface, text: string, width: number) =>
  $.process.run(['leaf', '--inline', `ansi:${width}`], { stdin: text, timeoutMs: 5_000 }).then(
    ran => (ran.exitCode === 0 && !ran.isStdoutTruncated ? ran.stdout : undefined),
    () => undefined,
  )

// A reply drawn in the transcript: leaf's lines, or undefined when leaf is missing or failed.
// Claude Code asks for a reply again on many redraws, so each is kept by width and text.
const replies = new Map<string, Run[][] | undefined>()

async function replyLines($: EngineInterface, text: string, width: number) {
  const key = `${width}:${text}`
  if (replies.has(key)) return replies.get(key)

  const stdout = await leafReply($, text, width)
  const lines = stdout === undefined ? undefined : parseAnsi(stdout)
  if (replies.size >= 400) replies.clear()
  replies.set(key, lines)

  return lines
}

// Two cells for the reply's bullet and its gap, as the engine's own row has.
const replyWidth = (columns: number) => Math.max(20, Math.min(columns - 2, 200))

// A reply while it streams. Claude Code hands over each batch of new lines and shows what the mod
// answers with, so the mod answers with the lines leaf newly draws for the reply so far.
type Stream = {
  raw: string
  // What leaf last drew: how much of `raw`, at which width, less how many withheld last lines.
  done: number
  width: number
  held: number
  // How many of leaf's lines are on show.
  shown: number
  // How much of `raw` is on show whole: up to the block still being written.
  whole: number
  // Everything answered so far: what the settled row's text will be.
  out: string
  // leaf failed once: the rest of this reply is left to Claude Code.
  isPlain: boolean
  // The batch before this one: batches are answered in order, each from where the last one stopped.
  last: Promise<unknown>
}
const streams = new Map<string, Stream>()
// What each streamed reply showed, back to its markdown: the settled row is drawn from the markdown.
const sources = new Map<string, string>()
// A streaming batch carries no width, so the transcript's is kept from the last drawing that had one.
let columns = 80

const leafLines = async ($: EngineInterface, text: string, width: number) => {
  const stdout = text.trim() === '' ? '' : await leafReply($, text, width)

  return stdout === undefined ? undefined : ansiLines(stdout)
}

// What one batch adds to the stream. leaf draws the reply so far, not the new lines alone, so the
// lines and the gaps between blocks are the ones the settled row will have. Lines on show cannot be
// drawn again: where a later line changes an earlier one (a table's columns widening, a diagram
// laid out anew), the stream is off until the settled row is drawn.
async function advance($: EngineInterface, stream: Stream, delta: string, isFinal: boolean) {
  stream.raw += delta
  const { raw } = stream

  if (!stream.isPlain) {
    const to = raw.length
    // The last line of a block that can still grow waits: it is the one more text changes.
    const end = openEnd(raw)
    const held = !isFinal && end.isOpen ? 1 : 0
    const width = replyWidth(columns)
    if (to === stream.done && held === stream.held && width === stream.width) return ''

    // Resized mid-reply: what is on show stays as drawn, and is counted again at the new width.
    const resized = width === stream.width ? undefined : await leafLines($, raw.slice(0, stream.done), width)
    const before = width === stream.width ? stream.shown : resized === undefined ? undefined : Math.max(0, resized.length - stream.held)
    const lines = before === undefined ? undefined : await leafLines($, raw.slice(0, to), width)
    if (before !== undefined && lines !== undefined) {
      const fresh = lines.slice(before, lines.length - held)
      stream.done = to
      stream.width = width
      stream.held = held
      stream.shown = before + fresh.length
      stream.whole = held === 0 ? to : end.start
      const out = fresh.length === 0 ? '' : literal(fresh) + '\n'
      stream.out += out

      return out
    }
    stream.isPlain = true
  }

  // From the last point shown whole, so no line is lost and no code fence is left without its
  // opening. A blank line first, so the markdown is not read as more of leaf's last line.
  const rest = (stream.shown > 0 ? '\n' : '') + raw.slice(stream.whole)
  stream.shown = 0
  stream.whole = raw.length
  stream.out += rest

  return rest
}

export const register: Register = (on, options) => {
  // Off by default: the reply is left to Claude Code. With `all`, leaf draws it in the transcript,
  // line by line while it streams and whole once it has settled.
  on('classic.MessageDisplay', async ($, e, next) => {
    if (options.inlineReplies !== 'all') return next(e)

    let stream = streams.get(e.message_id)
    if (stream === undefined) {
      stream = { raw: '', done: 0, width: 0, held: 0, shown: 0, whole: 0, out: '', isPlain: false, last: Promise.resolve() }
      // A reply that is interrupted never sends its last batch.
      if (streams.size >= 16) streams.delete(streams.keys().next().value!)
      streams.set(e.message_id, stream)
    }
    if (e.final) streams.delete(e.message_id)

    const streamed = stream
    const batch = streamed.last.then(() => advance($, streamed, e.delta, e.final))
    streamed.last = batch.catch(() => undefined)
    const displayContent = await batch
    if (e.final && streamed.out !== streamed.raw) {
      // The oldest goes first: a row whose markdown is forgotten keeps the lines it streamed.
      if (sources.size >= 400) sources.delete(sources.keys().next().value!)
      sources.set(streamed.out.trim(), streamed.raw)
    }

    return { displayContent }
  })

  // The band above the prompt is drawn at the start and again on every resize, a reply streaming
  // or not, which the spinner is not: it draws nothing itself and is hooked for its width alone.
  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.surface === 'terminal' && e.viewport !== undefined) columns = e.viewport.columns

    return next(e)
  })

  on('ui.render', { component: 'AssistantMessage' }, async ($, shown, next) => {
    if (options.inlineReplies !== 'all' || shown.surface !== 'terminal' || shown.viewport === undefined) return next(shown)
    columns = shown.viewport.columns

    const source = sources.get(shown.props.text.trim())
    // The mod's own lines with no markdown to draw them from: a row drawn before its reply's last
    // batch landed, or one whose markdown is forgotten. Claude Code draws them as the stream did.
    if (source === undefined && shown.props.text.includes(RESET)) return next(shown)
    const e = source === undefined ? shown : { ...shown, props: { ...shown.props, text: source } }

    const lines = await replyLines($, e.props.text, replyWidth(columns))
    // leaf missing or failed: the engine draws the reply as it always does.
    if (lines === undefined) return next(e)

    const { Box, Text } = $.ui.resolve(e)

    return (
      <Box flexDirection="row" marginTop={1}>
        <Box width={2} flexShrink={0}>
          <Text>{e.props.isFirstOfReply ? '●' : ' '}</Text>
        </Box>
        <Box flexDirection="column">
          {lines.map(runs => (
            <Text wrap="truncate-end">
              {runs.length === 0 ? ' ' : runs.map(({ text, ...style }) => <Text {...style}>{text}</Text>)}
            </Text>
          ))}
        </Box>
      </Box>
    )
  })

  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'leaf',
      description: 'Show markdown in a pane via leaf: /leaf <file>, /leaf reply',
    })

    return next(e)
  })

  on('command.run', { command: 'leaf' }, async ($, e) => {
    const arg = e.args.trim()
    if (arg === '') return { text: USAGE }
    if (arg === 'reply') {
      const text = await read($, reply)
      if (text === '') return { text: 'No reply to show yet.' }
      await show($, { kind: 'reply', text, rev: Date.now() }, 'Last reply')
      return { text: 'Showing the last reply.' }
    }
    const stat = await $.fs.stat(arg).catch(() => undefined)
    if (stat === undefined) return { text: `No such file: ${arg}` }
    if (stat.kind !== 'file') return { text: `Not a file: ${arg}` }
    await show($, { kind: 'file', path: arg, rev: Date.now() }, basename(arg))

    return { text: `Showing ${arg}` }
  })

  on('tool.call', { tool: 'Write' }, async ($, e, next) => {
    const ran = await next(e)
    if (ran.deny === undefined && ran.isError !== true) await follow($, e.file_path)

    return ran
  })

  on('tool.call', { tool: 'Edit' }, async ($, e, next) => {
    const ran = await next(e)
    if (ran.deny === undefined && ran.isError !== true) await follow($, e.file_path)

    return ran
  })

  on('turn.complete', async ($, e, next) => {
    if (e.agentId === undefined && e.answer.trim() !== '') {
      await update($, reply, () => e.answer)
      await followReply($, e.answer)
    }

    return next(e)
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text } = $.ui.resolve(e)
    const current = await read($, doc)
    if (current.kind === 'none') return <Text dimColor>{USAGE}</Text>

    const lines = await renderLines($, current, Math.max(20, Math.min(e.props.bodyColumns, 200)))
    if (typeof lines === 'string') return <Text color="error">{lines}</Text>

    // Only the rows near the window are drawn; the rest of the document is held as blank height.
    const { offset, bodyRows } = e.props.scroll
    const first = Math.max(0, Math.min(offset, lines.length) - bodyRows)
    const last = Math.min(lines.length, offset + 2 * bodyRows)

    return (
      <Box flexDirection="column">
        {first > 0 && <Box height={first} flexShrink={0} />}
        {lines.slice(first, last).map(runs => (
          <Text wrap="truncate-end">
            {runs.length === 0 ? ' ' : runs.map(({ text, ...style }) => <Text {...style}>{text}</Text>)}
          </Text>
        ))}
        {last < lines.length && <Box height={lines.length - last} flexShrink={0} />}
      </Box>
    )
  })
}
