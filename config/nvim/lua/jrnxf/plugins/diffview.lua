local utils = require('jrnxf.lib.utils')
local actions = require('diffview.actions')

require('diffview').setup({
  diff_binaries = false,
  enhanced_diff_hl = true,
  git_cmd = { 'git' },
  use_icons = true,
  icons = {
    folder_closed = '',
    folder_open = '',
  },
  signs = {
    fold_closed = '',
    fold_open = '',
  },
  -- Available for: diff_view, file_history_view
  view = {
    default = {
      -- Config for changed files, and staged files in diff views.
      layout = 'diff2_horizontal',
    },

    diff_view = {
      layout = 'diff2_horizontal',
      disable_diagnostics = true,
    },
    file_history_view = {
      layout = 'diff2_horizontal',
      disable_diagnostics = true,
    },
    merge_tool = {
      layout = 'diff3_mixed',
      disable_diagnostics = true,
    },
  },
  file_panel = {
    listing_style = 'tree',
    tree_options = {
      flatten_dirs = true,
      folder_statuses = 'only_folded',
    },
    win_config = {
      position = 'left',
      width = 35,
    },
  },
  file_history_panel = {
    log_options = {
      single_file = {
        diff_merges = 'combined',
      },
      multi_file = {
        diff_merges = 'first-parent',
      },
    },
    win_config = {
      position = 'bottom',
      height = 16,
    },
  },
  commit_log_panel = {
    win_config = {},
  },
  default_args = {
    DiffviewOpen = {},
    DiffviewFileHistory = {},
  },
  hooks = {
    ---@param view StandardView
    view_opened = function(view)
      local function post_layout()
        -- M.tbl_ensure(view, 'winopts.diff2.a')
        -- M.tbl_ensure(view, 'winopts.diff2.b')
        view.winopts.diff2.a = utils.tbl_union_extend_or_overwrite(view.winopts.diff2.a, {
          winhl = {
            'DiffChange:DiffAddAsDelete',
            'DiffText:DiffDeleteText',
          },
        })
        view.winopts.diff2.b = utils.tbl_union_extend_or_overwrite(view.winopts.diff2.b, {
          winhl = {
            'DiffChange:DiffAdd',
            'DiffText:DiffAddText',
          },
        })
      end
      view.emitter:on('post_layout', post_layout)
      post_layout()
    end,
  },
  keymaps = {
    view = {
      ['gf'] = actions.goto_file_edit,
      ['-'] = actions.toggle_stage_entry,
    },
    file_panel = {
      ['<cr>'] = actions.focus_entry,
      ['s'] = actions.toggle_stage_entry,
      ['gf'] = actions.goto_file_edit,
    },
    file_history_panel = {
      ['<cr>'] = actions.focus_entry,
      ['gf'] = actions.goto_file_edit,
    },
  },
})
