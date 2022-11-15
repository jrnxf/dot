local global = require('core.global')

local function load_options()
  local global_opts = {
    -- General
    background = 'dark',
    clipboard = 'unnamedplus',
    scrolloff = 8,
    sidescrolloff = 8,
    splitbelow = true, -- :split   new window on bottom of current one
    splitright = true, -- :vsplit  new window to right of current one
    termguicolors = true,
    mouse = 'a',
    cursorline = true,
    number = true,
    relativenumber = true,
    signcolumn = 'yes', -- extra line to left of numbers for signs
    wrap = false,

    -- Completion
    completeopt = 'menuone,noselect',
    pumblend = 5, -- p(op)u(p)m(enu) transparency 0 = opaque, 100 = fully transparent
    pumheight = 10, -- p(op)u(p)m(enu) height
    pumwidth = 20, -- p(op)u(p)m(enu) height

    -- Performance
    lazyredraw = true,

    -- winbar
    winbar = '%=%m %f', -- off to right, [+] if modified, file path

    -- Search
    inccommand = 'nosplit', -- show substitutions incrementally
    ignorecase = true,
    smartcase = true,
    wildignore = { '.git/*', 'node_modules/*' },
    wildignorecase = true,

    -- Backups
    backup = false,
    writebackup = false,
    swapfile = false,

    -- Undos
    undodir = global.cache_dir .. 'undo/',
    undofile = true,

    -- Tabs
    expandtab = true,
    autoindent = true,
    tabstop = 2,
    shiftwidth = 2,
  }

  for name, value in pairs(global_opts) do
    vim.opt[name] = value
  end
end

load_options()
