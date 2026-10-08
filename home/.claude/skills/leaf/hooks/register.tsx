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

async function renderLines($: EngineInterface, current: Exclude<LeafDoc, { kind: 'none' }>, width: number) {
  const key = `${current.rev}:${width}`
  if (rendered?.key === key) return rendered.lines

  const argv = ['leaf', '--inline', `ansi:${width}`]
  const lines = await (current.kind === 'file'
    ? $.process.run([...argv, current.path], { timeoutMs: 10_000 })
    : $.process.run(argv, { stdin: current.text, timeoutMs: 10_000 })
  ).then(
    ran => {
      if (ran.exitCode !== 0) return `leaf failed: ${ran.stderr.trim().slice(0, 300)}`
      if (!ran.isStdoutTruncated) return parseAnsi(ran.stdout)

      return [...parseAnsi(ran.stdout.slice(0, ran.stdout.lastIndexOf('\n') + 1)), CUT]
    },
    (error: unknown) => `leaf could not run (is it on PATH?): ${String(error).slice(0, 300)}`,
  )
  rendered = { key, lines }

  return lines
}

export const register: Register = on => {
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
    if (e.agentId === undefined && e.answer.trim() !== '') await update($, reply, () => e.answer)

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
