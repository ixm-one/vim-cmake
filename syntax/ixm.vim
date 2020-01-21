" Program: IXM - The Last CMake Library You'll Ever Use
" Language: IXM Binary File
" Author: Isabella Muerte
" License: MIT License

if exists('b:current_syntax') | finish | endif

syntax iskeyword @,_,+,45-58,@-@

" c0ws -> whitespace
" c0rs -> record separator
" c0us -> unit separator

syntax match c0ws /\%x09/ display conceal cchar=␉ "C0 \t
syntax match c0ws /\%x0b/ display conceal cchar=␋ "C0 \v
syntax match c0ws /\%x0c/ display conceal cchar=␌ "C0 \f
syntax match c0ws /\%xc2\%x85/ display conceal cchar=␊ "C1 NEL
syntax match c0ws /\%xc2\%x86/ display conceal cchar=␍ "C1 IDX

syntax match c0rs "\%x1e" display conceal cchar=␞ "C0 RS
syntax match c0us "\%x1f" display conceal cchar=␟ "C0 US
syntax match c0ws /\%x20/ display conceal cchar=· "C0 <space>

syntax keyword Boolean IGNORE FALSE OFF NO N
syntax keyword Boolean TRUE YES ON Y

syntax match Boolean /\v\zs%(\k*-)?NOTFOUND\ze/ display
syntax match Number /\v<\d+>/ display
syntax match Float /\v<\d+\.\d+%(\.\d+){,3}>/ display

syntax match Identifier /\v^\k+\ze%x1e/ display
syntax match Constant /\v<\k+>/ display contains=ALL

if exists('g:ixm_disable_control_concealment') && g:ixm_disable_control_concealment
  syntax match c0rs /\%x1e/ display conceal cchar=:
  syntax match c0us /\%x1f/ display conceal cchar=,
endif

let b:current_syntax = "ixm"
