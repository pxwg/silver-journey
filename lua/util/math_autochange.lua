local tex = require("util.latex")

local function switch_rime_math()
  if vim.bo.filetype == "tex" then
    -- if vim.fn.mode() == "i" and vim.bo.filetype == "tex" then
    -- in the mathzone or table or tikz and rime is active, disable rime
    if (tex.in_mathzone() == true or tex.in_tikz() == true) and rime_ls_active == true then
      if _G.rime_toggled == true then
        require("lsp.rime_2").toggle_rime()
        _G.rime_toggled = false
      end
      -- in the text but rime is not active(by hand), do nothing
    elseif _G.rime_ls_active == false then
      -- in the text but rime is active(by hand ), thus the configuration is for mathzone or table or tikz
    else
      if _G.rime_toggled == false then
        require("lsp.rime_2").toggle_rime()
        _G.rime_toggled = true
      end
    end
  end
end

vim.api.nvim_create_autocmd("CursorMovedI", {
  pattern = "*.tex",
  callback = switch_rime_math,
})

local function switch_rime_math_md()
  if vim.bo.filetype == "markdown" then
    -- in the mathzone or table or tikz and rime is active, disable rime
    if tex.in_latex() and rime_ls_active == true then
      if _G.rime_toggled == true then
        require("lsp.rime_2").toggle_rime()
        _G.rime_toggled = false
      end
      -- in the text but rime is not active(by hand), do nothing
    elseif _G.rime_ls_active == false then
      -- in the text but rime is active(by hand ), thus the configuration is for mathzone or table or tikz
    else
      if _G.rime_toggled == false then
        require("lsp.rime_2").toggle_rime()
        _G.rime_toggled = true
      end
      if _G.rime_ls_active and _G.rime_toggled then
      end
    end
  end
end

vim.api.nvim_create_autocmd("CursorMovedI", {
  pattern = "*",
  callback = switch_rime_math_md,
})
