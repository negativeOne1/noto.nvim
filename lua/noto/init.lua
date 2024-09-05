local view = require("noto.view")
local config = require("noto.config")

local M = {}

M.toggle = view.toggle
M.open = view.open
M.close = view.close
M.setup = config.setup

return M
