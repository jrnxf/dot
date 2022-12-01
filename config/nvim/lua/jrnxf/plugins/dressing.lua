require('dressing').setup({
  input = {
    enabled = false, -- dont conflict with noice
    -- relative = 'editor',
  },
  select = {
    telescope = require('telescope.themes').get_dropdown(), -- useful for code actions. i dont think noice has any ui for select (yet)
  },
})
