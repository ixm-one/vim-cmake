" Vim syntax file
" Program: CMake - Cross Platform Meta Build System
" Language: CMake (with optional IXM enhancements)
" Author: Isabella Muerte
" License: MIT License

if exists('b:current_syntax') | finish | endif

syntax iskeyword @,45-57,@-@,+,_

" This allows generator expressions to act like matching pairs
setlocal matchpairs+=<:> 

" non-data based keywords and matches
syntax keyword cmakeCommand function endfunction macro endmacro
syntax region cmakeFold start=/\v%(<function)@<=\s*\(/ms=e end=/\v%(<endfunction)@<=\s*\(/me=e transparent fold
syntax region cmakeFold start=/\v%(<macro)@<=\s*\(/ms=e end=/\v%(<endmacro)@<=\s*\(/me=e transparent fold

syntax keyword cmakeConditional if elseif while nextgroup=cmakeConditionalArguments
syntax keyword cmakeConditional endwhile endif else

syntax keyword cmakeRepeat foreach nextgroup=cmakeRepeatArguments
syntax keyword cmakeRepeat endforeach

syntax keyword cmakeStatement continue return break

syntax region cmakeConditionalArguments start=/\v%(<if|<elseif|<while)@<=\s*\(/ms=e end=/\v\)/
      \ contains=cmakeConditionalOperator,@cmakeExpression
syntax region cmakeRepeatArguments start=/\v%(<foreach)@<=\s*\(/ms=e end=/\v\)/
      \ contains=cmakeRepeatOperator,@cmakeExpression

" Constants
syntax keyword cmakeBoolean IGNORE FALSE OFF NO N
syntax keyword cmakeBoolean TRUE YES ON Y
syntax match cmakeBoolean /\v\zs%(\k*-)?NOTFOUND\ze/ display

syntax match cmakeTarget /\v<\k+::\k+(::\k+)*>/ display
syntax match cmakeNumber /\v<\d+/ display
syntax match cmakeFloat /\v<\d+%(\.\d+){1,3}/ display

syntax region cmakeString start=/\v\[\z(\={,9})\[/ end=/\v\]\z1\]/ contains=@cmakeDerefExpression
syntax region cmakeString start=/"/ end=/\v%(\\)@<!"/ contains=@cmakeDerefExpression

syntax region cmakeComment start='#' end='$' oneline contains=cmakeTodo
syntax region cmakeComment start=/\v#\[\z(\={,9})\[/ end=/\v\]\z1\]/ contains=cmakeTodo

syntax region cmakeGenerator start="$<" end=">" contains=@cmakeGeneratorExpression

syntax region cmakeDefined start='CACHE{' end='}' contained contains=cmakeReference,cmakeVariable
syntax region cmakeDefined start='ENV{' end='}' contained contains=cmakeReference,cmakeVariable

syntax keyword cmakeTodo contained FIXME NOTE TODO HACK BUG XXX

" Data based keywords and matches (Uses JSON for information)
call cmake#syntax#Properties()
call cmake#syntax#Variables()
call cmake#syntax#Operators()

call cmake#syntax#Reference('CACHE')
call cmake#syntax#Reference('DATA')
call cmake#syntax#Reference('ENV')
call cmake#syntax#Reference('')

let s:filepath = expand('<sfile>:h:h')
let s:filename = sha256(join(g:cmake#syntax#text, "\n")) . '.vim'

let s:fullpath = join([s:filepath, s:filename], '/')
if writefile(g:cmake#syntax#text, s:fullpath) == -1 | call cmake#Warn('Could not cache syntax calls') | endif

syntax keyword cmakeCommand file
syntax keyword cmakeSubcommand GENERATE
syntax keyword cmakeKeyword OUTPUT CONTENT KEYWORD
syntax keyword cmakeFlag NOT_TODAY NO_POLICY_SCOPE

syntax cluster cmakeGeneratorExpression add=cmakeGeneratorOperator
syntax cluster cmakeGeneratorExpression add=cmakeReference
syntax cluster cmakeGeneratorExpression add=cmakeProperty

syntax cluster cmakeDerefExpression add=cmakeGenerator
syntax cluster cmakeDerefExpression add=cmakeReference

syntax cluster cmakeExpression add=cmakeGenerator
syntax cluster cmakeExpression add=cmakeReference
syntax cluster cmakeExpression add=cmakeDefined
syntax cluster cmakeExpression add=cmakeBoolean
syntax cluster cmakeExpression add=cmakeNumber
syntax cluster cmakeExpression add=cmakeString
syntax cluster cmakeExpression add=cmakeFloat
syntax cluster cmakeExpression add=cmakeTarget

highlight default link cmakeCommand Keyword
highlight default link cmakeFunction Function
highlight default link cmakeMacro Macro

" FIXME: The actual groups to be linked still need to be decided upon
highlight default link cmakeSubcommand Special
highlight default link cmakeKeyword Label
highlight default link cmakeFlag Constant

highlight default link cmakeConditional Conditional
highlight default link cmakeStatement Statement
highlight default link cmakeRepeat Repeat

highlight default link cmakeConditionalOperator Operator
highlight default link cmakeGeneratorOperator Operator
highlight default link cmakeRepeatOperator Operator

highlight default link cmakeGenerator Structure
highlight default link cmakeReference Structure
highlight default link cmakeDefined Identifier

highlight default link cmakeBoolean Boolean
highlight default link cmakeNumber Number
highlight default link cmakeString String
highlight default link cmakeFloat Float
highlight default link cmakeTarget Type

highlight default link cmakeComment Comment
highlight default link cmakeTodo TODO

" TODO: This should support more granular capabilities. Things like
" 'these are subcommands and *these* are options for said subcommand'.
" Probably requires more stuff like nextgroup manipulation and such.
function! s:CMakeCommand(name, ...)
  let l:range = 'start=/\\@<=' . a:name . '(/ end=/)/'
  let l:ident = 'cmake' . cmake#Capitalize(a:name)
  let l:subcommands = l:ident . 'Subcommands'
  let l:parameters = l:ident . 'Parameters'
  let l:command = l:ident . 'Command'
  let l:keys = !empty(a:000) ? a:000 : cmake#Data('commands', a:name)->values()->cmake#Flatten()

  let l:subcommandArgs = ['syntax', 'keyword', l:subcommands, 'containedin=' . l:parameters]
  let l:parameterArgs = ['syntax', 'region', l:parameters, l:range]
  let l:commandArgs = ['syntax', 'keyword', l:command, a:name]
  let l:highlightSubcommands = ['highlight', 'default', 'link', l:subcommands, 'Special']
  let l:highlightCommand = ['highlight', 'default', 'link', l:command, 'Keyword']
  for item in l:keys
    eval l:subcommandArgs->extend(item->type() == v:t_list ? item : [item])
  endfor
  let l:contains = [l:subcommands, 'cmakeNumber', 'cmakeProperty', 'cmakeFloat']
  eval l:parameterArgs->extend(['contains=' . join(l:contains, ',')])
  eval l:commandArgs->extend(['nextgroup=' . l:parameters, l:command])

  call cmake#Execute(l:subcommandArgs)
  call cmake#Execute(l:parameterArgs)
  call cmake#Execute(l:commandArgs)
  call cmake#Execute(l:highlightSubcommands)
  call cmake#Execute(l:highlightCommand)
endfunction

function! s:CMakeModule(name)
  const l:keys = cmake#Data('modules', a:name)
  for [key, group] in l:keys->get('highlight', {})->items()
    let entries = l:keys->get(key, [])
    if empty(entries) | continue | endif
    let cmake = s:group(a:name, key)
    call s:keyword(cmake, entries)
    call s:link(cmake, group)
  endfor
endfunction

"call s:CMakeModule('FetchContent')
"call s:CMakeModule('ExternalData')

"{{{ 'Keyword' Commands
"call s:CMakeCommand('cmake_minimum_required', 'VERSION')
"call s:CMakeCommand('get_property')
"call s:CMakeCommand('set_property')
"call s:CMakeCommand('message')
"call s:CMakeCommand('option')
"call s:CMakeCommand('string')
"call s:CMakeCommand('file')
"call s:CMakeCommand('list')
"
"call s:CMakeCommand('math', 'EXPR')
"
"call s:CMakeCommand('unset', 'PARENT_SCOPE')
"call s:CMakeCommand('set', 'PARENT_SCOPE')
"
"if !exists('g:cmake_disable_ixm_highlighting')
"  call s:CMakeCommand('console')
"  call s:CMakeCommand('dict')
"  call s:CMakeCommand('find')
"  call s:CMakeCommand('log')
"endif

"call s:CMakeCommand('endfunction')
"call s:CMakeCommand('endmacro')
"call s:CMakeCommand('function') " TODO: Make this a fold marker
"call s:CMakeCommand('macro') " TODO: Make this a fold marker

"syntax keyword cmakeIncludeCommand include nextgroup=cmakeIncludeArgs
"syntax region cmakeIncludeArgs start=/include\zs(/ end=/)/ contains=cmakeModules,cmakeDeprecatedModules
"highlight default link cmakeIncludeCommand PreProc
"highlight default link cmakeModules Include
"highlight default link cmakeDeprecatedModules SpellRare

"}}}

syntax keyword cmakeIncludeGuardCommand include_guard

"highlight default link cmakeFetchContentCommands Function

"{{{ Modules
syntax keyword cmakeModules contained
      \ AddFileDependencies
      \ ExternalData
      \ ExternalProject
      \ FeatureSummary
      \ FetchContent
      \ FindPackageHandleStandardArgs
      \ FindPackageMessage
      \ FortranCInterface
      \ GenerateExportHeader
      \ GetPrerequisites
      \ GNUInstallDirs
      \ GoogleTest
      \ InstallRequiredSystemLibraries
      \ ProcessorCount
      \ SelectLibraryConfigurations
      \ WriteCompilerDetectionHeader

let b:current_syntax = "cmake"
