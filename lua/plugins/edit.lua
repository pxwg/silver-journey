function is_cmp_open(type)
  if require(type) then
    return true
  else
    return false
  end
end
function contains_unacceptable_character(content)
  if content == nil then
    return true
  end
  local ignored_head_number = false
  for i = 1, #content do
    local b = string.byte(content, i)
    if b >= 48 and b <= 57 or b == 32 or b == 46 then
      -- number dot and space
      if ignored_head_number then
        return true
      end
    elseif b <= 127 then
      return true
    else
      ignored_head_number = true
    end
  end
  return false
end

function is_rime_item(item)
  if item == nil or item.source_name ~= "LSP" then
    return false
  end
  local client = vim.lsp.get_client_by_id(item.client_id)
  return client ~= nil and client.name == "rime_ls"
end
--- @param item blink.cmp.CompletionItem
function rime_item_acceptable(item)
  -- return true
  return not contains_unacceptable_character(item.label) or item.label:match("%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d%")
end

function get_n_rime_item_index(n, items)
  if items == nil then
    items = require("blink.cmp.completion.list").items
  end
  local result = {}
  if items == nil or #items == 0 then
    return result
  end
  for i, item in ipairs(items) do
    if is_rime_item(item) and rime_item_acceptable(item) then
      result[#result + 1] = i
      if #result == n then
        break
      end
    end
  end
  return result
end

function is_texlab_item(item)
  if item == nil or item.source_name ~= "LSP" then
    return false
  end
  local client = vim.lsp.get_client_by_id(item.client_id)
  return client ~= nil and client.name == "texlab"
end

return {
  {
    "saghen/blink.compat",
    -- use the latest release, via version = '*', if you also use the latest release for blink.cmp
    event = "InsertEnter",
    version = "*",
    -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
    -- lazy = true,
    -- make sure to set opts so that lazy.nvim calls blink.compat's setup
    opts = {},
  },
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    enabled = true,
    -- use a release tag to download pre-built binaries
    version = "*",
    -- enabled = true,
    build = "cargo build --release",
    dependencies = {
      -- add source
      {
        "zbirenbaum/copilot-cmp",
        "dmitmel/cmp-digraphs",
        "L3MON4D3/LuaSnip",
        "mikavilpas/blink-ripgrep.nvim",
        "giuxtaposition/blink-cmp-copilot",
        {
          "saghen/blink.compat",
          opts = { impersonate_nvim_cmp = true, enable_events = true },
        },
        -- "zbirenbaum/copilot-cmp",
      },
    },
    -- build = 'cargo build --release',
    config = function()
      -- if last char is number, and the only completion item is provided by rime-ls, accept it
      require("blink.cmp.completion.list").show_emitter:on(function(event)
        if #event.items ~= 1 then
          return
        end
        local col = vim.fn.col(".") - 1
        if event.context.line:sub(1, col):match("^.*%a+%d+$") == nil then
          return
        end
        local client = vim.lsp.get_client_by_id(event.items[1].client_id)
        if (not client) or client.name ~= "rime_ls" then
          return
        end
        require("blink.cmp").accept({ index = 1 })
      end)

      -- link BlinkCmpKind to CmpItemKind since nvchad/base46 does not support it
      local set_hl = function(hl_group, opts)
        opts.default = true -- Prevents overriding existing definitions
        vim.api.nvim_set_hl(0, hl_group, opts)
      end
      for _, kind in ipairs(require("blink.cmp.types").CompletionItemKind) do
        set_hl("BlinkCmpKind" .. kind, { link = "CmpItemKind" .. kind or "BlinkCmpKind" })
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuOpen",
        callback = function()
          require("copilot.suggestion").dismiss()
          vim.b.copilot_suggestion_hidden = true
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuClose",
        callback = function()
          vim.b.copilot_suggestion_hidden = false
        end,
      })

      require("copilot_cmp").setup()
      require("blink.cmp").setup({
        keymap = {
          preset = "none",
          ["<cr>"] = { "accept", "fallback" },
          -- ["<tab>"] = { "snippet_forward", "fallback" },
          ["<C-y>"] = { "select_and_accept" },
          ["<s-tab>"] = { "snippet_backward", "fallback" },
          ["<c-j>"] = { "scroll_documentation_up", "fallback" },
          ["<c-k>"] = { "scroll_documentation_down", "fallback" },
          ["<c-n>"] = { "select_next", "fallback" },
          ["<down>"] = { "select_next", "fallback" },
          ["<up>"] = { "select_prev", "fallback" },
          ["<c-p>"] = { "select_prev", "fallback" },
          ["<c-x>"] = { "show", "fallback" },
          ["<c-c>"] = { "cancel", "fallback" },
          ["<space>"] = {
            function(cmp)
              if not vim.g.rime_enabled then
                return false
              end
              local rime_item_index = get_n_rime_item_index(1)
              if #rime_item_index ~= 1 then
                return false
              end
              return cmp.accept({ index = rime_item_index[1] })
            end,
            "fallback",
          },
          ["1"] = {
            function(cmp)
              if not vim.g.rime_enabled then
                return false
              end
              local rime_item_index = get_n_rime_item_index(1)
              if #rime_item_index ~= 1 then
                return false
              end
              return cmp.accept({ index = rime_item_index[1] })
            end,
            "fallback",
          },
          [";"] = {
            -- FIX: can not work when binding ;<space> to other key
            function(cmp)
              if not vim.g.rime_enabled then
                return false
              end
              local rime_item_index = get_n_rime_item_index(2)
              if #rime_item_index ~= 2 then
                return false
              end
              return cmp.accept({ index = rime_item_index[2] })
            end,
            "fallback",
          },
          ["'"] = {
            function(cmp)
              if not vim.g.rime_enabled then
                return false
              end
              local rime_item_index = get_n_rime_item_index(3)
              if #rime_item_index ~= 3 then
                return false
              end
              return cmp.accept({ index = rime_item_index[3] })
            end,
            "fallback",
          },
        },
        completion = {
          ghost_text = { enabled = true },
          documentation = {
            auto_show = true,
            window = {
              min_width = 10,
              max_width = 80,
              max_height = 20,
              border = { "󱕦", "─", "󰄛", "│", "", "─", "󰩃", "│" },
              winblend = 0,
              -- winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
              -- Note that the gutter will be disabled when border ~= 'none'
              scrollbar = true,
              -- Which directions to show the documentation window,
              -- for each of the possible menu window directions,
              -- falling back to the next direction when there's not enough space
              direction_priority = {
                menu_north = { "e", "w", "n", "s" },
                menu_south = { "e", "w", "s", "n" },
              },
            },
          },
          menu = {
            auto_show = function(ctx)
              return ctx.mode ~= "cmdline"
            end,
            -- auto_show = true,
            draw = {
              columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
            },
            border = { "󱕦", "─", "󰄛", "│", "", "─", "󰩃", "│" },
            winhighlight = "FloatBorder:CmpBorder",
            -- winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:PmenuSel,FloatBorder:CmpBorder",
          },
        },
        snippets = { preset = "luasnip" },
        -- fuzzy = { use_typo_resistance = true, use_proximity = false, use_frecency = false, use_unsafe_no_lock = false },
        sources = {
          default = { "lsp", "path", "buffer", "lazydev", "copilot" },
          -- default = { "lsp", "path", "buffer", "copilot" },
          cmdline = {},
          providers = {
            lsp = {
              min_keyword_length = 0,
              fallbacks = { "ripgrep", "buffer" },
              --- @param items blink.cmp.CompletionItem[]
              transform_items = function(_, items)
                -- demote snippets
                for _, item in ipairs(items) do
                  -- if item.kind == require("blink.cmp.types").CompletionItemKind.Snippet then
                  --   item.score_offset = item.score_offset - 3
                  -- end
                  if item.kind == require("blink.cmp.types").CompletionItemKind.Text then
                    item.score_offset = item.score_offset + 2
                  end
                end
                return items
              end,
            },
            buffer = { max_items = 5 },
            lazydev = {
              name = "LazyDev",
              module = "lazydev.integrations.blink",
              score_offset = 0,
            },
            copilot = {
              name = "copilot",
              -- module = "blink-cmp-copilot",
              module = "blink.compat.source",
              score_offset = 100,
              async = true,
              transform_items = function(_, items)
                local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
                local kind_idx = #CompletionItemKind + 1
                CompletionItemKind[kind_idx] = "Copilot"
                for _, item in ipairs(items) do
                  item.kind = kind_idx
                end

                -- filter non-acceptable (non-ascii) items
                -- for _, item in ipairs(items) do
                --   item.kind = kind_idx
                --   if item.label then
                --     item.label = truncate_non_utf8(item.label)
                --   end
                --   if item.insertText then
                --     item.insertText = truncate_non_utf8(item.insertText)
                --   end
                --   if item.textEdit and item.textEdit.newText then
                --     item.textEdit.newText = truncate_non_utf8(item.textEdit.newText)
                --   end
                -- end
                return items
              end,
            },
            ripgrep = {
              module = "blink-ripgrep",
              name = "RG",
              max_items = 5,
              ---@module 'blink-ripgrep'
              ---@type blink-ripgrep.Options
              opts = {
                prefix_min_len = 4,
                context_size = 5,
                max_filesize = "1M",
                project_root_marker = vim.g.root_markers,
                search_casing = "--smart-case",
                -- (advanced) Any additional options you want to give to ripgrep.
                -- See `rg -h` for a list of all available options. Might be
                -- helpful in adjusting performance in specific situations.
                -- If you have an idea for a default, please open an issue!
                --
                -- Not everything will work (obviously).
                additional_rg_options = {},
                -- When a result is found for a file whose filetype does not have a
                -- treesitter parser installed, fall back to regex based highlighting
                -- that is bundled in Neovim.
                fallback_to_regex_highlighting = true,
              },
            },
          },
        },
        appearance = {
          -- Blink does not expose its default kind icons so you must copy them all (or set your custom ones) and add Copilot
          kind_icons = {
            Copilot = "",
            Text = "󰉿",
            Method = "󰊕",
            Function = "󰊕",
            Constructor = "󰒓",

            Field = "󰜢",
            Variable = "󰆦",
            Property = "󰖷",

            Class = "󱡠",
            Interface = "󱡠",
            Struct = "󱡠",
            Module = "󰅩",

            Unit = "󰪚",
            Value = "󰦨",
            Enum = "󰦨",
            EnumMember = "󰦨",

            Keyword = "󰻾",
            Constant = "󰏿",

            Snippet = "󱄽",
            Color = "󰏘",
            File = "󰈔",
            Reference = "󰬲",
            Folder = "󰉋",
            Event = "󱐋",
            Operator = "󰪚",
            TypeParameter = "󰬛",
          },
        },
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    enabled = false,
    opts = function()
      -- Existing nvim-cmp configuration
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local compare = require("cmp.config.compare")
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      local auto_select = true

      --     -- Integrate rime_ls configuration
      --     local lspconfig = require("lspconfig")
      --     local configs = require("lspconfig.configs")
      --     local rime_ls_filetypes = { "markdown", "text", "org", "latex" } -- Define your filetypes here
      --
      --     if not configs.rime_ls then
      --       configs.rime_ls = {
      --         default_config = {
      --           name = "rime_ls",
      --           cmd = { vim.fn.expand("~/Desktop/rime-ls-0.4.0/target/release/rime_ls") },
      --           filetypes = rime_ls_filetypes,
      --           single_file_support = true,
      --         },
      --         settings = {},
      --         docs = {
      --           description = [[
      -- https://www.github.com/wlh320/rime-ls
      --
      -- A language server for librime
      -- ]],
      --         },
      --       }
      --     end
      --
      cmp.setup.filetype("copilot-chat", {
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
          { name = "luasnip" },
          { name = "nvim_lua" },
          { name = "copilot" },
          { name = "rime_ls" },
        }),
      })

      return {
        auto_brackets = {}, -- configure any filetype to auto add brackets
        completion = {
          completeopt = "menu,menuone,noinsert" .. (auto_select and "" or ",noselect"),
        },
        preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
        mapping = cmp.mapping.preset.insert({
          ["<C-a>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-k>"] = cmp.mapping({
            i = function()
              if cmp.visible() then
                cmp.abort()
              else
                cmp.complete()
              end
            end,
            c = function()
              if cmp.visible() then
                cmp.close()
              else
                cmp.complete()
              end
            end,
          }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = LazyVim.cmp.confirm({ select = auto_select }),
          ["<C-y>"] = LazyVim.cmp.confirm({ select = true }),
          ["<S-CR>"] = LazyVim.cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace }),
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
          ["<Space>"] = cmp.mapping(function(fallback)
            local entry = cmp.get_selected_entry()
            if entry == nil then
              entry = cmp.core.view:get_first_entry()
            end
            if entry and entry.source.name == "nvim_lsp" and entry.source.source.client.name == "rime_ls" then
              cmp.confirm({
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
              })
            else
              fallback()
            end
          end, { "i" }),
        }),
        window = {
          completion = {
            border = { "󱕦", "─", "󰄛", "│", "", "─", "󰩃", "│" },
          },
          documentation = {
            border = { "󱕦", "", "󰄛", "│", "", "─", "󰩃", "│" },
          },
        },
        sources = cmp.config.sources({
          { name = "rime_ls_2", priority = 100 },
          { name = "copilot" },
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "buffer" },
          { name = "luasnip" },
        }),
        formatting = {
          format = function(entry, item)
            local icons = LazyVim.config.icons.kinds
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end

            local widths = {
              abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
              menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
            }

            for key, width in pairs(widths) do
              if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
                item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
              end
            end

            return item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
        sorting = {
          comparators = {
            compare.sort_text,
            compare.offset,
            compare.exact,
            compare.score,
            compare.recently_used,
            compare.kind,
            compare.length,
            compare.order,
          },
        },
      }
    end,

    main = "lazyvim.util.cmp",
  },
  config = function()
    if require("cmp") then
      local function is_rime_entry(entry)
        return vim.tbl_get(entry, "source", "name") == "nvim_lsp"
          and vim.tbl_get(entry, "source", "source", "client", "name") == "rime_ls"
      end
      local cmp = require("cmp")
      local function auto_upload_rime()
        if not cmp.visible() then
          return
        end
        local entries = cmp.core.view:get_entries()
        if entries == nil or #entries == 0 then
          return
        end
        local first_entry = cmp.get_selected_entry()
        if first_entry == nil then
          first_entry = cmp.core.view:get_first_entry()
        end
        if first_entry ~= nil and is_rime_entry(first_entry) then
          local rime_ls_entries_cnt = 0
          for _, entry in ipairs(entries) do
            if is_rime_entry(entry) then
              rime_ls_entries_cnt = rime_ls_entries_cnt + 1
              if rime_ls_entries_cnt == 2 then
                break
              end
            end
          end
          if rime_ls_entries_cnt == 1 then
            cmp.confirm({
              behavior = cmp.ConfirmBehavior.Insert,
              select = true,
            })
          end
        end
      end
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function()
          for numkey = 1, 9 do
            local numkey_str = tostring(numkey)
            vim.api.nvim_buf_set_keymap(0, "i", numkey_str, "", {
              noremap = true,
              silent = false,
              callback = function()
                vim.fn.feedkeys(numkey_str, "n")
                vim.schedule(auto_upload_rime)
              end,
            })
            vim.api.nvim_buf_set_keymap(0, "s", numkey_str, "", {
              noremap = true,
              silent = false,
              callback = function()
                vim.fn.feedkeys(numkey_str, "n")
                vim.schedule(auto_upload_rime)
              end,
            })
          end
        end,
      })
    end
  end,
}
