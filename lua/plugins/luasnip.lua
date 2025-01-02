return {
  {
    "L3MON4D3/LuaSnip",
    event = "BufRead",
    config = function()
      require("luasnip").config.set_config({
        enable_autosnippets = true,
        store_selection_keys = "`",
        delete_check_events = "TextChanged",
      })
      require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/LuaSnip" })
      local auto_expand = require("luasnip").expand_auto
      require("luasnip").expand_auto = function(...)
        vim.o.undolevels = vim.o.undolevels
        auto_expand(...)
      end
    end,
    keys = function()
      return {
        {
          "jk",
          function()
            return require("luasnip").expand_or_locally_jumpable() and "<Plug>luasnip-jump-next"
              or "<c-\\><c-n>:call searchpair('[([{<|]', '', '[)\\]}>|]', 'W')<cr>a"
          end,
          expr = true,
          silent = true,
          mode = "i",
        },
        {
          "jk",
          function()
            return require("luasnip").jump(1)
          end,
          mode = "s",
        },
        {
          "kj",
          function()
            require("luasnip").jump(-1)
          end,
          mode = { "i", "s" },
        },
        {
          "<c-h>",
          "<Plug>luasnip-next-choice",
          mode = { "i", "s" },
        },
        {
          "<c-p>",
          "<Plug>luasnip-prev-choice",
          mode = { "i", "s" },
        },
      }
    end,
  },
}
