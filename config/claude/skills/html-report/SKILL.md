---
name: html-report
description: Generate a polished, single-file dark-themed HTML report (engineering write-ups, project summaries, design docs) using a fixed, self-contained design system. Activate when the user asks to "make an HTML report", "write this up as an HTML report", "turn this into a report page", or wants a shareable single-file HTML doc with a sidebar TOC.
disable-model-invocation: true
---

# HTML Report Generator

Produce a single, self-contained `.html` file (no external assets, no build step) that
renders a long-form technical report: sticky sidebar table of contents on the left,
content on the right. Open it straight in a browser.

## When to Activate

- "Make / generate an HTML report" out of a doc, branch, set of commits, or investigation
- "Write this up as a report page" / "turn this into a shareable HTML doc"
- Any request for a dark-themed, single-file write-up with a navigable TOC

## Workflow

1. **Gather the content.** Pull from whatever the user points at — a branch diff, commits,
   scratchpad docs, a PR, an investigation. Don't invent facts; if a detail is uncertain,
   say so in the prose rather than asserting it.
2. **Outline the sections first.** Decide the `<h2>` sections and their anchor ids — these
   become both the TOC links and the section headings. Group them under TOC sub-headings
   (e.g. "Overview", "The build", "Status").
3. **Write the body** using the components documented below. Reach for the right one:
   tables for comparisons, `.flow` for ordered steps, `.pipe` for a left-to-right pipeline,
   `.callout` for the one thing the reader must not miss, `.card`/`.grid` for parallel
   concepts, `.kv` for definition lists.
4. **Paste in the `<style>` block verbatim** (below) — do not re-derive colors or spacing.
5. **Write the file** to where the user asks; default to `.claude/scratchpad/<topic>/report.html`.
6. **Tell the user the path** and offer to open it (`open <path>`).

## Style rules

- One file. Inline `<style>`, no `<script>`, no CDN links, no fonts to fetch.
- Match the report's register to the source: precise, declarative, no marketing fluff.
- Prefer showing structure (tables, flows, pipes) over long paragraphs.
- Use `<code>` for every identifier, file path, flag, and enum value.
- Keep line length in prose readable; `.lead` and `.callout` carry the high-order bits.

## The template

Start every report from this scaffold. The `<style>` block is the design system — **paste it
exactly**. The accent is a clean violet (`--accent`) paired with a mint secondary
(`--accent2`); do not change these to a washed-out blue.

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>TITLE — Report</title>
<style>
  :root{
    --bg:#0f1117; --panel:#171a22; --panel2:#1d212b; --line:#2a2f3a;
    --ink:#e6e9ef; --muted:#9aa3b2; --accent:#a78bfa; --accent2:#7ee2b8;
    --warn:#f5b971; --bad:#f08a8a; --good:#7ee2b8; --chip:#252a36;
    --mono:'SF Mono',ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;
    --sans:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;
  }
  *{box-sizing:border-box}
  html{scroll-behavior:smooth}
  body{margin:0;background:var(--bg);color:var(--ink);font-family:var(--sans);line-height:1.6;font-size:15px}
  .wrap{display:grid;grid-template-columns:260px 1fr;max-width:1400px;margin:0 auto}
  nav.toc{position:sticky;top:0;align-self:start;height:100vh;overflow-y:auto;padding:28px 18px;border-right:1px solid var(--line);background:var(--panel)}
  nav.toc h2{font-size:12px;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);margin:18px 0 8px}
  nav.toc a{display:block;color:var(--ink);text-decoration:none;padding:5px 10px;border-radius:7px;font-size:13.5px;opacity:.85}
  nav.toc a:hover{background:var(--panel2);opacity:1}
  nav.toc .brand{font-weight:700;font-size:15px;margin-bottom:4px}
  nav.toc .brand small{display:block;color:var(--muted);font-weight:400;font-size:12px;margin-top:3px}
  main{padding:42px 56px;min-width:0}
  h1{font-size:30px;margin:0 0 6px;letter-spacing:-.01em}
  h2{font-size:23px;margin:46px 0 14px;padding-top:14px;border-top:1px solid var(--line);letter-spacing:-.01em}
  h2:first-of-type{border-top:none}
  h3{font-size:17.5px;margin:30px 0 10px;color:#fff}
  h4{font-size:14.5px;margin:20px 0 6px;color:var(--accent2);letter-spacing:.02em}
  p{margin:10px 0}
  a{color:var(--accent)}
  code{font-family:var(--mono);background:var(--chip);padding:1.5px 6px;border-radius:5px;font-size:12.5px;color:#dfe6f2}
  pre{background:#0c0e14;border:1px solid var(--line);border-radius:10px;padding:16px 18px;overflow-x:auto;font-family:var(--mono);font-size:12.5px;line-height:1.55}
  pre code{background:none;padding:0;color:#cdd6e6}
  .lead{font-size:16.5px;color:var(--muted);max-width:75ch}
  .pill{display:inline-block;font-size:11px;font-weight:600;letter-spacing:.04em;padding:2px 9px;border-radius:999px;background:var(--chip);color:var(--muted);border:1px solid var(--line);vertical-align:middle}
  .pill.s1{color:#c4b5fd;border-color:#473b6b}
  .pill.s2{color:#7ee2b8;border-color:#2a4f40}
  .pill.s3{color:#f5b971;border-color:#5a432a}
  .pill.done{color:var(--good);border-color:#2a4f40}
  .pill.partial{color:var(--warn);border-color:#5a432a}
  .pill.todo{color:var(--bad);border-color:#5a2f2f}
  .card{background:var(--panel);border:1px solid var(--line);border-radius:14px;padding:20px 22px;margin:16px 0}
  .grid2{display:grid;grid-template-columns:1fr 1fr;gap:16px}
  .grid3{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}
  @media(max-width:980px){.wrap{grid-template-columns:1fr}nav.toc{display:none}main{padding:28px 20px}.grid2,.grid3{grid-template-columns:1fr}}
  table{width:100%;border-collapse:collapse;margin:14px 0;font-size:13.5px}
  th,td{text-align:left;padding:9px 12px;border-bottom:1px solid var(--line);vertical-align:top}
  th{color:var(--muted);font-weight:600;font-size:12px;letter-spacing:.04em;text-transform:uppercase}
  tr:hover td{background:var(--panel2)}
  .callout{border-left:3px solid var(--accent);background:var(--panel2);border-radius:0 10px 10px 0;padding:12px 18px;margin:16px 0}
  .callout.warn{border-color:var(--warn)}
  .callout.good{border-color:var(--good)}
  .callout.bad{border-color:var(--bad)}
  .callout .k{font-weight:700;color:#fff;display:block;margin-bottom:2px}
  ul,ol{margin:10px 0;padding-left:22px}
  li{margin:5px 0}
  .flow{display:flex;flex-direction:column;gap:0;margin:18px 0}
  .step{display:flex;gap:14px;align-items:flex-start;position:relative;padding:0 0 18px 0}
  .step:not(:last-child)::before{content:"";position:absolute;left:15px;top:32px;bottom:-4px;width:2px;background:var(--line)}
  .step .n{flex:0 0 32px;height:32px;border-radius:50%;background:var(--accent);color:#0c0e14;font-weight:700;display:flex;align-items:center;justify-content:center;font-size:14px;z-index:1}
  .step .body{flex:1;padding-top:3px}
  .step .body b{color:#fff}
  .step .body .meta{font-size:12.5px;color:var(--muted);font-family:var(--mono)}
  .pipe{display:flex;flex-wrap:wrap;align-items:center;gap:8px;margin:18px 0;font-size:13px}
  .pipe .box{background:var(--panel2);border:1px solid var(--line);border-radius:9px;padding:8px 13px}
  .pipe .box b{display:block;color:#fff;font-size:13px}
  .pipe .box span{color:var(--muted);font-size:11.5px;font-family:var(--mono)}
  .pipe .arr{color:var(--accent);font-size:18px}
  .kv{display:grid;grid-template-columns:auto 1fr;gap:4px 16px;font-size:13.5px;margin:8px 0}
  .kv dt{color:var(--muted);font-family:var(--mono);font-size:12.5px}
  .kv dd{margin:0}
  .tag{font-family:var(--mono);font-size:12px;color:var(--accent2)}
  hr{border:none;border-top:1px solid var(--line);margin:32px 0}
  .small{font-size:12.5px;color:var(--muted)}
  .footer{margin-top:50px;padding-top:20px;border-top:1px solid var(--line);color:var(--muted);font-size:12.5px}
  .legend{display:flex;gap:18px;flex-wrap:wrap;font-size:12.5px;color:var(--muted);margin:8px 0 0}
</style>
</head>
<body>
<div class="wrap">
<nav class="toc">
  <div class="brand">PROJECT<small>subtitle / ticket</small></div>
  <h2>Section group</h2>
  <a href="#summary">Executive summary</a>
  <a href="#detail">Some section</a>
  <!-- one <a href="#id"> per <h2 id="id"> in the body -->
</nav>

<main>
<h1>Report title</h1>
<p class="lead">One-paragraph framing: what this is, what it covers, and the single takeaway.</p>

<h2 id="summary">Executive summary</h2>
<p>…</p>

<h2 id="detail">Some section</h2>
<p>…</p>

<div class="footer">
  <p>Provenance: where this came from, when, and how to verify a detail that matters.</p>
</div>
</main>
</div>
</body>
</html>
```

## Component cheatsheet

Pick by intent — don't over-decorate.

- **`.lead`** — the one-paragraph framing right under `<h1>`.
- **`.pill`** — inline status/stage chip. Variants: `.done .partial .todo` (status) and
  `.s1 .s2 .s3` (categories/stages). e.g. `<span class="pill done">shipped</span>`.
- **`.card`** + **`.grid2`/`.grid3`** — parallel concepts side by side.
  `<div class="grid3"><div class="card">…</div>…</div>`.
- **`.callout`** (+ `.warn`/`.good`/`.bad`) — the can't-miss note. Lead with
  `<span class="k">Headline.</span>` then the explanation.
- **`.flow`** — ordered steps with a connecting spine:
  `<div class="flow"><div class="step"><div class="n">1</div><div class="body"><b>Title</b> — detail. <span class="meta">aside</span></div></div>…</div>`.
- **`.pipe`** — left-to-right pipeline of boxes joined by arrows:
  `<div class="pipe"><div class="box"><b>Stage</b><span>note</span></div><span class="arr">→</span>…</div>`.
- **`.kv`** — definition list / glossary: `<dl class="kv"><dt>term</dt><dd>meaning</dd></dl>`.
- **`table`** — comparisons and status matrices; `th` auto-uppercases.
- **`.tag`** — small monospace caption under a heading (file paths, commit ids, keys).
- **`.footer`** — closing provenance block; note that external links rot, verify live.

## Notes

- Every TOC `<a href="#x">` must have a matching `<h2 id="x">` (or other id'd heading).
- For literal `<` / `>` inside `<code>`/`<pre>`, escape as `&lt;` / `&gt;`.
- Keep it one file — the value is that the user can double-click it or send it as an attachment.
