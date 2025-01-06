-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local cn = require("util.autocorrect")
local Util = require("lazyvim.util")
local tex = require("util.latex")
-- local synctex = require("util.synctex_view")
local synctex = require("util.tdf")
local replace = require("util.replace_ai")
local choose = require("util.markdown_code")
local keymap = vim.keymap

vim.api.nvim_create_autocmd("CursorMovedI", {
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "tex" then
      if tex.in_item() == true then
        keymap.set("i", ";<CR>", ";<CR>\\item ", { noremap = true, silent = true })
        keymap.set("i", "'<CR>", "<CR>\\item ", { noremap = true, silent = true })
      else
        keymap.set("i", ";<CR>", ";<CR>", { noremap = true, silent = true })
        keymap.set("i", "'<CR>", "'<CR>", { noremap = true, silent = true })
      end
    end
  end,
})

-- Key mappings
keymap.set({ "i", "s" }, "jj", "<Esc>")
-- keymap.set({ "i", "s" }, "jk", "<Esc>")
-- keymap.set({ "i", "s" }, "kj", "<Esc>")

keymap.set("n", "<leader>h", "<cmd>noh<cr>", { desc = "no highlight" })

-- keymap.set("i", "<c-c>", "<cmd>lua require('luasnip.extras.select_choice')()<cr>")
-- keymap.set("i", "<c-s>", "<cmd>lua require('luasnip.extras.select_choice')()<Cr>")
keymap.set({ "i", "s" }, "<c-u>", "<cmd>lua require('luasnip.extras.select_choice')()<cr>")
keymap.set({ "i", "s" }, "<c-n>", "<Plug>luasnip-next-choice")
keymap.set({ "i", "s" }, "<c-p>", "<Plug>luasnip-prev-choice")

keymap.set("n", "<leader>h", function()
  local harpoon = require("harpoon")
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon Quick Menu" })

local function save_and_delete_last_line()
  local ft = vim.bo.filetype
  local cursor_pos = vim.fn.getpos(".") -- 记录光标位置

  if ft == "tex" or ft == "markdown" then
    -- 修复一些上游的问题: autoformat 插件会在最后一行多加一个空行，需要额外删除
    vim.cmd("w")
    local view = vim.fn.winsaveview()
    vim.api.nvim_buf_set_lines(0, -2, -1, false, {})
    vim.fn.winrestview(view)
    cn.autocorrect()
    vim.cmd("w")
  else
    vim.cmd("w")
  end
  vim.fn.setpos(".", cursor_pos) -- 恢复光标位置
end

keymap.set("n", "<leader>ua", function()
  cn.autocorrect()
end, { noremap = true, silent = true, desc = "AutoCorrect For Chinese File" })

-- Map <C-s> to the function
keymap.set({ "n", "v", "i" }, "<C-s>", function()
  save_and_delete_last_line()
  vim.cmd("stopinsert")
end, { noremap = true, silent = true })

keymap.set({ "i", "n", "s" }, "<c-z>", "<cmd>undo<cr>")

keymap.set("i", "<c-e>", "<esc><c-e>a")

-- rime_ls for Copilot-Chat
keymap.set("n", "<C-c>", function()
  vim.cmd("CopilotChat")
  vim.cmd("LspStart rime_ls")
end, { noremap = true, silent = true })
keymap.set("n", "<leader>aa", function()
  vim.cmd("CopilotChat")
  vim.cmd("LspStart rime_ls")
end, { noremap = true, silent = true, desc = "Toggle (Copilot-Chat)" })

keymap.set("i", "<C-d>", " ")

-- Map $ to L in normal mode
keymap.set({ "n", "s", "v" }, "L", "$", { noremap = true, silent = true })

-- Map 0 to H in normal mode
keymap.set({ "n", "s", "v" }, "H", "^", { noremap = true, silent = true })

-- pickbufferline

-- keymap.set("n", "<leader>bg", ":BufferLinePick<CR>", { noremap = true, silent = true })

-- 下面的是来自 Gilles Castel 的快速拼写修正的 keymap,
-- "It basically jumps to the previous spelling mistake [s, then picks the first suggestion 1z=, and then jumps back `]a. The <c-g>u in the middle make it possible to undo the spelling correction quickly."
keymap.set("i", "<c-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u")

-- 下面是来自 Gilles Castel 的图片插入代码, 见https://github.com/gillescastel/inkscape-figures
-- 需要注意的是, rofi 在 xorg 显示服务器上面才能正常工作.
-- 他的另一个项目, inkscape shortcut 也需要在 xorg 服务器下运行来捕获窗口.
keymap.set(
  "i",
  "<C-f>",
  [[ <Esc>: silent exec '.!inkscape-figures create "'.getline('.').'" "'.b:vimtex.root.'/figures/"'<CR><CR>:w<CR>]]
)

keymap.set(
  "n",
  "<C-f>",
  [[ : silent exec '!inkscape-figures edit "'.b:vimtex.root.'/figures/" > /dev/null 2>&1 &'<CR><CR>:redraw!<CR>]]
)

-- BufferLinePick
keymap.set("n", "<leader>bg", ":BufferLinePick<CR>", { noremap = true, silent = true })

local rime_active = false

-- 定义一个函数来切换 Rime 输入法
local function toggle_rime()
  if rime_active then
    vim.cmd("LspStop rime_ls")
  else
    vim.cmd("LspStart rime_ls")
  end
  rime_active = not rime_active
end

-- 设置快捷键激活 Rime 输入法
keymap.set(
  { "n", "i" },
  "<localleader>f",
  toggle_rime,
  { noremap = true, silent = true, desc = "Toggle Rime input method" }
)

keymap.set("i", "jn", function()
  require("lsp.rime_2").toggle_rime()
  _G.rime_toggled = not _G.rime_toggled
  _G.rime_ls_active = not _G.rime_ls_active
end, { noremap = true, silent = true, desc = "toggle rime-ls" })
-- windows manager with hammerspoon

local function is_rightmost_window()
  local current_win = vim.api.nvim_get_current_win()
  local current_pos = vim.api.nvim_win_get_position(current_win)[2]
  local max_col = current_pos

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local pos = vim.api.nvim_win_get_position(win)[2]
    if pos > max_col then
      max_col = pos
    end
  end

  return current_pos == max_col
end

local function is_leftmost_window()
  local current_win = vim.api.nvim_get_current_win()
  local current_pos = vim.api.nvim_win_get_position(current_win)[2]
  local min_col = current_pos

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local pos = vim.api.nvim_win_get_position(win)[2]
    if pos < min_col then
      min_col = pos
    end
  end

  return current_pos == min_col
end

local function to_right_window()
  if is_rightmost_window() then
    vim.fn.system("hs -c 'focusNextWindow()'")
  else
    vim.cmd("wincmd l")
  end
end

_G.to_right_window = to_right_window

-- switch to right window
keymap.set("n", "<C-l>", function()
  if is_rightmost_window() then
    vim.fn.system("hs -c 'focusNextWindow()'")
  else
    vim.cmd("wincmd l")
  end
end, { noremap = true, silent = true, desc = "Move to right window" })

-- same for left
keymap.set("n", "<C-h>", function()
  if is_leftmost_window() then
    vim.fn.system("hs -c 'focusPreviousWindow()'")
  else
    vim.cmd("wincmd h")
  end
end, { noremap = true, silent = true, desc = "Move to left window" })

-- sniprun  直接触发
keymap.set({ "n" }, "<leader>cr", function()
  local caret = vim.fn.winsaveview()
  vim.cmd("%SnipRun")
  vim.fn.winrestview(caret)
end, { noremap = true, silent = true, desc = "Code run full" })

keymap.set({ "v" }, "<leader>cr", function()
  vim.cmd("SnipRun")
end, { noremap = true, silent = true, desc = "Code run selected" })

-- sync windows
_G.is_windows_synced = false

function ToggleSyncWindows()
  if _G.is_windows_synced then
    vim.cmd("windo set noscrollbind nocursorbind")
    _G.is_windows_synced = false
    print("Windows unsynced")
  else
    vim.cmd("windo set scrollbind cursorbind")
    _G.is_windows_synced = true
    print("Windows synced")
  end
end

keymap.set(
  "n",
  "<leader>wS",
  ":lua ToggleSyncWindows()<CR>",
  { noremap = true, silent = true, desc = "Toggle Sync Windows" }
)

vim.keymap.set({ "n", "v" }, "<leader>ct", require("stay-centered").toggle, { desc = "Toggle stay-centered.nvim" })

-- mathematica calculation with float window, trigger when ft = md of tex
keymap.set("n", "<f6>", function()
  require("util.windows").create_floating_window()
end, { noremap = true, silent = true, desc = "Mathematica Calculation" })

local telescope = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function open_selected_telescope(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  vim.fn.system({ "open", selection.path })
end

local function search_selected_word()
  local prev = vim.fn.expand("<cword>")
  local word = prev .. ".nb"

  local search_dir = "/Library/Wolfram/Documentation/14.1/zh-hans-cn/Documentation/ChineseSimplified/"

  telescope.find_files({
    prompt_title = "Search for " .. word,
    cwd = search_dir,
    search_dirs = { search_dir },
    default_text = word,
  })
end

local function search_and_open_selected_word()
  local prev = vim.fn.expand("<cword>")
  local word = prev .. ".nb"
  local confpath = vim.fn.stdpath("config")
  local script = confpath .. "/fzf_mmadoc.sh"

  print("Executing script: " .. script .. " with word: " .. word)
  local result = vim.fn.system(script .. " " .. word)
  print(result)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "mma",
  callback = function()
    keymap.set({ "v", "n" }, "<leader>fd", function()
      search_and_open_selected_word()
    end, { noremap = true, silent = true, desc = "Go Mathematica Definition" })
    keymap.set({ "v", "n" }, "<leader>fD", function()
      search_selected_word()
    end, { noremap = true, silent = true, desc = "Search Mathematica Definition" })
  end,
})

keymap.set("n", "<leader>ct", function()
  require("stay-centered").toggle()
  _G.is_center_open = not _G.is_center_open
end, { desc = "Toggle stay-centered" })

-- jieba 分词
vim.keymap.set(
  { "x", "n" },
  "B",
  '<cmd>lua require("jieba_nvim").wordmotion_B()<CR>',
  { noremap = false, silent = true }
)
vim.keymap.set(
  { "x", "n" },
  "b",
  '<cmd>lua require("jieba_nvim").wordmotion_b()<CR>',
  { noremap = false, silent = true }
)
vim.keymap.set(
  { "x", "n" },
  "w",
  '<cmd>lua require("jieba_nvim").wordmotion_w()<CR>',
  { noremap = false, silent = true }
)
vim.keymap.set(
  { "x", "n" },
  "W",
  '<cmd>lua require("jieba_nvim").wordmotion_W()<CR>',
  { noremap = false, silent = true }
)
vim.keymap.set(
  { "x", "n" },
  "E",
  '<cmd>lua require("jieba_nvim").wordmotion_E()<CR>',
  { noremap = false, silent = true }
)
vim.keymap.set(
  { "x", "n" },
  "e",
  '<cmd>lua require("jieba_nvim").wordmotion_e()<CR>',
  { noremap = false, silent = true }
)
vim.keymap.set(
  { "x", "n" },
  "ge",
  '<cmd>lua require("jieba_nvim").wordmotion_ge()<CR>',
  { noremap = false, silent = true }
)
vim.keymap.set(
  { "x", "n" },
  "gE",
  '<cmd>lua require("jieba_nvim").wordmotion_gE()<CR>',
  { noremap = false, silent = true }
)
