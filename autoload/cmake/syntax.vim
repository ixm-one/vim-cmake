let s:plugin_root = fnamemodify(findfile('README.md', expand('<sfile>:h') .. ';'), ':h')
let s:gitdir = join([s:plugin_root, '.git'], '/')

function! s:flatten(items)
  if type(a:items) != v:t_list | return [a:items] | endif
  if empty(a:items) | return a:items | endif
  let l:result = []
  for item in a:items
    let l:result += s:flatten(item)
  endfor
  return l:result
endfunction


" TODO: Replace this with a function in plugin/ that
" 1) Globs all of our data files
" 2) Reads them all into a buffer
" 3) Runs sha256 over them
" 4) Stores the resulting hash cmake#syntax#cache
" This removes the need to call git, and know where the git directory is
function! cmake#syntax#Cache()
  let l:hash = trim(system('git --git-dir=' .. shellescape(s:gitdir) .. ' rev-parse HEAD'))
  let l:path = join([fnamemodify(s:gitdir, ':h'), '.cache'], '/')
  call mkdir(l:path, "p", 0700)
  return join([l:path, l:hash .. '.vim'], '/')
endfunction

let cmake#syntax#cache = cmake#syntax#Cache()
let cmake#syntax#text = []

let cmake#syntax#highlight_text = []
let cmake#syntax#syntax_text = []

function! s:execute(...)
  let l:command = join(s:flatten(a:000), ' ')
  call add(g:cmake#syntax#text, l:command)
endfunction

function! s:group(...)
  return 'cmake' .. join(a:000, '')
endfunction

function! s:capitalize(name)
  let l:words = split(tolower(a:name), '_')
  let l:words = map(l:words, {idx, val -> substitute(val, '^.', '\u\0', "") })
  return join(l:words, '')
endfunction

function! s:highlight(from, to)
  call add(g:cmake#syntax#highlight_text, join(['highlight', 'default', 'link', a:from, a:to], ' '))
endfunction

function! s:syntax_keyword(group, ...)
  call s:execute('syntax', 'keyword', a:group, a:000)
endfunction

function! s:match(group, pattern, ...)
  call s:execute('syntax', 'match', a:group, '/' .. a:pattern .. '/', a:000)
endfunction

function! cmake#syntax#Keyword(group, ...)
  if empty(a:000) | return | endif
  let l:command = join(s:flatten(['syntax', 'keyword', 'cmake' . a:group, a:000]), ' ')
  call add(g:cmake#syntax#syntax_text, l:command)
endfunction

function! cmake#syntax#Match(group, pattern, ...)
  call s:execute('syntax', 'match', 'cmake' . a:group, '/' . a:pattern . '/', a:000)
endfunction

function! cmake#syntax#Region(group, start, end, ...)
  call s:execute('syntax', 'region', 'cmake' . a:group, 'start=' . a:start, 'end=' . a:end, a:000)
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

function! cmake#syntax#Subcommand(command, subcommand, keywords = [], flags = [])
  let subcommand = #{
  \   category: a:command,
  \   name: a:subcommand,
  \   keywords: deepcopy(a:keywords),
  \   flags: deepcopy(a:flags)
  \ }
  function subcommand.group() dict
    return s:capitalize(self.category) .. s:capitalize(self.name)
  endfunction
  function subcommand.keyword() dict
    if empty(self.keywords) | return [] | endif

    return [self.keywords, 'contained', 'containedin=' .. self.match_group]
  endfunction
"  function subcommand.flag() dict
"    if empty(self.flags) | return [] | endif
"    return ['syntax', 'keyword', self.flag_group, self.flags, 'contained', 'containedin=' .. self.match_group]
"  endfunction
  function subcommand.command() dict
    return ['syntax', 'keyword', 'cmakeCommand', self.category, 'skipwhite', 'nextgroup=@' .. self.cluster_group]
  endfunction
  function subcommand.cluster() dict
    let l:category = s:capitalize(self.category)
    let l:target = s:group(self.group())
    return ['syntax', 'cluster', self.cluster_group, 'add=' .. l:target]
  endfunction
  function subcommand.match() dict
    const l:match = 'matchgroup=cmakeSubcommand'
    const l:start = 'start=/\v%(<' .. self.category .. ')@<=\s*\(\zs' .. self.name .. '/'
    const l:end = 'end=/\v\)/he=e-1'
    const l:contains = 'contains=@cmakeExpression'
    return ['syntax', 'region', self.match_group, l:match, l:start, l:end, l:contains]
  endfunction
  let subcommand.flag = function('cmake#generate#SubcommandFlags', subcommand)
  let subcommand.cluster_group = s:group(s:capitalize(subcommand.category), 'Subcommands')
  let subcommand.keyword_group = s:group(subcommand.group(), 'Keyword')
  let subcommand.flag_group = s:group(subcommand.group(), 'Flag')
  let subcommand.match_group = s:group(subcommand.group())
  return subcommand
endfunction

function! cmake#syntax#SubcommandSet(name)
  let l:data = get(g:cmake#data#subcommands, a:name)
  let l:shared_keywords = get(l:data, 'keyword', [])
  let l:shared_flags = get(l:data, 'flag', [])
  let l:complex = get(l:data, 'complex', {})
  call s:syntax_keyword('cmakeCommand', a:name, 'skipwhite', 'nextgroup=@' .. s:group(s:capitalize(a:name), 'Subcommands'))
  for [subcommand, values] in items(l:complex)
    let l:keywords = get(values, 'keyword', []) + l:shared_keywords
    let l:flags = get(values, 'flag', []) + l:shared_flags
    let l:subcommand = cmake#syntax#Subcommand(a:name, subcommand, l:keywords, l:flags)
    call s:execute(l:subcommand.cluster())
    call s:execute(l:subcommand.match())
    if !empty(l:subcommand.keywords)
      call s:syntax_keyword(l:subcommand.keyword_group, l:subcommand.keyword())
    endif
      call s:execute(l:subcommand.flag())
    if !empty(l:subcommand.keywords)
      call s:highlight(l:subcommand.keyword_group, 'cmakeKeyword')
    endif
    if !empty(l:subcommand.flags)
      call s:highlight(l:subcommand.flag_group, 'cmakeFlag')
    endif
    unlet l:keywords
    unlet l:flags
  endfor
  let l:simple = get(l:data, 'simple', [])
  for subcommand in l:simple
    let l:subcommand = cmake#syntax#Subcommand(a:name, subcommand, l:shared_keywords, l:shared_flags)
    call s:execute(l:subcommand.cluster())
    call s:execute(l:subcommand.match())
    if !empty(l:subcommand.keywords)
      call s:syntax_keyword(l:subcommand.keyword_group, l:subcommand.keyword())
    endif
    call s:execute(l:subcommand.flag())
    if !empty(l:subcommand.keywords)
      call s:highlight(l:subcommand.keyword_group, 'cmakeKeyword')
    endif
    if !empty(l:subcommand.flags)
      call s:highlight(l:subcommand.flag_group, 'cmakeFlag')
    endif
  endfor
endfunction

function! cmake#syntax#ModuleSet(name)
  let l:data = get(g:cmake#data#modules, a:name, {})
  let l:data = type(l:data) == v:t_list
        \ ? #{ keyword: l:data }
        \ : l:data
  let l:highlight = get(l:data, 'highlight', 'Identifier')
  let l:group = has_key(l:data, 'highlight')
        \ ? s:capitalize(a:name) .. 'Include'
        \ : 'Include'
  call cmake#syntax#Keyword(l:group, get(data, 'keyword', []))
  call s:highlight('cmake' .. l:group, l:highlight)
endfunction


function! cmake#syntax#VariableSet(name)
  let l:data = get(g:cmake#data#variables, a:name, {})
  let l:highlight = get(data, 'highlight', 'Identifier')
  let l:group = has_key(l:data, 'highlight')
        \ ? s:capitalize(a:name) . 'Variable'
        \ : 'Variable'
  call cmake#syntax#Keyword(l:group, get(data, 'keyword', []))
  call cmake#syntax#Pattern(l:group, get(data, 'pattern', []))
  call cmake#syntax#Suffix(l:group, get(data, 'suffix', []))
  call cmake#syntax#Prefix(l:group, get(data, 'prefix', []))
  call s:highlight('cmake' .. l:group, l:highlight)
endfunction

function! cmake#syntax#OperatorSet(name)
  let l:data = get(g:cmake#data#operators, a:name, [])
  let l:group = s:capitalize(a:name) . 'Operator'
  let l:entries = type(l:data) == v:t_dict ? s:flatten(values(l:data)) : l:data
  call cmake#syntax#Keyword(l:group, entries, 'contained')
  call s:highlight('cmake' .. l:group, 'Operator')
endfunction

function! cmake#syntax#PropertySet(name)
  let l:data = get(g:cmake#data#properties, a:name, {})
  let l:highlight = get(l:data, 'highlight', 'StorageClass')
  let l:group = has_key(l:data, 'highlight')
        \ ? s:capitalize(a:name) . 'Property'
        \ : 'Property'
  call cmake#syntax#Keyword(l:group, get(l:data, 'keyword', []), 'contained')
  call cmake#syntax#Pattern(l:group, get(l:data, 'pattern', []))
  call cmake#syntax#Suffix(l:group, get(l:data, 'suffix', []))
  call cmake#syntax#Prefix(l:group, get(l:data, 'prefix', []))
  call s:highlight('cmake' .. l:group, l:highlight)
endfunction

function! cmake#syntax#References()
  for prefix in ['CACHE', 'ENV', '']
    echo prefix
    let reference = cmake#generate#Reference(prefix)
    call map(reference, {idx, val -> join(val, ' ')})
    call extend(g:cmake#syntax#syntax_text, reference)
  endfor
endfunction

function! cmake#syntax#Operators()
  for name in keys(g:cmake#data#operators)
    let operator = cmake#generate#Operator(name)
    call map(operator.syntax, {idx, val -> join(val, ' ')})
    call map(operator.highlight, {idx, val -> join(val, ' ')})
    call extend(g:cmake#syntax#syntax_text, operator.syntax)
    call extend(g:cmake#syntax#highlight_text, operator.highlight)
  endfor
endfunction

function! cmake#syntax#Variables()
  for name in keys(g:cmake#data#variables)
    call cmake#syntax#VariableSet(name)
  endfor
endfunction

function! cmake#syntax#Properties()
  for name in keys(g:cmake#data#properties)
    call cmake#syntax#PropertySet(name)
  endfor
endfunction

function! cmake#syntax#Modules()
  for name in keys(g:cmake#data#modules)
    call cmake#syntax#ModuleSet(name)
  endfor
endfunction

function! cmake#syntax#Commands()
endfunction

" TODO: Move these to be under the commands/ directory
function! cmake#syntax#Subcommands()
  for name in keys(g:cmake#data#subcommands)
    call cmake#syntax#SubcommandSet(name)
  endfor
endfunction
