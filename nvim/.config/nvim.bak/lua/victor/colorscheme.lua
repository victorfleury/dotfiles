local colorscheme = "everforest"
local background = os.getenv("BG")

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  return
end

if background == "dark" then
    vim.opt.background = "dark"
else
    vim.opt.background = "light"
end
