" Program: CMake Cache File
" Language: CMake Cache
" Author: Isabella Muerte
" License: MIT License

if exists('b:current_syntax') | finish | endif

syntax iskeyword @,45-57,@-@,+,_

syntax keyword cmakeCacheBoolean IGNORE FALSE OFF NO N
syntax keyword cmakeCacheBoolean TRUE YES ON Y
syntax match cmakeCacheBoolean /\v\zs%(\k*-)?NOTFOUND\ze/ display

syntax match cmakeCacheNumber /\v<\x+/ display
syntax match cmakeCacheFloat /\v<\d+%(\.\d+){1,3}/ display

syntax keyword cmakeCacheType BOOL STRING INTERNAL FILEPATH PATH STATIC

syntax region cmakeCacheVariable start=/\v^%([^:])/ end=/:/he=e-1 display
syntax region cmakeCacheVariable start=/\v^"[^"]+/ end=/"/ display
syntax region cmakeCacheAdvanced start=/\v^%(\k+)-ADVANCED/ end=/:/he=e-1 display

syntax region cmakeCacheComment start='^#' end='$' oneline
syntax region cmakeCacheComment start='^//' end='$' oneline

syntax region cmakeCacheTerminal start=/\v\d/ skip=/\v[^m]+/ end=/m$/ display contained
syntax match cmakeCacheEscape /\v\e\[/ display conceal cchar=␛ nextgroup=cmakeCacheTerminal
syntax match cmakeCacheEscape "\%x1e" display conceal cchar=␞ "C0 RS
syntax match cmakeCacheEscape "\%x1f" display conceal cchar=␟ "C0 US
syntax match cmakeCacheEscape /\%xc2\%x85/ display conceal cchar=␊ "C1 NEL
syntax match cmakeCacheEscape /\%xc2\%x86/ display conceal cchar=␍ "C1 IDX
syntax match cmakeCacheEscape /\%xc0/ display conceal cchar=�

highlight default link cmakeCacheTerminal Constant

highlight default link cmakeCacheVariable Identifier
highlight default link cmakeCacheAdvanced Special

highlight default link cmakeCacheBoolean Boolean
highlight default link cmakeCacheNumber Number
highlight default link cmakeCacheFloat Float

highlight default link cmakeCacheComment Comment
highlight default link cmakeCacheString String
highlight default link cmakeCacheType Type

let b:current_syntax = "cmake_cache"
