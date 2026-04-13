---
name: timesheet
description: Generates a clean PDF timesheet from a screenshot of time entries. Reads the image, cross-references git commits in the date range, and produces a minimal styled PDF with bullet-point descriptions. Use when the user provides a timesheet screenshot or asks to generate a timesheet PDF.
---

# Timesheet PDF Generator

Turns a screenshot of time-tracking entries into a polished PDF timesheet with commit-derived descriptions.

## When to Use

- User provides a timesheet screenshot (PNG/JPG) and wants a PDF
- User says "generate timesheet", "timesheet pdf", "build my timesheet"
- User wants to cross-reference tracked time with git history

## Execution

Run the entire workflow end-to-end without pausing for confirmation. Do not ask the user to approve intermediate steps — just execute everything and present the final result.

## Workflow

### Step 1: Read the timesheet image

Use the Read tool on the provided image path. Extract:

- Each day (date)
- All time entries per day — sum all session durations into a single daily total
- The project name (shown next to the colored dot)

### Step 2: Pull git commits for the date range

Run:

```bash
git log --author="$(git config user.name)" --since="<first_date>" --until="<last_date_plus_1>" --format="%H %ai %s" --all
```

### Step 3: Write descriptions from commits

For each day, turn each commit into a bullet point:

- Summarize the commit message into a short, readable line — don't just copy the raw message verbatim
- Strip conventional commit prefixes (feat(web):, style(web):, etc.) and rewrite as plain English
- Group closely related commits into a single bullet if they're part of the same logical change
- If no commits match (e.g. meetings, env setup), use the entry's own description (if present and meaningful) or best-guess from context

**Good bullet examples:**

- `Migrated marketing page from inline styles to Tailwind classes`
- `Added lint-staged with husky pre-commit hook`
- `Replaced static agent-signup PNG with interactive Rive animation`
- `Header mask/overlay styling; merged PRs #198, #199`

### Step 4: Generate the PDF

Use Python with `reportlab`. Install if needed: `pip3 install --break-system-packages reportlab`

**The PDF must follow this exact style specification:**

```python
from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor

output = "<project_dir>/colby_thomas_timesheet_<start_date>-<end_date>.pdf"  # e.g. colby_thomas_timesheet_mar_26-apr_3.pdf (lowercase 3-letter month, underscore, day)
c = canvas.Canvas(output, pagesize=letter)
w, h = letter

# Colors
black = HexColor("#1a1a1a")
gray = HexColor("#666666")
light_gray = HexColor("#cccccc")
separator = HexColor("#e5e5e5")

# Layout constants
LEFT = 0.75 * inch
RIGHT = w - 0.75 * inch
DESC_X = 1.0 * inch        # bullet position
TEXT_X = DESC_X + 10        # text after bullet
BULLET_MAX_W = RIGHT - TEXT_X
BULLET = "\u2022"

def wrap_text(text, font, size, max_w):
    words = text.split()
    lines, line = [], ""
    for word in words:
        test = f"{line} {word}".strip()
        if c.stringWidth(test, font, size) <= max_w:
            line = test
        else:
            if line: lines.append(line)
            line = word
    if line: lines.append(line)
    return lines

# --- Title ---
y = h - 1 * inch
c.setFont("Helvetica-Bold", 18)
c.setFillColor(black)
c.drawString(LEFT, y, "Colby Thomas")

# --- Subtitle: date range · project ---
y -= 20
c.setFont("Helvetica", 10)
c.setFillColor(gray)
c.drawString(LEFT, y, "<date_range>  \u00b7  <project_name>")

# --- Divider under subtitle ---
y -= 12
c.setStrokeColor(light_gray)
c.setLineWidth(0.5)
c.line(LEFT, y, RIGHT, y)
y -= 30

# --- Day rows ---
for day_label, day_total, items in days:
    # Estimate height for page break
    needed = 18
    for item_text, item_sha in items:
        sha_suffix = f" ({item_sha})" if item_sha else ""
        needed += len(wrap_text(item_text + sha_suffix, "Helvetica", 9, BULLET_MAX_W)) * 13 + 2
    needed += 20
    if y - needed < 0.75 * inch:
        c.showPage()
        y = h - 1 * inch

    # Day header: bold label left, total right
    c.setFont("Helvetica-Bold", 11)
    c.setFillColor(black)
    c.drawString(LEFT, y, day_label)       # e.g. "March 26"
    c.setFont("Helvetica", 10)
    c.setFillColor(gray)
    c.drawRightString(RIGHT, y, day_total) # e.g. "1h 15m"
    y -= 18

    # Bullet items
    for item_text, item_sha in items:
        if y < 0.75 * inch:
            c.showPage()
            y = h - 1 * inch
        c.setFont("Helvetica", 9)
        c.setFillColor(black)
        c.drawString(DESC_X, y, BULLET)
        # Append sha to last line if present
        sha_suffix = f" ({item_sha})" if item_sha else ""
        lines = wrap_text(item_text + sha_suffix, "Helvetica", 9, BULLET_MAX_W)
        for i, ln in enumerate(lines):
            if item_sha and i == len(lines) - 1 and ln.endswith(f"({item_sha})"):
                # Draw text before sha in black, sha portion in gray
                prefix = ln[: -len(f"({item_sha})")]
                c.setFillColor(black)
                c.drawString(TEXT_X, y, prefix)
                sha_x = TEXT_X + c.stringWidth(prefix, "Helvetica", 9)
                c.setFillColor(gray)
                c.drawString(sha_x, y, f"({item_sha})")
            else:
                c.setFillColor(black)
                c.drawString(TEXT_X, y, ln)
            y -= 13
        y -= 2

    y -= 5

    # Day separator
    c.setStrokeColor(separator)
    c.setLineWidth(0.3)
    c.line(LEFT, y + 4, RIGHT, y + 4)
    y -= 14

# --- Total at bottom ---
if y < 1 * inch:
    c.showPage()
    y = h - 1 * inch

y -= 5
c.setFont("Helvetica", 10)
c.setFillColor(gray)
c.drawString(LEFT, y, f"Total: {total_h}h {total_m}m")

c.save()
```

### Data format

Structure the data as a list of tuples — one tuple per day with a list of `(description, sha)` tuples. `sha` is a short (7-char) commit hash string if the bullet was derived from a commit, or `None` if no commit matches (e.g. meetings, env setup):

```python
days = [
    ("March 26", "1h 15m", [
        ("Onboarding call with anon team", None),
        ("Local dev environment setup (Node.js, Docker, Supabase)", None),
        ("Ran Prettier across existing codebase; began Tailwind setup", "303896e"),
    ]),
    # ... more days
]
```

When grouping multiple commits into one bullet, use the SHA of the primary/first commit in the group.

Day totals: format as `Xh Ym` (e.g. "2h 54m", "0h 27m") — sum of all sessions that day.
Grand total: sum all day totals, format as `Xh Ym`.

### Key rules

- **One row per day** with aggregated total and bullet-point list of work items
- **Each commit becomes a bullet** — summarized in plain English, not raw commit messages
- **Total goes at the bottom**, after all day groups — never at the top
- Day labels use format "March 26" (full month name, day number, no weekday)
- Font is Helvetica only (Bold for title and day headers, regular for everything else)
- No colors other than `#1a1a1a` (black), `#666666` (gray), `#cccccc` (light divider), `#e5e5e5` (day separator)
- Output filename is `colby_thomas_timesheet_<start>-<end>.pdf` where start/end are `mon_dd` (e.g. `mar_26`, `apr_3`) — lowercase 3-letter month, underscore, day number. Saved to the current project directory **and** copied to `~/Documents/`

### Step 5: Copy to Documents

Always copy the generated PDF to `~/Documents/`:

```bash
cp <project_dir>/colby_thomas_timesheet_<start>-<end>.pdf ~/Documents/
```

### Step 6: Verify

Read the generated PDF to confirm it renders correctly, then tell the user both file paths.
