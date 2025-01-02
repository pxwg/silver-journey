local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local f = ls.function_node
local i = ls.insert_node
local d = ls.dynamic_node
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local line_begin = require("luasnip.extras.expand_conditions").line_begin
local tex = require("util.latex")

-- local get_visual = function(args, parent)
--   if #parent.snippet.env.SELECT_RAW > 0 then
--     return sn(nil, i(1, parent.snippet.env.SELECT_RAW))
--   else -- If SELECT_RAW is empty, return a blank insert node
--     return sn(nil, i(1))
--   end
-- end
return {
  s(
    { trig = "nsnip", snippetType = "autosnippet", hidden = false, name = "test", dscr = "test2" },
    fmta(
      [[s( { trig = "<>", snippetType = "autosnippet" }, fmta([[<><>,{<>}), { condition = tex.in_mathzone }),<>]],
      { i(1), i(2), t("]]"), i(3), i(0) }
    )
  ),
  s(
    { trig = "msnip", snippetType = "autosnippet", hidden = false, name = "test", dscr = "test2", priority = 10 },
    fmta(
      [[s( { trig = "<>", snippetType = "autosnippet" }, fmta([[<><>,{<>}), { condition = tex.in_latex }),<>]],
      { i(1), i(2), t("]]"), i(3), i(0) }
    )
  ),
}
