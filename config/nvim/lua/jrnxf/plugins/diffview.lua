local actions = require('diffview.actions')

require('diffview').setup({
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
