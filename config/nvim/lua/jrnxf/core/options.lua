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

vim.opt.autoindent = true
vim.opt.backupdir = backup
vim.opt.background = 'dark'
vim.opt.belloff = 'all'
vim.opt.breakindent = true
vim.opt.breakindentopt = {
  shift = 2, -- wrapped line's beginning will be shifted by the given number of
}
vim.opt.clipboard = 'unnamedplus'
vim.opt.cmdheight = 1
vim.opt.completeopt = 'menu,menuone,noselect'
vim.opt.cursorline = true
vim.opt.directory = swap
vim.opt.expandtab = true
-- https://www.compart.com/en/unicode/U+XXXX (unicode character code)
vim.opt.fillchars = {
  fold = '·', -- MIDDLE DOT (U+00B7, UTF-8: C2 B7)
  horiz = '━', -- BOX DRAWINGS HEAVY HORIZONTAL (U+2501, UTF-8: E2 94 81)
  horizdown = '┳', -- BOX DRAWINGS HEAVY DOWN AND HORIZONTAL (U+2533, UTF-8: E2 94 B3)
  horizup = '┻', -- BOX DRAWINGS HEAVY UP AND HORIZONTAL (U+253B, UTF-8: E2 94 BB)
  vert = '┃', -- BOX DRAWINGS HEAVY VERTICAL (U+2503, UTF-8: E2 94 83)
  vertleft = '┫', -- BOX DRAWINGS HEAVY VERTICAL AND LEFT (U+252B, UTF-8: E2 94 AB)
  vertright = '┣', -- BOX DRAWINGS HEAVY VERTICAL AND RIGHT (U+2523, UTF-8: E2 94 A3)
  verthoriz = '╋', -- BOX DRAWINGS HEAVY VERTICAL AND HORIZONTAL (U+254B, UTF-8: E2 95 8B)
}

vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.inccommand = 'split' -- shows the effects of |:substitute|, |:smagic|, |:snomagic| and user commands with the |:command-preview| flag as you type.
vim.opt.incsearch = true
vim.opt.laststatus = 3
vim.opt.list = true
vim.opt.listchars = o.listchars
  + 'nbsp:⦸' --
  + 'tab:▷┅' --
  + 'extends:»' --
  + 'precedes:«' --
  + 'trail:•' --
-- + 'eol:↴' --
-- + 'space:⋅' --
vim.opt.mouse = 'a'
vim.opt.number = true
vim.opt.pumblend = 5 -- p(op)u(p)m(enu) transparency 0 = opaque, 100 = fully transparent
vim.opt.pumheight = 30 -- p(op)u(p)m(enu) height
vim.opt.pumwidth = 60 -- p(op)u(p)m(enu) height
vim.opt.relativenumber = true
vim.opt.scrolloff = 3
vim.opt.shiftwidth = 2
vim.opt.showbreak = '↳ '
vim.opt.showmode = false
vim.opt.sidescrolloff = 3
vim.opt.signcolumn = 'yes' -- extra line to left of numbers for signs
vim.opt.smartcase = true
vim.opt.splitbelow = true -- :split   new window on bottom of current one
vim.opt.splitright = true -- :vsplit  new window to right of current one
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.textwidth = 80
vim.opt.undodir = undo
vim.opt.undofile = true
vim.opt.viewdir = view
vim.opt.wildignore = { '.git/*', 'node_modules/*' }
vim.opt.wildignorecase = true
-- configured be feline
-- vim.opt.winbar = '%=%m %f' -- off to right, [+] if modified, file path --
vim.opt.wrap = false
