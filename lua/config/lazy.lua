local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "snacks_dashboard",
  callback = function()
    vim.opt_local.spell = false
  end,
})
vim.opt.rtp:prepend(lazypath)
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)
local rime_ls_active = true
local rime_toggled = true --默认打开require("lsp.rime_2")_ls

vim.opt.spell = false
vim.env.LANG = "zh_CN.UTF-8"
vim.o.timeoutlen = 50
vim.o.ttimeout = true
vim.opt.list = false
vim.o.ttimeoutlen = 10

_G.rime_toggled = rime_toggled
_G.rime_ls_active = rime_ls_active
_G.notify_state = true
_G.is_center_open = true

local file_path = "/tmp/nvim_hammerspoon_latex.txt"
local file = io.open(file_path, "r")
if not file then
  file = io.open(file_path, "w")
  if not file then
    print("failed to create " .. file_path)
    return
  end
  file:close()
  print(file_path .. " created")
end

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

vim.g.python3_host_prog = "/opt/homebrew/Caskroom/miniconda/base/bin/python3"

vim.cmd([[
        highlight! BorderBG guibg=NONE guifg=#b4befe
        highlight! normalfloat guibg=none guifg=none
        highlight! BufferLineFill guibg=none
        " highlight! Normal guibg=NONE
        " highlight! NormalNC guibg=NONE
        highlight! WinSeparator guibg=None guifg=#bac2de
        highlight! StatusLine guibg=NONE guifg=#c0caf5
        highlight! StatusLineNC guibg=NONE guifg=#c0caf5
        highlight! TabLine guibg=NONE guifg=#c0caf5
        highlight! TabLineFill guibg=NONE guifg=#c0caf5
        highlight! TabLineSel guibg=NONE guifg=#c0caf5
        highlight! NeoTreeNormal guibg=NONE guifg=#c0caf5
        highlight! NeoTreeNormalNC guibg=NONE guifg=#c0caf5
]])
vim.o.pumblend = 0

-- if vim.g.colors_name == "nightfox" then
-- vim.cmd([[
--     highlight Normal guibg=#191C28
--     highlight! NormalNC guibg=#191C28
--   ]])
-- end

require("util.listen_code_change")
