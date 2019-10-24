let cmake#syntax#text = []

function! s:found(group, name)
  if exists('g:cmake#data#{a:group}#{a:name}') | return 1 | endif
  let l:var = join(['cmake', 'data', a:group, a:name], '#')
  return cmake#Warn('Cannot find ' . l:var)
endfunction

function! s:data(group, name)
  try
    return js_decode(join(g:cmake#data#{a:group}#{a:name}, "\n"))
  catch /\v^Vim%(.+):E121:/
    echohl WarningMsg | echomsg v:exception | echohl None
    return {}
  endtry
endfunction

function! cmake#syntax#LinkTo(from, to)
  call cmake#Execute('highlight', 'default', 'link', 'cmake' . a:from, a:to)
endfunction

function! cmake#syntax#Keyword(group, ...)
  if empty(a:000) | return | endif
  let l:text = join(cmake#Flatten(['syntax', 'keyword', 'cmake' . a:group, a:000]), ' ')
  call add(g:cmake#syntax#text, l:text)
  call cmake#Execute(l:text) 
endfunction

function! cmake#syntax#Match(group, pattern, ...)
  call cmake#Execute('syntax', 'match', 'cmake' . a:group, '/' . a:pattern . '/', a:000)
endfunction

function! cmake#syntax#Region(group, start, end, ...)
  call cmake#Execute('syntax', 'region', 'cmake' . a:group, 'start=' . a:start, 'end=' . a:end, a:000)
endfunction

function! cmake#syntax#Suffix(group, items)
  for pattern in a:items
    call cmake#syntax#Match(a:group, '\v<' . pattern . '_\w+>', 'display')
  endfor
endfunction

function! cmake#syntax#Prefix(group, items)
  for pattern in a:items
    call cmake#syntax#Match(a:group, '\v<\w+_' . pattern . '>', 'display')
  endfor
endfunction

function! cmake#syntax#Pattern(group, items)
  for pattern in a:items
    call cmake#syntax#Match(a:group, '\v<' . pattern . '>', 'display')
  endfor
endfunction

function! cmake#syntax#Reference(prefix)
  let l:options = ['oneline', 'contains=cmakeVariable,cmakeReference']
  call cmake#syntax#Region('Reference', "'$" . a:prefix . "{'", "'}'", l:options)
endfunction

function! cmake#syntax#Module(filename)
endfunction


" TODO: group name is *incorrect* for deprecated data
function! cmake#syntax#Variables()
  let l:variables = cmake#Data('variables')
  for [name, data] in items(l:variables)
    let l:highlight = get(data, 'highlight', 'Identifier')
    let l:group = l:highlight == 'Identifier'
          \ ? 'Variable'
          \ : cmake#Capitalize(name) . 'Variable'
    call cmake#syntax#Keyword(l:group, get(data, 'keyword', []))
    call cmake#syntax#Pattern(l:group, get(data, 'pattern', []))
    call cmake#syntax#Suffix(l:group, get(data, 'suffix', []))
    call cmake#syntax#Prefix(l:group, get(data, 'prefix', []))
    call cmake#syntax#LinkTo(l:group, l:highlight)
  endfor
endfunction

function! cmake#syntax#OperatorSet(name)
  let l:data = s:data('operators', a:name)
  let l:group = cmake#Capitalize(a:name) . 'Operator'
  let l:entries = type(l:data) == v:t_dict ? cmake#Flatten(values(l:data)) : l:data
  for entry in entries
    call cmake#syntax#Keyword(l:group, entry, 'contained')
  endfor
  call cmake#syntax#LinkTo(l:group, 'Operator')
endfunction

function! cmake#syntax#PropertySet(name)
  let l:data = s:data('properties', a:name)
  let l:highlight = get(l:data, 'highlight', 'StorageClass')
  let l:group = has_key(l:data, 'highlight')
        \ ? cmake#Capitalize(a:name) . 'Property'
        \ : 'Property'
  call cmake#syntax#Keyword(l:group, get(l:data, 'keyword', []))
  call cmake#syntax#Pattern(l:group, get(l:data, 'pattern', []))
  call cmake#syntax#Suffix(l:group, get(l:data, 'suffix', []))
  call cmake#syntax#Prefix(l:group, get(l:data, 'prefix', []))
  call cmake#syntax#LinkTo(l:group, l:highlight)
endfunction

function! cmake#syntax#Operators()
  call cmake#syntax#OperatorSet('conditional')
  call cmake#syntax#OperatorSet('generator')
  call cmake#syntax#OperatorSet('repeat')
endfunction

function! cmake#syntax#Properties()
  call cmake#syntax#PropertySet('global')
  call cmake#syntax#PropertySet('directory')
  call cmake#syntax#PropertySet('target')
  call cmake#syntax#PropertySet('test')
  call cmake#syntax#PropertySet('source_file')
  call cmake#syntax#PropertySet('cache')
  call cmake#syntax#PropertySet('installed')
  call cmake#syntax#PropertySet('deprecated')
endfunction

