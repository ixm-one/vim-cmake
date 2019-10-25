let s:path = expand('<sfile>:h')

function! s:load(path, default = {})
  if !filereadable(a:path) | return a:default | endif
  return json_decode(join(readfile(a:path), "\n"))
endfunction

function! s:data(...)
  let l:tail = join(a:000, '/')
  let l:file = fnamemodify(resolve(join([s:path, 'json', l:tail], '/') .. '.json'), ':p')
  return s:load(l:file)
endfunction

let cmake#data#subcommands = s:data('subcommands')
let cmake#data#properties = s:data('properties')
let cmake#data#variables = s:data('variables')
let cmake#data#operators = s:data('operators')
let cmake#data#modules = s:data('modules')
