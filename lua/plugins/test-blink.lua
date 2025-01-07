return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      -- default = { "lsp", "path", "luasnip", "buffer", "ripgrep", "lazydev" },
      default = { "lsp", "path", "buffer", "copilot" },
      cmdline = {},
      providers = {
        lsp = {
          min_keyword_length = 0,
          fallbacks = { "ripgrep", "buffer" },
          --- @param items blink.cmp.CompletionItem[]
          transform_items = function(_, items)
            -- demote snippets
            for _, item in ipairs(items) do
              if item.kind == require("blink.cmp.types").CompletionItemKind.Snippet then
                item.score_offset = item.score_offset - 3
              end
            end
            return items
          end,
        },
        buffer = { max_items = 5 },
        luasnip = { name = "Snip" },
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

            -- filter non-acceptable rime items (e.g. English item)
            -- return vim.tbl_filter(function(item)
            --   if not is_rime_item(item) then
            --     return true
            --   end
            --   item.detail = nil
            --   return rime_item_acceptable(item)
            -- end, items)
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
  },
}
