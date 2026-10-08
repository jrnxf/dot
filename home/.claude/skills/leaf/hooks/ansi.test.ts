import { expect, test } from 'claude-code/testing'

import { parseAnsi } from './ansi'

const ESC = '\x1b'

test('a truecolor run keeps its colors and styles until the reset', () => {
  const lines = parseAnsi(`${ESC}[38;2;140;190;255;1mTitle${ESC}[0m plain${ESC}[0m\n`)

  expect(lines).toEqual([[{ text: 'Title', color: '#8cbeff', bold: true }, { text: ' plain' }]])
})

test('foreground and background arrive in one sequence', () => {
  const run = parseAnsi(`${ESC}[38;2;220;150;118;48;2;38;32;31m code ${ESC}[0m`)[0]?.[0]

  expect(run).toEqual({ text: ' code ', color: '#dc9676', backgroundColor: '#26201f' })
})

test('italic and underline are carried', () => {
  const lines = parseAnsi(`${ESC}[3mquote${ESC}[0m${ESC}[38;2;88;152;238;4mlink${ESC}[0m`)

  expect(lines).toEqual([
    [
      { text: 'quote', italic: true },
      { text: 'link', color: '#5898ee', underline: true },
    ],
  ])
})

test('struck text stays struck and does not run into what follows', () => {
  const lines = parseAnsi(`${ESC}[9mdone${ESC}[0mlive${ESC}[38;2;1;2;3;9mcut${ESC}[0m`)

  expect(lines).toEqual([
    [
      { text: 'done', strikethrough: true },
      { text: 'live' },
      { text: 'cut', color: '#010203', strikethrough: true },
    ],
  ])
})

test('an indexed color is read whole: its index is never taken for a style or a reset', () => {
  const lines = parseAnsi(`${ESC}[38;5;1;48;5;3ma${ESC}[0m${ESC}[1;38;5;0mb${ESC}[0m${ESC}[48;5;4;9mc${ESC}[0m`)

  expect(lines).toEqual([[{ text: 'a' }, { text: 'b', bold: true }, { text: 'c', strikethrough: true }]])
})

test('adjacent runs of one style merge', () => {
  const [line] = parseAnsi(`${ESC}[38;2;1;2;3ma${ESC}[0m${ESC}[38;2;1;2;3mb${ESC}[0m`)

  expect(line).toEqual([{ text: 'ab', color: '#010203' }])
})

test('an empty line stays a line and the final newline adds none', () => {
  expect(parseAnsi(`a\n${ESC}[0m\nb\n`)).toEqual([[{ text: 'a' }], [], [{ text: 'b' }]])
})

test('control characters that are not SGR never reach a Text', () => {
  const text = parseAnsi(`a${ESC}[2Kb\rc`)
    .flat()
    .map(run => run.text)
    .join('')

  expect(text).not.toMatch(/[\x00-\x08\x0b-\x1f\x7f]/)
})
