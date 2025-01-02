local tex = require("util.latex")

-- TODO: 现在这个函数仍然存在一些问题，主要是会报错，尝试通过修改lspattach 来实现这个修正!
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
