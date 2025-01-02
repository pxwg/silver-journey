--这个现在还不能使用, 当前的数学识别还依靠vimtex
local M = {}

-- environment detection via treesitter

local MATH_NODES = {
  displayed_equation = true,
  inline_formula = true,
  math_environment = true,
}

local ts_utils = require("nvim-treesitter.ts_utils")

M.test = function()
  return true
end
M.in_env = function(env)
  local node = ts_utils.get_node_at_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  while node do
    if node:type() == "generic_environment" then
      local begin = node:child(0)
      local name = begin:field("name")
      if name[1] and vim.treesitter.get_node_text(name[1], bufnr, nil) == "{" .. env .. "}" then
        return true
      end
    end
    node = node:parent()
  end
  return false
end
--
-- M.in_text = function()
--   local node = ts_utils.get_node_at_cursor()
--   while node do
--     if node:type() == "text_mode" then
--       return true
--     elseif MATH_NODES[node:type()] then
--       return false
--     end
--     node = node:parent()
--   end
--   return true
-- end
--
-- M.in_mathzone = function()
--   return not M.in_text()
-- end

-- environment detection via vimtex

M.in_mathzone = function()
  -- The `in_mathzone` function requires the VimTeX plugin
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

M.in_text = function()
  return not M.in_mathzone()
end

M.in_item = function()
  return M.in_env("itemize") or M.in_env("enumerate")
end

M.in_tikz = function()
  return M.in_env("tikzpicture")
end

M.in_center = function()
  return M.in_env("center")
end

M.in_figure = function()
  return M.in_env("figure")
end

M.in_table = function()
  return M.in_env("xltabular")
end
-- -- For markdown
M.in_latex = function()
  local captures = vim.treesitter.get_captures_at_cursor(0)
  for _, capture in ipairs(captures) do
    if capture == "markup.math" then
      return "math"
    end
  end
  return false
end

M.clean = function()
  local current_dir = vim.fn.expand("%:p:h")
  local file_types = { "aux", "log", "out", "fls", "fdb_latexmk", "bcf", "run.xml", "toc", "DS_Store", "bak*", "dvi" }
  for _, file_type in ipairs(file_types) do
    local command = "rm " .. current_dir .. "/*." .. file_type
    vim.api.nvim_call_function("system", { command })
  end
end

-- M.format = function()
--   local current_file = vim.fn.expand("%:p")
--   local latexindent = "latexindent -g /dev/null " .. current_file .. " -wd -l ~/Documents/Latex/latexindent.yaml"
--   local build = "pdflatex " .. current_file
--   vim.api.nvim_call_function("system", { build })
--   vim.cmd("w")
--   M.clean()
--   vim.api.nvim_call_function("system", { latexindent })
--   vim.cmd("e")
--   vim.cmd("normal! zz")
--   -- vim.cmd("TexlabForward")
-- end

M.sympy_calc = function()
  local selected_text = vim.fn.getreg("v")
  print(selected_text)
  vim.api.nvim_out_write(selected_text)
end

return M
