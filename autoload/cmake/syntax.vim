function! s:capitalize(name)
  let words = split(tolower(a:name), '_')
  let words = map(words, {_, val -> substitute(val, '^.', '\u\0', "") })
  return join(words, '')
endfunction

" merges multiple dictionaries into one
function! s:merge(...)
  let result = #{ keyword: [], match: [], region: [], highlight: [] }
  for dict in a:000
    for key in keys(result)
      let result[key] += get(dict, key, [])
    endfor
  endfor
  return result
endfunction

function! s:kwargs(dict)
  let result = []
  for [key, value] in items(a:dict)
    if type(value) = v:t_list
      let value = join(value, ',')
    endif
    let result += [printf("%s=%s", key, value)]
  endfor
  return result
endfunction

function! s:group(name)
  if a:name !~# '^cmake' | return 'cmake' .. a:name | endif
  return a:name
endfunction

function! s:keyword(group, keywords, options = [], kwargs = {})
  if empty(a:keywords) | return [] | endif
  let command = ['syntax', 'keyword']
  call add(command, a:group)
  call extend(command, a:keywords)
  call extend(command, a:options)
  call extend(command, s:kwargs(a:kwargs))
  return [l:command]
endfunction

function! s:match(group, pattern, options = [], kwargs = {})
  if empty(a:pattern) | return [] | endif
  let command = ['syntax', 'match']
  call add(command, a:group)
  call extend(command, a:options)
  call extend(command, s:kwargs(a:kwargs))
  call add(command, a:pattern)
  return [l:command]
endfunction

function! s:pattern(group, pattern, options = [], kwargs = {})
  return s:match(a:group, '/\v<' .. a:pattern .. '>/', a:options, a:kwargs)
endfunction

function! s:prefix(group, prefix, options = [], kwargs = {})
  return s:match(a:group, '/\v<\w+_' .. a:prefix .. '>/', a:options, a:kwargs)
endfunction

function! s:suffix(group, suffix, options = [], kwargs = {})
  return s:match(a:group, '/\v<' .. a:suffix .. '_\w+>/', a:options, a:kwargs)
endfunction

function! s:region(group, start, end, options=[], kwargs = {})
  let command = ['syntax', 'region']
  let start = 'start=' .. a:start
  let end = 'end=' .. a:end
  let skip = has_key(a:kwargs, 'skip') ? 'skip=' .. remove(a:kwargs, 'skip') : ''
  call add(command, a:group)
  call extend(command, a:options)
  call extend(command, s:kwargs(a:kwargs))
  call add(command, start)
  call add(command, skip)
  call add(command, end)
  return [l:command]
endfunction

function! s:highlight(from, to)
  return [['highlight', 'default', 'link', a:from, a:to]]
endfunction

function! s:metadata(object, highlight, group)
  let highlight = get(a:object, '@highlight', a:highlight)
  let group = s:group(s:capitalize(get(a:object, '@name', '')) .. a:group)
  return [l:highlight, l:group]
endfunction

" returns #{ keyword: [...], match: [...], highlight: [...] }
function! s:unit(object, highlight, group)
  let result = #{ keyword:[], match: [], highlight: [] }
  if type(a:object) != v:t_dict | return result | endif
  let [highlight, group] = s:metadata(a:object, a:highlight, a:group)
  for key in ['prefix', 'suffix', 'pattern']
    for pattern in get(a:object, key, [])
      let result['match'] += s:{key}(group, pattern, ['display'])
    endfor
  endfor
  let result['keyword'] = s:keyword(group, get(a:object, 'keyword', []))
  let result['highlight'] = s:highlight(group, highlight)
  return result
endfunction

" Returns #{ keyword: [...], match: [...], highlight: [...] }
function! cmake#syntax#variable(object)
  return s:unit(a:object, 'Identifier', 'Variable')
endfunction

function! cmake#syntax#property(object)
  return s:unit(a:object, 'StorageClass', 'Property')
endfunction

" Temporary until all other modules are marked
function! cmake#syntax#include(object)
  let result = #{ keyword: [], highlight: [] }
  let [highlight, group] = s:metadata(a:object, 'Include', 'Include')
  let result['keyword'] = s:keyword(group, get(a:object, 'keyword', []))
  let result['highlight'] = s:highlight(group, highlight)
  return result
endfunction

function! cmake#syntax#command(object, highlight = 'Keyword', group='Command')
  let result = #{ keyword: [], match: [], region: [], highlight: [] }
  if type(a:object) != v:t_dict | return [] | endif
  let [highlight, group] = s:metadata(a:object, a:highlight, a:group)
  for cmd in keys(a:object)
    let result['keyword'] += s:keyword(group, [cmd], ['skipwhite'])
  endfor
  let result['highlight'] = s:highlight(group, highlight)
  return result
endfunction

function! cmake#syntax#module(object)
  let result = #{ keyword: [], match: [], region: [], highlight: [] }
  if type(a:object) != v:t_dict | return result | endif
  let variable = cmake#syntax#variable(get(a:object, 'variable', {}))
  let function = cmake#syntax#command(get(a:object, 'function', {}), 'Function', 'Function')
  return s:merge(result, variable, function)
endfunction
