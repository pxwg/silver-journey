local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local d = ls.dynamic_node
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local line_begin = require("luasnip.extras.expand_conditions").line_begin
local tex = require("util.latex")
local get_visual = function(args, parent)
  if #parent.snippet.env.SELECT_RAW > 0 then
    return sn(nil, t(parent.snippet.env.SELECT_RAW))
  else -- If SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end

return {
  s(
    { trig = "mcal", wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("mcal <> mcal", {
      i(0),
    }),
    { condition = tex.in_latex }
  ),

  s(
    { trig = "mcal", wordTrig = false, snippetType = "autosnippet", priority = 3000 },
    fmta("mcal <> mcal", {
      d(1, get_visual),
    }),
    { condition = tex.in_latex }
  ),

  s(
    { trig = "mcal", wordTrig = false, snippetType = "autosnippet", priority = 4000 },
    c(1, {
      sn(
        nil,
        fmta("mcal <> mcal", {
          d(1, get_visual),
        })
      ),
      sn(
        nil,
        fmta("pcal <> pcal", {
          d(1, get_visual),
        })
      ),
    }),
    { condition = tex.in_latex }
  ),
  s( -- This one evaluates anything inside the simpy block
    { trig = "mcal.*mcals", regTrig = true, desc = "Sympy block evaluator", snippetType = "autosnippet" },
    d(1, function(_, parent)
      -- Gets the part of the block we actually want, and replaces spaces
      -- at the beginning and at the end
      local to_eval = string.gsub(parent.trigger, "^mcal(.*)mcals", "%1")
      to_eval = string.gsub(to_eval, "^%s+(.*)%s+$", "%1")

      -- Replace single backslashes with double backslashes
      to_eval = string.gsub(to_eval, "\\mathrm{d}", "d")
      to_eval = string.gsub(to_eval, "\\mathrm{i}", "i")
      to_eval = string.gsub(to_eval, "\\", "\\\\")

      local job = require("plenary.job")

      local sympy_script = string.format(
        [[
        a = FullSimplify[ToExpression["%s",TeXForm] ];
        b = TeXForm[a];
        Return["%s =" b]
        ]],
        -- origin = re.sub(r'^\s+|\s+$', '', origin)
        -- parsed = parse_expr(origin)
        -- output = origin + parsed
        -- print_latex(parsed)
        to_eval,
        to_eval
      )

      sympy_script = string.gsub(sympy_script, "^[\t%s]+", "")
      local result = {}

      job
        :new({
          command = "wolframscript",
          args = {
            "-c",
            sympy_script,
          },
          on_exit = function(j)
            result = j:result()
          end,
          -- timeout = 210000000,
        })
        :sync()

      return sn(nil, t(result))
    end)
  ),
}
