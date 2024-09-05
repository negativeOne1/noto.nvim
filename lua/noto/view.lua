local config = require("noto.config")

local M = {}

M.options = { config.options }
M.win = {}
M.buf = {}
M.state = {}

function M.is_open(win)
  return M.win[win] and vim.api.nvim_win_is_valid(M.win[win])
end

function M.getWindow(win)
  for _, v in ipairs(config.options.windows) do
    if v["name"] == win then
      print(v)
      return v
    end
  end
end

-- get the width of the window, minimum 30
function M.calc_width(opts)
  local w = math.floor(vim.o.columns * opts["width"])
  if w < 30 then
    return 30
  end
  return w
end

-- get the height of the window, minimum 10
function M.calc_height(opts)
  local h = math.floor(vim.o.lines * opts["height"])
  if h < 10 then
    return 10
  end
  return h
end

function M.calc_position(opts)
  local height = M.calc_height(opts)
  local width = M.calc_width(opts)
  local padding_y = opts["padding_y"] or 0
  local padding_x = opts["padding_x"] or 0
  local row = 0
  local col = 0
  if opts["position"] == "center" then
    row = math.floor((vim.o.lines - height) / 2)
    col = math.floor((vim.o.columns - width) / 2)
  elseif opts["position"] == "N" then
    row = 0 + padding_y
    col = math.floor((vim.o.columns - width) / 2)
  elseif opts["position"] == "NE" then
    row = 0 + padding_y
    col = vim.o.columns - (width + padding_x)
  elseif opts["position"] == "E" then
    row = math.floor((vim.o.lines - height) / 2)
    col = vim.o.columns - (width + padding_x)
  elseif opts["position"] == "SE" then
    row = vim.o.lines - (height + padding_y)
    col = vim.o.columns - (width + padding_x)
  elseif opts["position"] == "S" then
    row = vim.o.lines - (height + padding_y)
    col = math.floor((vim.o.columns - width) / 2)
  elseif opts["position"] == "SW" then
    row = vim.o.lines - (height + padding_y)
    col = 0 + padding_x
  elseif opts["position"] == "W" then
    row = math.floor((vim.o.lines - height) / 2)
    col = 0 + padding_x
  elseif opts["position"] == "NW" then
    row = 0 + padding_y
    col = 0 + padding_x
  end
  return { row = row, col = col }
end

function M.create(win)
  local opts = M.getWindow(win)

  M.set_keymaps()
  M.buf[win] = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_call(M.buf[win], function()
    vim.cmd("edit " .. opts["path"])
  end)

  vim.api.nvim_set_option_value("filetype", "todo", { buf = M.buf[win] })

  local width = M.calc_width(opts)
  local height = M.calc_height(opts)
  local position = M.calc_position(opts)

  M.win[win] = vim.api.nvim_open_win(M.buf[win], true, {
    relative = "editor",
    width = width,
    height = height,
    row = position.row,
    col = position.col,
    style = "minimal",
    border = "shadow",
  })
end

function M.close(win)
  if not M.is_open(win) then
    return
  end

  vim.api.nvim_win_close(M.win[win], true)
  vim.api.nvim_buf_delete(M.buf[win], { force = true })
  M.win[win] = nil
  M.buf[win] = nil
end

function M.set_keymaps()
  local todoSettingGroup = vim.api.nvim_create_augroup("Todo", { clear = true })
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.todo", "*.td", "todo" },
    callback = function()
      vim.api.nvim_command("command! New :normal o<space>")
      vim.api.nvim_command("command! OK s///g")
      vim.api.nvim_command("command! NOK s//󰄮/g")
      vim.api.nvim_command("command! CB s/|󰄮//g")
      vim.api.nvim_command("nmap <leader>n :New<CR>")
      vim.api.nvim_command("nmap <leader>c :CB<CR>")
      vim.api.nvim_command("nmap <leader>o :OK<CR>")
      vim.api.nvim_command("nmap <leader>b :NOK<CR>")
      vim.api.nvim_command("nmap <leader>q :lua require('todo').close()<CR>")
    end,
    group = todoSettingGroup,
  })
end

function M.open(win)
  if M.is_open(win) then
    return
  end

  M.close(win)
  M.create(win)
end

function M.toggle(win)
  if M.is_open(win) then
    M.close(win)
  else
    M.open(win)
  end
end

return M