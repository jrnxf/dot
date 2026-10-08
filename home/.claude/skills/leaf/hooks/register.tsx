import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { LeafDoc } from '../types'
import { parseAnsi } from './ansi'
import type { Run } from './ansi'

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

// A reply drawn in the transcript: leaf's lines, or undefined when leaf is missing or failed.
// Claude Code asks for a reply again on many redraws, so each is kept by width and text.
const replies = new Map<string, Run[][] | undefined>()

async function replyLines($: EngineInterface, text: string, width: number) {
  const key = `${width}:${text}`
  if (replies.has(key)) return replies.get(key)

  const lines = await $.process.run(['leaf', '--inline', `ansi:${width}`], { stdin: text, timeoutMs: 5_000 }).then(
    ran => (ran.exitCode === 0 && !ran.isStdoutTruncated ? parseAnsi(ran.stdout) : undefined),
    () => undefined,
  )
  if (replies.size >= 400) replies.clear()
  replies.set(key, lines)

  return lines
}

export const register: Register = (on, options) => {
  // Off by default: the reply is left to Claude Code. With `all`, leaf draws it in the transcript.
  on('ui.render', { component: 'AssistantMessage' }, async ($, e, next) => {
    const columns = e.viewport?.columns
    if (options.inlineReplies !== 'all' || e.surface !== 'terminal' || columns === undefined) return next(e)

    // Two cells for the reply's bullet and its gap, as the engine's own row has.
    const lines = await replyLines($, e.props.text, Math.max(20, Math.min(columns - 2, 200)))
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
