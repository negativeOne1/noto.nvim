vim.api.nvim_create_user_command('Noto', 'lua require("noto").toggle(<f-args>)', {
  nargs = '?',
  complete = 'customlist,v:lua.notocomplete',
})
