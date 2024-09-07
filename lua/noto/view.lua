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

function M.get_buffer(name)
  local buf_nr = vim.fn.bufnr(name)
  if buf_nr > 0 then
    print("BUFNR", buf_nr)
    if vim.api.nvim_buf_is_valid(buf_nr) and vim.api.nvim_buf_is_loaded(buf_nr) then
      print("BUFNR RETURN", buf_nr)
      return buf_nr
    else
      vim.api.nvim_buf_delete(buf_nr, { force = true })
      buf_nr = 0
    end
  end
  if buf_nr < 1 then
    buf_nr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("filetype", "todo", { buf = buf_nr })
  end
  return buf_nr
end

function M.create(win)
  local opts = M.getWindow(win)

  M.set_keymaps()

  local bufname = string.format("noto [%s]", win)
  local bufnr = M.get_buffer(bufname)

  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd("edit " .. opts["path"])
  end)
  vim.api.nvim_buf_set_name(bufnr, bufname)

  local width = M.calc_width(opts)
  local height = M.calc_height(opts)
  local position = M.calc_position(opts)

  w = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    width = width,
    height = height,
    row = position.row,
    col = position.col,
    style = "minimal",
    border = "shadow",
  })

  M.win[win] = w
  M.buf[win] = bufnr
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
      vim.api.nvim_command("command! OK s/// | noh")
      vim.api.nvim_command("command! NOK s//󰄮/ | noh")
      vim.api.nvim_command("command! CB s/|󰄮// | noh")
      vim.api.nvim_command("nmap <leader>n :New<CR>")
      vim.api.nvim_command("nmap <leader>c :CB  <CR>")
      vim.api.nvim_command("nmap <leader>o :OK  <CR>")
      vim.api.nvim_command("nmap <leader>b :NOK <CR>")
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
  t = function(w)
    if M.is_open(w) then
      M.close(w)
    else
      M.open(w)
    end
  end

  if not win then
    for _, v in ipairs(config.options.windows) do
      t(v["name"])
    end
  else
    t(win)
  end
end

return M
