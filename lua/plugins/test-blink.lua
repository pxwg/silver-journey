return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      -- default = { "lsp", "path", "luasnip", "buffer", "ripgrep", "lazydev" },
      default = { "lsp", "path", "buffer" },
      cmdline = {},
      providers = {
        lsp = {
          min_keyword_length = 2,
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
      },
    },
  },
}
