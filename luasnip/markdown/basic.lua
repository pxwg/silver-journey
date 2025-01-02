local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local f = ls.function_node
local c = ls.choice_node
local i = ls.insert_node
local d = ls.dynamic_node
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local line_begin = require("luasnip.extras.expand_conditions").line_begin
local tex = require("util.latex")

local get_visual = function(args, parent)
  if #parent.snippet.env.SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.SELECT_RAW))
  else -- If SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end

return {
  -- 马原论文引用快捷键
  s(
    { trig = "inp", wordTrig = true, snippetType = "autosnippet", trigEngine = "ecma" },
    fmta([[*“<>”* <>]], { i(1), i(0) })
  ),

  s(
    { trig = "mk", wordTrig = true, snippetType = "autosnippet", trigEngine = "ecma" },
    fmta([[$<>$ <>]], { i(1), i(0) })
  ),
  s(
    { trig = "eqt", snippetType = "autosnippet" },
    fmta(
      [[
        <>$$
          <>
        $$<>]],
      {
        i(0),
        i(1),
        i(2),
      }
    ),
    { condition = line_begin }
  ),
  s(
    { trig = "eqs", snippetType = "autosnippet" },
    fmta(
      [[
        <>$$
          <>
        $$<>]],
      {
        i(0),
        i(1),
        i(2),
      }
    ),
    { condition = line_begin }
  ),
  s(
    { trig = "km", wordTrig = true, snippetType = "autosnippet", trigEngine = "ecma" },
    fmta([[$<>$ <>]], { i(1), i(0) })
  ),
  s(
    { trig = "td", wordTrig = false, snippetType = "autosnippet" },
    { t("_{"), i(1), t("}"), i(0) },
    { condition = tex.in_latex }
  ),
  s(
    { trig = "tp", wordTrig = false, snippetType = "autosnippet" },
    { t("^{"), i(1, "2"), t("}"), i(0) },
    { condition = tex.in_latex }
  ),

  --自动下标
  s(
    { trig = "([%a%)%]%}])(%d)", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
    fmta("<>_<>", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
    }),
    { condition = tex.in_latex }
  ),
  s(
    { trig = "([%a%)%]%}])_(%d)(%d)", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
    fmta("<>_{<><>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
      f(function(_, snip)
        return snip.captures[3]
      end),
    }),
    { condition = tex.in_latex }
  ),
  s(
    { trig = "(%a)(%a)%2", regTrig = true, wordTrig = true, snippetType = "autosnippet", priority = 100 },
    fmta("<>_<>", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
    }),
    { condition = tex.in_latex }
  ),
  s(
    { trig = "([%a%)%]%}])_(%a)(%a)%3", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("<>_{<><>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
      f(function(_, snip)
        return snip.captures[3]
      end),
    }),
    { condition = tex.in_latex }
  ),

  s(
    { trig = "//", wordTrig = true, snippetType = "autosnippet", priority = 100 },
    fmta("\\frac{<>}{<>}<>", {
      i(1),
      i(2),
      i(0),
    }),
    { condition = tex.in_latex }
  ),

  s(
    { trig = "(%d+)/", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 100 },
    fmta("\\frac{<>}{<>}<>", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      i(1),
      i(0),
    }),
    { condition = tex.in_latex }
  ),
  s(
    { trig = "(%a)/", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 100 },
    fmta("\\frac{<>}{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      i(1),
    }),
    { condition = tex.in_latex }
  ),
  s( -- 带括号的分数
    { trig = "%((.+)%)/", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
    fmta("\\frac{<>}{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      i(1),
    }),
    { condition = tex.in_latex }
  ),
  s(
    { trig = "(\\%a+)/", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\frac{<>}{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      i(1),
    }),
    { condition = tex.in_latex }
  ),
  s(
    { trig = "(\\%a+%{%a+%})/", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 3000 },
    fmta("\\frac{<>}{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      i(1),
    }),
    { condition = tex.in_latex }
  ),
  s(
    { trig = "\\%)(%a)", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\) <>", {
      f(function(_, snip)
        return snip.captures[1]
      end),
    })
  ),

  s(
    { trig = "lim", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
    c(1, {
      sn(nil, { t("\\lim "), i(1) }),
      sn(nil, { t("\\lim_{"), i(1, "x"), t(" \\to "), i(2, "\\infty"), t("} "), i(0) }),
    }),
    { condition = tex.in_latex }
  ),
  s(
    { trig = "sum", snippetType = "autosnippet" },
    c(1, {
      sn(nil, { t("\\sum_{"), i(1), t("}^{"), i(2), t("} ") }),
      sn(nil, { t("\\sum_{"), i(1), t("} ") }),
      sn(nil, { t("\\sum "), i(1) }),
    }),
    { condition = tex.in_latex }
  ),
  s(
    { trig = "prod", snippetType = "autosnippet" },
    c(1, {
      sn(nil, { t("\\prod_{"), i(1), t("}^{"), i(2), t("} ") }),
      sn(nil, { t("\\prod_{"), i(1), t("} ") }),
      sn(nil, { t("\\prod "), i(1) }),
    }),
    { condition = tex.in_latex }
  ),

  s(
    { trig = "bnn", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\bigcap\\limits_{<>}^{<>}", {
      i(1),
      i(0),
    }),
    { condition = tex.in_latex }
  ),
  s(
    { trig = "buu", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\bigcup\\limits_{<>}^{<>}", {
      i(1),
      i(0),
    }),
    { condition = tex.in_latex }
  ),
  s(
    { trig = "dint", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 1500 },
    c(1, {
      sn(
        nil,
        fmta("<>\\int_{<>}^{<>} <> \\, \\mathrm{d}<> <>", {
          i(0),
          i(1, "-\\infty"),
          i(2, "+\\infty"),
          i(3),
          i(4, "x"),
          i(5),
        })
      ),
      sn(
        nil,
        fmta("<>\\int  \\, \\mathrm{d} <> <>", {
          i(0),
          i(1, "x"),
          i(2),
        })
      ),
    }),
    { condition = tex.in_latex }
  ),
  s(
    { trig = "bdint", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    c(1, {
      sn(
        nil,
        fmta("<>\\int_{<>}^{<>} \\, \\mathrm{d} <> <>", {
          i(0),
          i(1, "-\\infty"),
          i(2, "+\\infty"),
          i(3, "x"),
          i(4),
        })
      ),
      sn(
        nil,
        fmta("<>\\int <> \\, \\mathrm{d}<> <>", {
          i(0),
          i(1),
          i(2, "x"),
          i(3),
        })
      ),
    }),
    { condition = tex.in_latex }
  ),
}
