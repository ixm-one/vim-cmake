"if exists('b:did_indent') | finish | endif
let b:did_indent = 1

" reset to 'sane' defaults, then add ours
setlocal indentkeys=0),0],0#,!^F,o,O
setlocal indentkeys+=0=~endif(,endforeach(,endmacro(,endfunction(,else(,elseif(,endwhile(
setlocal indentexpr=GetCMakeIndent(v:lnum)
setlocal autoindent

if exists("*GetCMakeIndent") | finish | endif

const s:cpo = &cpo
set cpo&vim

const s:call = '\v^\s*\h\w+\s*\('
const s:exec = '\v^\s*\)'

const s:begin = '\v^\s*(if|elseif|else|foreach|while|function|macro)\s*\('
const s:end = '\v^\s*(endif|endwhile|endforeach|endfunction|endmacro)\s*\('

" Find a line above 'lnum' that isn't blank, in a comment, or string
function! s:previous(n)
  let n = prevnonblank(a:n)
  while s:skippable(n, 1)
    let n = prevnonblank(n - 1)
  endwhile
  return n
endfunction

" Return line without trailing single-line comment
function! s:content(n)
  return substitute(getline(a:n), '\v#.*$', '', '')
endfunction

function! s:skippable(line, col)
  const skippable = ['cmakeComment', 'cmakeString']
  return count(skippable, synIDattr(synID(a:line, a:col, 1), "name"))
endfunction

function GetCMakeIndent(n)
  let p = s:previous(a:n - 1)
  if !p | return 0 | endif

  if s:skippable(a:n, 1) | return -1 | endif

  let current = s:content(a:n)
  echomsg current =~# s:exec
  let prev = s:content(p)
  echomsg prev
  let amt = indent(p)
  echomsg amt

  if prev =~# s:begin || prev =~# s:call | let amt += shiftwidth() | endif
  if prev =~# s:end || current =~# s:exec | let amt -= shiftwidth() | endif

  return amt
endfunction

let &cpo = s:cpo
