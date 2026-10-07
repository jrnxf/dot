---
name: pr-visual-evidence
description: Show a PR's visual changes as captioned before/after screenshot pairs, side by side in the PR description, with red boxes around what changed. Use when a PR or change alters anything a user can see, or when asked for before/after screenshots in a PR.
---

# PR visual evidence

Every visible change gets a before/after pair in the PR description: a one-sentence caption, then the two screenshots side by side with red boxes marking what changed. Images are GitHub attachments in the description. Never commit screenshots to the repo and never host them elsewhere.

## 1. Capture

- Take "before" from the PR's base branch and "after" from the PR branch, with the same data, the same viewport, and the same scroll position.
- Use a desktop viewport such as 1440x900. When layout is involved, add a narrow pair at about 500px wide.
- Run the app locally against fixtures or a local stub. Never point it at a hosted environment.
- Name files `before-<name>.png` and `after-<name>.png`, outside the repo.
- When several agents run in parallel, start each app on a random free port and use a unique browser session name (for example `CHROME_DEVTOOLS_AXI_SESSION=<task>-<name>`).
- Skip PRs with nothing visible, such as tests-only changes.

## 2. Caption

Write one sentence per pair that says what the screen shows and what changed. Keep the captions in `captions.md` next to the images, one `<name>: <caption>` line per pair, in display order. Example:

```
run-header: Ticket page header at 1440px; after adds a PR link chip next to the Run and Ticket chips.
```

Wrap `owner/repo#123` references in backticks so GitHub does not autolink them and post a cross-reference on that issue.

## 3. Box the changes

Run the bundled script on each pair:

```sh
scripts/annotate.sh before-<name>.png after-<name>.png
```

It diffs the pair with `magick compare`, groups the changed pixels into at most 3 regions, pads each by 8px, and draws an unfilled 3px `#FF0000` rectangle at the same spot on both images. It writes `<file>.annotated.png` next to each input (or in `$OUT_DIR`) and keeps the originals.

Look at both annotated images and check each box against the caption. When a layout shift makes the diff noisy (the script warns when a box covers over 20% of the image), place the boxes by judgment and pass them as `x0,y0,x1,y1` tight content bounds. Prefix a box with `b:` or `a:` to draw it on one image only, so a moved element is boxed where it sits in each:

```sh
scripts/annotate.sh before-x.png after-x.png 596,93,752,119 b:10,200,300,260 a:10,232,300,292
```

## 4. Embed in the PR description

GitHub has no API for attachments, so upload through the description's web editor in a signed-in browser. One signed-in session can serve many PRs.

1. Open the PR, then the description's "Show options" menu, then "Edit". Retry if the editor does not open on the first click.
2. Upload each `*.annotated.png` with the editor's "Attach files" control, in caption order. Wait until each `https://github.com/user-attachments/assets/...` URL appears in the textarea before the next upload. If the browser tool refuses a file path, copy the images to `/tmp` first.
3. Replace the inserted `<img>` tags with one block per pair: a bold caption line, then a two-column table.

   ```markdown
   **<caption>**

   | Before | After |
   | --- | --- |
   | ![before-<name>](https://github.com/user-attachments/assets/...) | ![after-<name>](https://github.com/user-attachments/assets/...) |
   ```

   Put the blocks under one `## Screenshots` heading. Set the textarea value through the native value setter and dispatch an `input` event so GitHub sees the change, then save.
4. Read the body back with `gh-axi pr view <number> --full`. Confirm every image URL is present, each caption appears once, no placeholder or stray `<img>` tag is left, and the text outside the screenshots section is unchanged. GitHub stores web-edited bodies with CRLF line endings, so normalize before comparing.

## 5. Leave the rest alone

Keep the rest of the PR body short and unchanged. Never change the PR's title or its draft or ready state as part of this workflow.
