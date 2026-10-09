// One reply /mkd pages through, and where the pane stands: the reply shown (0 for none) and its top row.
export type MkdReply = { id: number; text: string }
export type MkdPlace = { at: number; top: number }

declare module 'claude-code' {
  interface PluginState {
    mkd: { replies: MkdReply[]; place: MkdPlace }
  }
}
