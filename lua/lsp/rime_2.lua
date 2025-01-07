local M = {}
local rime_ls_filetypes = { " vimwiki", "tex", "markdown", "copilot-chat" }
-- local rime_ls_filetypes = { "*" }
-- local cmp = require("cmp")

function M.setup_rime()
  -- global status
  vim.g.rime_enabled = true
  M.start_rime_ls()

  -- add rime-ls to lspconfig as a custom server
  -- see `:h lspconfig-new`
  local lspconfig = require("lspconfig")
  local configs = require("lspconfig.configs")
  if not configs.rime_ls then
    configs.rime_ls = {
      default_config = {
        name = "rime_ls",
        -- cmd = { vim.fn.expand("/usr/local/bin/rime_ls") }, -- your path to rime-ls
        cmd = vim.lsp.rpc.connect("127.0.0.1", 9257),
        filetypes = rime_ls_filetypes,
        single_file_support = true,
        autostart = true, -- Add this line to prevent automatic start, in order to boost
      },
      settings = {},
      docs = {
        description = [[
https://www.github.com/wlh320/rime-ls

A language server for librime
]],
      },
    }
  end
  -- if last char is number, and the only completion item is provided by rime-ls, accept it
  -- require("blink.cmp.completion.list").show_emitter:on(function(event)
  --   if not vim.g.rime_enabled then
  --     return
  --   end
  --   local col = vim.fn.col(".") - 1
  --   -- if you don't want use number to select, change the match pattern by yourself
  --   if event.context.line:sub(col, col):match("%d") == nil then
  --     return
  --   end
  --   local rime_item_index = get_n_rime_item_index(2, event.items)
  --   if #rime_item_index ~= 1 then
  --     return
  --   end
  --   require("blink.cmp").accept({ index = rime_item_index[1] })
  -- end)

  local rime_on_attach = function(client, _)
    local toggle_rime = function()
      client.request("workspace/executeCommand", { command = "rime-ls.toggle-rime" }, function(_, result, ctx, _)
        if ctx.client_id == client.id then
          vim.g.rime_enabled = result
        end
      end)
    end
    -- keymaps for executing command
    vim.keymap.set("n", "<leader>rr", toggle_rime, { desc = "Toggle [R]ime" })
    -- vim.keymap.set("i", "jn", toggle_rime, { desc = "Toggle Rime" })
    vim.keymap.set("n", "<leader>rs", function()
      vim.lsp.buf.execute_command({ command = "rime-ls.sync-user-data" })
    end, { desc = "[R]ime [S]ync" })
    vim.keymap.set("i", "jn", function()
      require("lsp.rime_2").toggle_rime()
      _G.rime_toggled = not _G.rime_toggled
      _G.rime_ls_active = not _G.rime_ls_active
    end, { noremap = true, silent = true, desc = "toggle rime-ls" })
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
  -- capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
  capabilities.general.positionEncodings = { "utf-8", "utf-16" }

  lspconfig.rime_ls.setup({
    init_options = {
      enabled = vim.g.rime_enabled,
      shared_data_dir = "/Library/Input Methods/Squirrel.app/Contents/SharedSupport",
      user_data_dir = "~/Library/Rime_2/",
      log_dir = vim.fn.expand("~/.local/share/rime-ls-1/"),
      -- paging_characters = { "-", "=", ",", ".", "?", "!" },
      paging_characters = { ",", "." },
      trigger_characters = {},
      schema_trigger_character = "&",
      always_incomplete = false,
      preselect_first = false,
      show_filter_text_in_label = false,
      max_candidates = 9,
      max_tokens = 0,
      long_filter_text = true,
    },
    -- on_attach = attach_in_insert_mode,
    on_attach = rime_on_attach,
    capabilities = capabilities,
  })

  -- config for nvim-cmp
  -- if require("cmp") then
  --   local function is_rime_entry(entry)
  --     return vim.tbl_get(entry, "source", "name") == "nvim_lsp"
  --       and vim.tbl_get(entry, "source", "source", "client", "name") == "rime_ls"
  --   end
  --   local cmp = require("cmp")
  --   local function auto_upload_rime()
  --     if not cmp.visible() then
  --       return
  --     end
  --     local entries = cmp.core.view:get_entries()
  --     if entries == nil or #entries == 0 then
  --       return
  --     end
  --     local first_entry = cmp.get_selected_entry()
  --     if first_entry == nil then
  --       first_entry = cmp.core.view:get_first_entry()
  --     end
  --     if first_entry ~= nil and is_rime_entry(first_entry) then
  --       local rime_ls_entries_cnt = 0
  --       for _, entry in ipairs(entries) do
  --         if is_rime_entry(entry) then
  --           rime_ls_entries_cnt = rime_ls_entries_cnt + 1
  --           if rime_ls_entries_cnt == 2 then
  --             break
  --           end
  --         end
  --       end
  --       if rime_ls_entries_cnt == 1 then
  --         cmp.confirm({
  --           behavior = cmp.ConfirmBehavior.Insert,
  --           select = true,
  --         })
  --       end
  --     end
  --   end
  --   vim.api.nvim_create_autocmd("FileType", {
  --     pattern = rime_ls_filetypes,
  --     callback = function()
  --       for numkey = 1, 9 do
  --         local numkey_str = tostring(numkey)
  --         vim.api.nvim_buf_set_keymap(0, "i", numkey_str, "", {
  --           noremap = true,
  --           silent = false,
  --           callback = function()
  --             vim.fn.feedkeys(numkey_str, "n")
  --             vim.schedule(auto_upload_rime)
  --           end,
  --         })
  --         vim.api.nvim_buf_set_keymap(0, "s", numkey_str, "", {
  --           noremap = true,
  --           silent = false,
  --           callback = function()
  --             vim.fn.feedkeys(numkey_str, "n")
  --             vim.schedule(auto_upload_rime)
  --           end,
  --         })
  --       end
  --     end,
  --   })
  -- end
end

function M.toggle_rime()
  local client = vim.lsp.get_clients({ name = "rime_ls" })[1]
  if client then
    client.request("workspace/executeCommand", { command = "rime-ls.toggle-rime" }, function(_, result, ctx, _)
      if ctx.client_id == client.id then
        vim.g.rime_enabled = result
      end
    end)
  end
end

function M.start_rime_ls()
  local job_id = vim.fn.jobstart("rime_ls --listen", {
    on_stdout = function() end,
    on_stderr = function() end,
    on_exit = function(_, code)
      if code ~= 0 then
        vim.api.nvim_err_writeln("rime_ls exited with code " .. code)
      end
    end,
  })

  -- Create an autocommand to stop the job when Neovim exits
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      vim.fn.jobstop(job_id)
    end,
  })
end

return M
