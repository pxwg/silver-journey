local synctex = require("util.tdf")
return {
  "lervag/vimtex",
  -- lazy = true,
  -- priority = 100,
  -- event = "VimEnter",
  config = function()
    vim.cmd([[
let g:tex_flavor='latex'
let g:vimtex_view_method = 'skim'
" let g:vimtex_view_enabled = 0
let g:vimtex_quickfix_mode=0
let g:vimtex_fold_enabled=0
let g:tex_conceal='abdmg'
let g:vimtex_syntax_custom_cmds_with_concealed_delims = [
          \ {'name': 'ket',
          \  'mathmode': 1,
          \  'cchar_open': '|',
          \  'cchar_close': '>'},
          \ {'name': 'binom',
          \  'nargs': 2,
          \  'mathmode': 1,
          \  'cchar_open': '(',
          \  'cchar_mid': '|',
          \  'cchar_close': ')'},
          \]
let g:vimtex_syntax_conceal = {
          \ 'accents': 1,
          \ 'ligatures': 1,
          \ 'cites': 1,
          \ 'fancy': 1,
          \ 'spacing': 1,
          \ 'greek': 1,
          \ 'math_bounds': 1,
          \ 'math_delimiters': 1,
          \ 'math_fracs': 1,
          \ 'math_super_sub': 1,
          \ 'math_symbols': 1,
          \ 'sections': 0,
          \ 'styles': 1,
          \}
]])
    vim.cmd([[
let g:vimtex_compiler_latexmk = {
        \ 'aux_dir' : '',
        \ 'out_dir' : '',
        \ 'callback' : 1,
        \ 'continuous' : 1,
        \ 'executable' : 'latexmk',
        \ 'hooks' : [],
        \ 'options' : [
        \   '-verbose',
        \   '-file-line-error',
        \   '-synctex=1',
        \   '-interaction=nonstopmode',
        \ ],
        \}
]])
  end,
  keys = {
    -- keymapping for forward search
    {
      "<localleader>lf",
      function()
        synctex.synctex_forward()
      end,
      mode = "n",
      desc = "vimtex-forward",
    },
    -- keymapping for inverse search
    {
      "<localleader>li",
      function()
        synctex.synctex_edit()
      end,
      mode = "n",
      desc = "vimtex-inverse",
    },
    -- keymapping for show pdf
    {
      "<localleader>lp",
      function()
        synctex.convert_tex_to_pdf()
      end,
      mode = "n",
      desc = "vimtex-view-in-Terminal",
    },
  },
}
