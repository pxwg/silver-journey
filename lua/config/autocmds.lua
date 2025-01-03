-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Set conceal level
local keymap = vim.keymap
local tex = require("util.latex")
local toggle_rime_and_set_flag = function()
  require("lsp.rime_2").toggle_rime()
  rime_toggled = false
end
local tdf = require("util.tdf")

require("lsp.rime_2").setup_rime()

-- 定义一个命令来同步所有窗口的滚动和光标移动
vim.api.nvim_create_user_command("SyncWindows", function()
  vim.cmd("windo set scrollbind cursorbind")
end, {})

vim.api.nvim_create_user_command("SyncWindowsClear", function()
  vim.cmd("windo set noscrollbind nocursorbind")
end, {})

-- import quotes
local quotes = {}
local home = os.getenv("HOME")
local file_path = home .. "/quotes.txt"

local file = io.open(file_path, "r")

if file then
  for line in file:lines() do
    table.insert(quotes, line)
  end
  file:close()
else
  print("无法打开文件")
end

math.randomseed(os.time())
local random_quote = quotes[math.random(#quotes)]

vim.cmd([[set conceallevel=2]])

-- 基本逻辑: 在text 区域，rime_toggle = true 始终成立, rime_ls_active = true 在中文输入法下成立。如果在数学区域，则rime_toggle = false, rime_ls_active = true 应当始终成立, 如果

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "*.md", "*.tex" },
  callback = function()
    local old_pattern = _G.rime_toggled
    local old_active = _G.rime_ls_active
    -- TODO: deactivate rime from user update
    -- if not _G.rime_ls_active and not _G.rime_ls_active then
    -- return nil
    -- else
    if old_pattern == false then
      vim.cmd("LspStart rime_ls")
      require("lsp.rime_2").toggle_rime()
      _G.rime_toggled = true
      _G.rime_ls_active = true
    else
      vim.cmd("LspStart rime_ls")
    end
  end,
})

require("util.math_autochange")

-- TODO: 让这段代码可以监控数学区域内的中文输入法是否打开，如果打开则打印到lualine ✅
-- TODO: 支持英文输入的状态栏检测(单buffer) 每次进入buffer  需要手动改变输入法✅

if vim.g.neovide then
  vim.g.neovide_scale_factor = 0.8
  vim.o.guifont = "JetBrainsMono_Nerd_Font:h21"
  vim.g.neovide_fullscreen = true
  vim.g.neovide_refresh_rate = 144
  vim.g.neovide_transparency = 1
  vim.g.neovide_transparency_point = 0.8
  vim.opt.linespace = -1
  vim.g.neovide_show_border = false
  vim.g.neovide_cursor_animation_length = 0.03
  vim.g.neovide_show_border = false
end

if string.match(vim.env.PATH, "tex") then
  vim.notify(random_quote, vim.log.levels.INFO, { title = "今日格言", position = "bottom" })
end

vim.cmd([[
" set spell
set spelllang=en,cjk]])

-- local ts_utils = require("nvim-treesitter.ts_utils")
--
-- local function is_comment()
--   local node = ts_utils.get_node_at_cursor()
--   while node do
--     if node:type() == "comment" then
--       return true
--     end
--     node = node:parent()
--   end
--   return false
-- end
--
-- local rime_ls_active_f = function()
--   local clients = vim.lsp.get_active_clients()
--   for _, client in ipairs(clients) do
--     if client.name == "rime_ls" then
--       return true
--     end
--   end
--   return false
-- end
--
-- -- cannot be used for now
-- vim.api.nvim_create_autocmd("CursorMoved", {
--   pattern = "*",
--   callback = function()
--     local ft = vim.bo.filetype
--     if ft ~= "tex" and ft ~= "markdown" and ft ~= "copilot-chat" then
--       if is_comment() and rime_ls_active_f() then
--         vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<localleader>f", true, true, true), "n", false)
--         print("restart")
--       elseif is_comment() and rime_ls_active_f() == false then
--         vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<localleader>f", true, true, true), "n", false)
--         print("start")
--       elseif is_comment() == false and rime_ls_active_f() then
--         vim.api.nvim_command("LspStop rime_ls")
--       end
--     end
--   end,
-- })

-- 监听hammerspoon的文件变化，实现双向查找。

local uv = vim.loop
local handle

local function watch_file_changes()
  local watch_file_path = "/tmp/nvim_hammerspoon_latex.txt"

  local function on_change(err, filename, status)
    if err then
      print("Error watching file:", err)
      return
    end
    if status.change then
      tdf.synctex_inverse()
    end
  end

  if not handle then
    handle = uv.new_fs_event()
    uv.fs_event_start(handle, watch_file_path, {}, vim.schedule_wrap(on_change))
  end
end

-- 执行tdf.synctex_inverse()

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "tex",
--   callback = function()
--     watch_file_changes()
--   end,
-- })

-- Disable autoformat for latex files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "tex" },
  callback = function()
    watch_file_changes()
    vim.b.autoformat = false
    vim.diagnostic.enable(false)
  end,
})

-- Disable autoformat for markdown files

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "markdown" },
  callback = function()
    vim.b.autoformat = false
    vim.diagnostic.enable(false)
  end,
})

-- mathematica snippets
vim.api.nvim_create_autocmd("FileType", {
  pattern = "mma",
  callback = function()
    local root_dir = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1])

    local client = vim.lsp.start({
      name = "wolfram-lsp",
      cmd = {
        "/Applications/Wolfram.app/Contents/MacOS/WolframKernel",
        "kernel",
        "-noinit",
        "-noprompt",
        "-nopaclet",
        "-noicon",
        "-nostartuppaclets",
        "-run",
        'Needs["LSPServer`"];LSPServer`StartServer[]',
      },
      root_dir = root_dir,
      handlers = {
        ["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
          -- 只显示错误和警告
          severity_sort = true,
          underline = true,
          virtual_text = {
            severity_limit = "Warning",
          },
          signs = {
            severity_limit = "Warning",
          },
        }),
      },
    })

    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
    vim.keymap.set("n", "<leader>kd", vim.diagnostic.open_float)
    vim.keymap.set("n", "<leader>kw", vim.diagnostic.setqflist)
    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help)
    vim.keymap.set("n", "K", vim.lsp.buf.hover)
    vim.keymap.set("n", "gr", vim.lsp.buf.references)
    -- This requires Telescope to be installed.
    vim.keymap.set("n", "<leader>d", ":Telescope lsp_document_symbols<CR>", { noremap = true, silent = true })

    -- vim.notify("Wolfram LSP started", vim.log.levels.INFO, { title = "Wolfram LSP" })
    require("util.lang-mma").check_wolfarm()
    vim.lsp.buf_attach_client(0, client)
  end,
})
_G.notify_state = false

require("util.formatter")

-- This is for firenvim

if vim.g.started_by_firenvim then
  vim.api.nvim_create_autocmd("BufWritePost", {
    callback = require("util.firenvim").adjust_minimum_lines,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    callback = require("util.firenvim").adjust_minimum_lines,
  })

  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = "*.txt",
    command = "set filetype=markdown",
  })
end

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<C-o>"] = function(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          vim.fn.system({ "open", selection.path })
        end,
      },
    },
  },
})

-- auto delate untitled file

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_get_name(buf) == "Untitled" then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end,
})
