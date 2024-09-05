local M = {}

--@class NotoOptions
local defaults = {
  windows = {
    name = "NOTES",
    width = 0.3,
    height = 0.3,
    position = "center",
    path = vim.fn.stdpath("cache") .. "/todo.md",
  },
}

--@type NotoOptions
M.options = nil

function M.setup(options)
  if not options then
    return
  end
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

return setmetatable(M, {
  __index = function(_, k)
    if k == "options" then
      M.setup()
    end
    return rawget(M, k)
  end,
})
