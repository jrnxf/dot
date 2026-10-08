export type LeafDoc =
  | { kind: 'none' }
  | { kind: 'file'; path: string; rev: number }
  | { kind: 'reply'; text: string; rev: number }

declare module 'claude-code' {
  interface PluginState {
    leaf: { doc: LeafDoc; reply: string }
  }
}
