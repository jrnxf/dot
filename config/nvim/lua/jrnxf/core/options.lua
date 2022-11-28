local path = require('jrnxf.lib.path')

local o = vim.opt

local backup = path.join(path.cachehome, 'backup')
local swap = path.join(path.cachehome, 'swap')
local undo = path.join(path.cachehome, 'undo')
local view = path.join(path.cachehome, 'view')

path.create_dir(backup)
path.create_dir(swap)
path.create_dir(undo)
path.create_dir(view)

o.autoindent = true
o.backupdir = backup
o.background = 'dark'
o.belloff = 'all'
o.breakindent = true
o.breakindentopt = {
  shift = 2, -- wrapped line's beginning will be shifted by the given number of
}
o.clipboard = 'unnamedplus'
-- o.cmdheight = 0
o.completeopt = 'menu,menuone,noselect'
o.cursorline = true
o.directory = swap
o.expandtab = true
-- https://www.compart.com/en/unicode/U+XXXX (unicode character code)
o.fillchars = {
  fold = '·', -- MIDDLE DOT (U+00B7, UTF-8: C2 B7)
  horiz = '━', -- BOX DRAWINGS HEAVY HORIZONTAL (U+2501, UTF-8: E2 94 81)
  horizdown = '┳', -- BOX DRAWINGS HEAVY DOWN AND HORIZONTAL (U+2533, UTF-8: E2 94 B3)
  horizup = '┻', -- BOX DRAWINGS HEAVY UP AND HORIZONTAL (U+253B, UTF-8: E2 94 BB)
  vert = '┃', -- BOX DRAWINGS HEAVY VERTICAL (U+2503, UTF-8: E2 94 83)
  vertleft = '┫', -- BOX DRAWINGS HEAVY VERTICAL AND LEFT (U+252B, UTF-8: E2 94 AB)
  vertright = '┣', -- BOX DRAWINGS HEAVY VERTICAL AND RIGHT (U+2523, UTF-8: E2 94 A3)
  verthoriz = '╋', -- BOX DRAWINGS HEAVY VERTICAL AND HORIZONTAL (U+254B, UTF-8: E2 95 8B)
}
o.formatoptions = o.formatoptions -- :help fo-table
  + 'c' -- auto wrap comments using textwith
  + 'q' -- formmating of comments w/ `gq`
  + 'l' -- long lines are not broken up
  + 'j' -- remove comment leader when joning comments
  + 'r' -- continue comment with enter
  - 'o' -- but not w/ o and o, dont continue comments
  + 'n' -- smart auto indenting inside numbered lists
  - '2' -- this is not grade school anymore
o.ignorecase = true
o.inccommand = 'nosplit'
o.lazyredraw = true
o.laststatus = 3
o.list = true
o.listchars = o.listchars
  + 'nbsp:⦸' -- CIRCLED REVERSE SOLIDUS (U+29B8, UTF-8: E2 A6 B8)
  + 'tab:▷┅' -- WHITE RIGHT-POINTING TRIANGLE (U+25B7, UTF-8: E2 96 B7)
  + 'extends:»' -- RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00BB, UTF-8: C2 BB)
  + 'precedes:«' -- LEFT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00AB, UTF-8: C2 AB)
  + 'trail:•' -- BULLET (U+2022, UTF-8: E2 80 A2)
o.mouse = 'a'
o.number = true
o.pumblend = 5 -- p(op)u(p)m(enu) transparency 0 = opaque, 100 = fully transparent
o.pumheight = 10 -- p(op)u(p)m(enu) height
o.pumwidth = 20 -- p(op)u(p)m(enu) height
o.relativenumber = true
o.scrolloff = 3
o.shiftwidth = 2
o.shortmess = o.shortmess
  + 'A' -- ignore annoying swapfile messages
  + 'T' -- truncate non-file messages in middle
  + 'W' -- dont echo '[w]/[written]' when writing
  + 'a' -- use abbreviations in message '[ro]' instead of '[readonly]'
  + 'o' -- overwrite file-written mesage
  + 't' -- truncate file messages at start
  + 'c' -- dont show matching messages
o.showbreak = '↳ '
o.showmode = false
o.sidescrolloff = 3
o.signcolumn = 'yes' -- extra line to left of numbers for signs
o.smartcase = true
o.splitbelow = true -- :split   new window on bottom of current one
o.splitright = true -- :vsplit  new window to right of current one
o.tabstop = 2
o.termguicolors = true
o.textwidth = 80
o.undodir = undo
o.undofile = true
o.viewdir = view
o.wildignore = { '.git/*', 'node_modules/*' }
o.wildignorecase = true
-- o.winbar = '%=%m %f' -- off to right, [+] if modified, file path
o.wrap = false
