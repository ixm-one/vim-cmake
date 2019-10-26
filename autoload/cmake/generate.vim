let s:plugin_root = fnamemodify(findfile('README.md', expand('<sfile>:h') .. ';'), ':h')

" TODO: All script specific functions need to be moved to the cmake#syntax#
" namespace when possible. Reading files will be moved to cmake#json# and
" actual command accumulation and file writing will be placed here.

function! s:flatten(items)
  if type(a:items) != v:t_list | return [a:items] | endif
  if empty(a:items) | return a:items | endif
  let l:result = []
  for item in a:items
    let l:result += s:flatten(item)
  endfor
  return l:result
endfunction

function! s:kwargs(dict)
  let result = []
  for [key, value] in items(a:dict)
    if type(value) == v:t_list
      let value = join(value, ',')
    endif
    let result += [key .. '=' .. value]
  endfor
  return result
endfunction

function! s:groupify(name)
  if a:name !~ '^cmake'
    return 'cmake' .. a:name
  endif
  return a:name
endfunction

function! s:link(from, to)
  return ['highlight', 'default', 'link', s:groupify(a:from), a:to]
endfunction

function! s:keyword(group, keywords, options = [], kwargs = {})
  let command = ['syntax', 'keyword']
  call add(command, s:groupify(a:group))
  call extend(command, a:keywords)
  call extend(command, a:options)
  call extend(command, s:kwargs(a:kwargs))
  return command
endfunction

function! s:match(group, pattern, options = [], kwwargs = { })
  let command = ['syntax', 'match']
  call add(command, s:groupify(a:group))
  call extend(command, a:options)
  call extend(command, s:kwargs(a:kwargs))
  call add(command, pattern)
  return command
endfunction

function! s:region(group, start, end, options=[], kwargs={ })
  let command = ['syntax', 'region']
  let start = 'start=' .. a:start
  let end = 'end=' .. a:end
  let skip = has_key(a:kwargs, 'skip') ? 'skip=' .. remove(a:kwargs, 'skip') : ''
  call add(command, s:groupify(a:group))
  call extend(command, a:options)
  call extend(command, s:kwargs(a:kwargs))
  call add(command, start)
  call add(command, end)
  return command
endfunction

function! cmake#generate#Operator(name)
  let data = get(g:cmake#data#operators, a:name, [])
  let group = a:name .. 'Operator'
  let entries = type(data) == v:t_dict ? s:flatten(values(data)) : data
  let operator = {}
  let operator.syntax = [s:keyword(group, entries, ['contained'])]
  let operator.highlight = [s:link(group, 'Operator')]
  return operator
endfunction

function! cmake#generate#Reference(prefix)
  let start = "'$" .. a:prefix .. "{'"
  let end = "'}'"
  let options = ['oneline', 'display', 'contained']
  return [s:region('Reference', start, end, options, #{contains: '@cmakeArgument'})]
endfunction

function! cmake#generate#SubcommandFlags() dict
  if empty(self.flags) | return [] | endif
  return s:keyword(self.flag_group, self.flags, ['contained'], #{containedin: self.match_group})
endfunction
