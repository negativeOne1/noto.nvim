
<h1 align="center"> noto.nvim </h1>
<p align="center"><sup>A note and todo plugin for nvim written in lua</sup></p>

![image](https://github.com/user-attachments/assets/8d08ea84-340d-46fa-8710-dc551a208958)

### ✨ Features

- creates many beautiful flowing editors
- supports basic note taking
- support todo lists
- more coming

### 🚀 Installation

- With [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- add this to your lua/plugins.lua, lua/plugins/init.lua,  or the file you keep your other plugins:
return {
  'negativeOne1/noto.nvim',
  config = function()
    require("noto").setup({
      windows = {
        {
          name = "todo",
          width = 0.3,
          height = 0.3,
          position = "NE",
          padding_x = 10,
          padding_y = 5,
          path = vim.fn.stdpath("cache") .. "/todo.td",
        },
        {
          name = "notes",
          width = 0.3,
          height = 0.3,
          position = "SE",
          padding_x = 10,
          padding_y = 15,
          path = vim.fn.stdpath("cache") .. "/notes.md",
        },
      },
    })

    vim.keymap.set("n", "<leader>1", ":Noto todo<CR>", { noremap = true, silent = true, desc = "Todo" })
    vim.keymap.set("n", "<leader>2", ":Noto notes<CR>", { noremap = true, silent = true, desc = "Notes" })
  end,
}

```
