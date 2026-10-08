export type Run = {
  text: string
  color?: string
  backgroundColor?: string
  bold?: boolean
  italic?: boolean
  underline?: boolean
  strikethrough?: boolean
}

const SGR = /\x1b\[([0-9;]*)m/g
const hex = (r: number, g: number, b: number) =>
  '#' + [r, g, b].map(n => n.toString(16).padStart(2, '0')).join('')

// leaf --inline ansi writes SGR only: truecolor fg/bg, bold, italic, underline, strikethrough, reset.
// Under a custom theme it can also write named and indexed colors: text in those keeps the pane's own color.
const apply = (style: Omit<Run, 'text'>, codes: number[]) => {
  let next = { ...style }
  for (let i = 0; i < codes.length; i++) {
    const code = codes[i]
    if (code === 0) next = {}
    else if (code === 1) next.bold = true
    else if (code === 3) next.italic = true
    else if (code === 4) next.underline = true
    else if (code === 9) next.strikethrough = true
    else if ((code === 38 || code === 48) && codes[i + 1] === 2) {
      const color = hex(codes[i + 2] ?? 0, codes[i + 3] ?? 0, codes[i + 4] ?? 0)
      if (code === 38) next.color = color
      else next.backgroundColor = color
      i += 4
    } else if ((code === 38 || code === 48) && codes[i + 1] === 5) i += 2
  }
  return next
}

const same = (a: Omit<Run, 'text'>, b: Omit<Run, 'text'>) =>
  a.color === b.color &&
  a.backgroundColor === b.backgroundColor &&
  a.bold === b.bold &&
  a.italic === b.italic &&
  a.underline === b.underline &&
  a.strikethrough === b.strikethrough

export const parseAnsi = (output: string): Run[][] =>
  output
    .replace(/\n$/, '')
    .split('\n')
    .map(line => {
      const runs: Run[] = []
      let style: Omit<Run, 'text'> = {}
      let at = 0
      const push = (text: string) => {
        // Any escape that is not SGR is dropped rather than drawn.
        const clean = text.replace(/[\x00-\x08\x0b-\x1f\x7f]/g, '')
        if (clean === '') return
        const last = runs[runs.length - 1]
        if (last !== undefined && same(last, style)) last.text += clean
        else runs.push({ ...style, text: clean })
      }
      for (const match of line.matchAll(SGR)) {
        push(line.slice(at, match.index))
        style = apply(style, (match[1] ?? '').split(';').map(Number))
        at = match.index + match[0].length
      }
      push(line.slice(at))
      return runs
    })
