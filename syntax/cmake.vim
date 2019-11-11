" Vim syntax file
" Program: CMake - Cross Platform Meta Build System
" Language: CMake (with optional IXM enhancements)
" Author: Isabella Muerte
" License: MIT License

" There's currently no easy way for us to override all the garbage in the
" default plugin. So we have to do this manually :/
if !exists('b:override_syntax') | syntax clear | endif
let b:override_syntax = 1
if exists('b:current_syntax') | finish | endif
const s:cpo = &cpo
set cpo&vim

syntax iskeyword @,45-57,@-@,+,_

" Control flow commands
syntax keyword cmakeCommand function endfunction macro endmacro
syntax keyword cmakeConditional if elseif while nextgroup=cmakeConditionalArguments
syntax keyword cmakeConditional endwhile endif else

syntax keyword cmakeRepeat foreach nextgroup=cmakeRepeatArguments
syntax keyword cmakeRepeat endforeach

syntax keyword cmakeStatement continue return break

syntax region cmakeFold start=/\v%(<function)@<=\s*\(/ms=e end=/\v%(<endfunction)@<=\s*\(/me=e transparent fold
syntax region cmakeFold start=/\v%(<macro)@<=\s*\(/ms=e end=/\v%(<endmacro)@<=\s*\(/me=e transparent fold

syntax region cmakeFold start=/\v%(<foreach)@<=\s*\(/ms=e end=/\v%(<endforeach)@<=\s*\(/me=e transparent fold
syntax region cmakeFold start=/\v%(<while)@<=\s*\(/ms=e end=/\v%(endwhile)@<=\s*\(/me=e transparent fold
syntax region cmakeFold start=/\v%(<if)@<=\s*\(/ms=e end=/\v%(<endif)@<=\s*\(/me=e transparent fold

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

syntax match cmakeEscape /\v\\n/ containedin=cmakeString
syntax match cmakeEscape /\v\\t/ containedin=cmakeString

syntax region cmakeString start=/\v\[\z(\={,9})\[/ end=/\v\]\z1\]/ contains=@cmakeDerefExpression
syntax region cmakeString start=/"/ end=/\v%(\\)@<!"/ contains=@cmakeDerefExpression

syntax region cmakeComment start='#' end='$' oneline contains=cmakeTodo,@Spell
syntax region cmakeComment start=/\v#\[\z(\={,9})\[/ end=/\v\]\z1\]/ contains=cmakeTodo,@Spell

syntax region cmakeGenerator start="$<" end=">" contains=@cmakeGeneratorExpression

syntax region cmakeDefined start='CACHE{' end='}' contained contains=@cmakeArgument
syntax region cmakeDefined start='ENV{' end='}' contained contains=@cmakeArgument

syntax keyword cmakeTodo contained FIXME NOTE TODO HACK BUG XXX

syntax keyword cmakeConditionalOperator contained IS_NEWER_THAN
syntax keyword cmakeConditionalOperator contained IS_DIRECTORY
syntax keyword cmakeConditionalOperator contained IS_ABSOLUTE
syntax keyword cmakeConditionalOperator contained IS_SYMLINK
syntax keyword cmakeConditionalOperator contained EXISTS

syntax keyword cmakeConditionalOperator contained VERSION_GREATER_EQUAL
syntax keyword cmakeConditionalOperator contained VERSION_LESS_EQUAL
syntax keyword cmakeConditionalOperator contained VERSION_GREATER
syntax keyword cmakeConditionalOperator contained VERSION_EQUAL
syntax keyword cmakeConditionalOperator contained VERSION_LESS

syntax keyword cmakeConditionalOperator contained STRGREATER_EQUAL
syntax keyword cmakeConditionalOperator contained STRLESS_EQUAL
syntax keyword cmakeConditionalOperator contained STRGREATER
syntax keyword cmakeConditionalOperator contained STREQUAL
syntax keyword cmakeConditionalOperator contained STRLESS

syntax keyword cmakeConditionalOperator contained GREATER_EQUAL
syntax keyword cmakeConditionalOperator contained LESS_EQUAL
syntax keyword cmakeConditionalOperator contained GREATER
syntax keyword cmakeConditionalOperator contained EQUAL
syntax keyword cmakeConditionalOperator contained LESS

syntax keyword cmakeConditionalOperator contained IN_LIST
syntax keyword cmakeConditionalOperator contained DEFINED
syntax keyword cmakeConditionalOperator contained COMMAND
syntax keyword cmakeConditionalOperator contained MATCHES
syntax keyword cmakeConditionalOperator contained POLICY
syntax keyword cmakeConditionalOperator contained TARGET
syntax keyword cmakeConditionalOperator contained TEST

syntax keyword cmakeConditionalOperator contained NOT AND OR

syntax keyword cmakeRepeatOperator contained RANGE LISTS ITEMS IN

" TODO: Move these to a separate file. 
syntax keyword cmakeGeneratorOperator contained Fortran_COMPILER_VERSION
syntax keyword cmakeGeneratorOperator contained OBJCXX_COMPILER_VERSION
syntax keyword cmakeGeneratorOperator contained OBJC_COMPILER_VERSION
syntax keyword cmakeGeneratorOperator contained CUDA_COMPILER_VERSION
syntax keyword cmakeGeneratorOperator contained CXX_COMPILER_VERSION
syntax keyword cmakeGeneratorOperator contained C_COMPILER_VERSION

syntax keyword cmakeGeneratorOperator contained Fortran_COMPILER_ID
syntax keyword cmakeGeneratorOperator contained OBJCXX_COMPILER_ID
syntax keyword cmakeGeneratorOperator contained OBJC_COMPILER_ID
syntax keyword cmakeGeneratorOperator contained CUDA_COMPILER_ID
syntax keyword cmakeGeneratorOperator contained CXX_COMPILER_ID
syntax keyword cmakeGeneratorOperator contained C_COMPILER_ID

syntax keyword cmakeGeneratorOperator contained COMPILE_LANG_AND_ID
syntax keyword cmakeGeneratorOperator contained COMPILE_LANGUAGE
syntax keyword cmakeGeneratorOperator contained COMPILE_FEATURES

syntax keyword cmakeGeneratorOperator contained TARGET_POLICY
syntax keyword cmakeGeneratorOperator contained TARGET_EXISTS
syntax keyword cmakeGeneratorOperator contained PLATFORM_ID
syntax keyword cmakeGeneratorOperator contained CONFIG

syntax keyword cmakeGeneratorOperator contained VERSION_GREATER_EQUAL
syntax keyword cmakeGeneratorOperator contained VERSION_LESS_EQUAL
syntax keyword cmakeGeneratorOperator contained VERSION_GREATER
syntax keyword cmakeGeneratorOperator contained VERSION_EQUAL
syntax keyword cmakeGeneratorOperator contained VERSION_LESS

syntax keyword cmakeGeneratorOperator contained ANGLE-R COMMA SEMICOLON
syntax keyword cmakeGeneratorOperator contained STREQUAL IN_LIST EQUAL
syntax keyword cmakeGeneratorOperator contained BOOL AND OR NOT
syntax keyword cmakeGeneratorOperator contained IF

syntax keyword cmakeGeneratorOperator contained REMOVE_DUPLICATES
syntax keyword cmakeGeneratorOperator contained TARGET_GENEX_EVAL
syntax keyword cmakeGeneratorOperator contained GENEX_EVAL 
syntax keyword cmakeGeneratorOperator contained LOWER_CASE
syntax keyword cmakeGeneratorOperator contained UPPER_CASE
syntax keyword cmakeGeneratorOperator contained FILTER
syntax keyword cmakeGeneratorOperator contained JOIN

syntax keyword cmakeGeneratorOperator contained TARGET_NAME_IF_EXISTS
syntax keyword cmakeGeneratorOperator contained TARGET_PROPERTY
syntax keyword cmakeGeneratorOperator contained INSTALL_PREFIX

syntax keyword cmakeGeneratorOperator contained TARGET_FILE_BASE_NAME
syntax keyword cmakeGeneratorOperator contained TARGET_FILE_PREFIX
syntax keyword cmakeGeneratorOperator contained TARGET_FILE_SUFFIX
syntax keyword cmakeGeneratorOperator contained TARGET_FILE_NAME
syntax keyword cmakeGeneratorOperator contained TARGET_FILE_DIR
syntax keyword cmakeGeneratorOperator contained TARGET_FILE

syntax keyword cmakeGeneratorOperator contained TARGET_LINKER_FILE_BASE_NAME
syntax keyword cmakeGeneratorOperator contained TARGET_LINKER_FILE_PREFIX
syntax keyword cmakeGeneratorOperator contained TARGET_LINKER_FILE_SUFFIX
syntax keyword cmakeGeneratorOperator contained TARGET_LINKER_FILE_NAME
syntax keyword cmakeGeneratorOperator contained TARGET_LINKER_FILE_DIR
syntax keyword cmakeGeneratorOperator contained TARGET_LINKER_FILE

syntax keyword cmakeGeneratorOperator contained TARGET_SONAME_FILE_NAME
syntax keyword cmakeGeneratorOperator contained TARGET_SONAME_FILE_DIR
syntax keyword cmakeGeneratorOperator contained TARGET_SONAME_FILE

syntax keyword cmakeGeneratorOperator contained TARGET_PDB_FILE_NAME
syntax keyword cmakeGeneratorOperator contained TARGET_PDB_FILE_DIR
syntax keyword cmakeGeneratorOperator contained TARGET_PDB_FILE

syntax keyword cmakeGeneratorOperator contained TARGET_BUNDLE_CONTENT_DIR
syntax keyword cmakeGeneratorOperator contained TARGET_BUNDLE_DIR

syntax keyword cmakeGeneratorOperator contained MAKE_C_IDENTIFIER
syntax keyword cmakeGeneratorOperator contained INSTALL_INTERFACE
syntax keyword cmakeGeneratorOperator contained BUILD_INTERFACE
syntax keyword cmakeGeneratorOperator contained TARGET_OBJECTS
syntax keyword cmakeGeneratorOperator contained TARGET_NAME
syntax keyword cmakeGeneratorOperator contained SHELL_PATH
syntax keyword cmakeGeneratorOperator contained LINK_ONLY

syntax cluster cmakeGeneratorExpression add=cmakeGeneratorOperator
syntax cluster cmakeGeneratorExpression add=cmakeGenerator
syntax cluster cmakeGeneratorExpression add=cmakeReference
syntax cluster cmakeGeneratorExpression add=cmakeProperty

syntax cluster cmakeArgument add=cmakeReference
syntax cluster cmakeArgument add=cmakeVariable

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
syntax cluster cmakeExpression add=cmakeProperty
syntax cluster cmakeExpression add=cmakeVariable

call CMakeGenerateSyntax()

" These *must* go after every syntax keyword/match/region command
syntax region cmakeReference oneline display contained contains=@cmakeArgument start='$CACHE{' end='}'
syntax region cmakeReference oneline display contained contains=@cmakeArgument start='$ENV{' end='}'
syntax region cmakeReference oneline display contained contains=@cmakeArgument start='${' end='}'

" TODO: Place all generated syntax sync match groups here
syntax sync match cmakeCommentSync grouphere cmakeComment /\v#\[\={,9}\[/
syntax sync match cmakeCommentSync groupthere NONE /\v\]\]/

syntax sync match cmakeStringSync grouphere cmakeString /\v\[\={,9}\[/
syntax sync match cmakeStringSync groupthere NONE /\v\]\]/

" Override default links
highlight! default link cmakeProperty StorageClass
highlight! default link cmakeCommand Keyword

highlight default link cmakeFunction Function
highlight default link cmakeMacro Macro

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
highlight default link cmakeEscape SpecialChar
highlight default link cmakeFloat Float
highlight default link cmakeTarget Type

highlight default link cmakeComment Comment
highlight default link cmakeTodo TODO

syntax sync minlines=200
syntax sync maxlines=500

let b:override_syntax = "cmake"
let &cpo = s:cpo
unlet s:cpo
