let s:gitdir = finddir('.git', expand('<sfile>:h') . ';')

function! cmake#syntax#Cache()
  let l:hash = trim(system('git --git-dir=' .. shellescape(s:gitdir) .. ' rev-parse HEAD'))
  let l:path = join([fnamemodify(s:gitdir, ':h'), '.cache'], '/')
  call mkdir(l:path, "p", 0700)
  return join([l:path, l:hash .. '.vim'], '/')
endfunction

let cmake#syntax#cache = cmake#syntax#Cache()
let cmake#syntax#text = []

function! s:flatten(items)
  if type(a:items) != v:t_list | return [a:items] | endif
  if empty(a:items) | return a:items | endif
  let l:result = []
  for item in a:items
    let l:result += s:flatten(item)
  endfor
  return l:result
endfunction

function! s:execute(...)
  let l:command = join(s:flatten(a:000), ' ')
  call add(g:cmake#syntax#text, l:command)
endfunction

function! s:group(...)
  return join(s:flatten(['cmake', a:000]), '')
endfunction

function! s:capitalize(name)
  let l:words = split(tolower(a:name), '_')
  let l:words = map(l:words, {idx, val -> substitute(val, '^.', '\u\0', "") })
  return join(l:words, '')
endfunction

function! s:found(group, name)
  if exists('g:cmake#data#{a:group}#{a:name}') | return 1 | endif
  let l:var = join(['cmake', 'data', a:group, a:name], '#')
  return cmake#Warn('Cannot find ' . l:var)
endfunction

function! cmake#syntax#LinkTo(from, to)
  call s:execute('highlight', 'default', 'link', 'cmake' . a:from, a:to)
endfunction

function! cmake#syntax#Keyword(group, ...)
  if empty(a:000) | return | endif
  call s:execute('syntax', 'keyword', 'cmake' . a:group, a:000)
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

function! cmake#syntax#Reference(prefix)
  let l:options = ['oneline', 'display', 'contained', 'contains=@cmakeArgument']
  call cmake#syntax#Region('Reference', "'$" . a:prefix . "{'", "'}'", l:options)
endfunction

function! cmake#syntax#SubcommandMatch(command, subcommand)
  let l:group = 'cmake' .. s:capitalize(a:command) .. s:capitalize(a:subcommand)
  let l:match = 'matchgroup=cmakeSubcommand'
  let l:start = 'start=/\v%(<list)@<=\s*\(\zs' .. a:subcommand .. '/'
  let l:end = 'end=/\v\)/'
  let l:contains = 'contains=@cmakeExpression'
  call s:execute('syntax', 'region', l:group, l:match, l:start, l:end, l:contains)
endfunction

function! cmake#syntax#SubcommandKeyword() dict
  if empty(self.keywords) | return [] | endif
  return ['syntax', 'keyword', 'cmake' .. self.group() .. 'Keyword', self.keywords, 'contained', 'containedin=' .. self.group()]
endfunction

function! cmake#syntax#SubcommandFlag() dict
  if empty(self.flags) | return [] | endif
  return ['syntax', 'keyword', 'cmake' .. self.group() .. 'Flag', self.flags, 'contained', 'containedin=' .. self.group()]
endfunction

function! cmake#syntax#Subcommand(command, subcommand, keywords = [], flags = [])
  let l:subcommand = #{
  \   category: a:command,
  \   name: a:subcommand,
  \   keywords: deepcopy(a:keywords),
  \   flags: deepcopy(a:flags)
  \ }
  function l:subcommand.cluster_group() dict
    return s:group(s:capitalize(self.category), 'Subcommands')
  endfunction
  function l:subcommand.keyword_group() dict
    return s:group(self.group(), 'Keyword')
  endfunction
  function l:subcommand.flag_group() dict
    return s:group(self.group(), 'Flag')
  endfunction
  function l:subcommand.match_group() dict
    return s:group(self.group())
  endfunction
  function l:subcommand.group() dict
    return s:capitalize(self.category) .. s:capitalize(self.name)
  endfunction
  function l:subcommand.keyword() dict
    if empty(self.keywords) | return [] | endif
    return ['syntax', 'keyword', self.keyword_group(), self.keywords, 'contained', 'containedin=' .. self.match_group()]
  endfunction
  function l:subcommand.flag() dict
    if empty(self.flags) | return [] | endif
    return ['syntax', 'keyword', self.flag_group(), self.flags, 'contained', 'containedin=' .. self.match_group()]
  endfunction
  function l:subcommand.command() dict
    return ['syntax', 'keyword', 'cmakeCommand', self.category, 'skipwhite', 'nextgroup=@' .. self.cluster_group()]
  endfunction
  function l:subcommand.highlight_keyword() dict
    return ['highlight', 'default', 'link', self.keyword_group(), 'cmakeKeyword']
  endfunction
  function l:subcommand.highlight_flag() dict
    return ['highlight', 'default', 'link', self.flag_group(), 'cmakeFlag']
  endfunction
  function l:subcommand.cluster() dict
    let l:category = s:capitalize(self.category)
    let l:target = s:group(self.group())
    return ['syntax', 'cluster', self.cluster_group(), 'add=' .. l:target]
  endfunction
  function l:subcommand.match() dict
    const l:match = 'matchgroup=cmakeSubcommand'
    const l:start = 'start=/\v%(<' .. self.category .. ')@<=\s*\(\zs' .. self.name .. '/'
    const l:end = 'end=/\v\)/he=e-1'
    const l:contains = 'contains=@cmakeExpression'
    return ['syntax', 'region', self.match_group(), l:match, l:start, l:end, l:contains]
  endfunction
  return l:subcommand
endfunction

function! cmake#syntax#SubcommandSet(name)
  let l:data = get(g:cmake#data#subcommands, a:name)
  let l:shared_keywords = get(l:data, 'keyword', [])
  let l:shared_flags = get(l:data, 'flag', [])
  let l:complex = get(l:data, 'complex', {})
  call s:execute('syntax', 'keyword', 'cmakeCommand', a:name, 'skipwhite', 'nextgroup=@' .. s:group(a:name, 'Subcommands'))
  for [subcommand, values] in items(l:complex)
    let l:keywords = get(values, 'keyword', []) + l:shared_keywords
    let l:flags = get(values, 'flag', []) + l:shared_flags
    let l:subcommand = cmake#syntax#Subcommand(a:name, subcommand, l:keywords, l:flags)
    call s:execute(l:subcommand.cluster())
    call s:execute(l:subcommand.match())
    call s:execute(l:subcommand.keyword())
    call s:execute(l:subcommand.flag())
    call s:execute(l:subcommand.highlight_keyword())
    call s:execute(l:subcommand.highlight_flag())
    unlet l:keywords
    unlet l:flags
  endfor
  let l:simple = get(l:data, 'simple', [])
  for subcommand in l:simple
    let l:subcommand = cmake#syntax#Subcommand(a:name, subcommand, l:shared_keywords, l:shared_flags)
    call s:execute(l:subcommand.cluster())
    call s:execute(l:subcommand.match())
    call s:execute(l:subcommand.keyword())
    call s:execute(l:subcommand.flag())
    if !empty(l:subcommand.keyword())
      call s:execute(l:subcommand.highlight_keyword())
    endif
    if !empty(l:subcommand.flag())
      call s:execute(l:subcommand.highlight_flag())
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
  call cmake#syntax#LinkTo(l:group, l:highlight)
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
  call cmake#syntax#LinkTo(l:group, l:highlight)
endfunction

function! cmake#syntax#OperatorSet(name)
  let l:data = get(g:cmake#data#operators, a:name, [])
  let l:group = s:capitalize(a:name) . 'Operator'
  let l:entries = type(l:data) == v:t_dict ? s:flatten(values(l:data)) : l:data
  call cmake#syntax#Keyword(l:group, entries, 'contained')
  call cmake#syntax#LinkTo(l:group, 'Operator')
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
  call cmake#syntax#LinkTo(l:group, l:highlight)
endfunction

function! cmake#syntax#Operators()
  call cmake#syntax#OperatorSet('conditional')
  call cmake#syntax#OperatorSet('generator')
  call cmake#syntax#OperatorSet('repeat')
endfunction

function! cmake#syntax#Variables()
  call cmake#syntax#VariableSet('information')
  call cmake#syntax#VariableSet('behavior')
  call cmake#syntax#VariableSet('system')
  call cmake#syntax#VariableSet('build')
  call cmake#syntax#VariableSet('language')
  call cmake#syntax#VariableSet('ctest')
  call cmake#syntax#VariableSet('cpack')
  call cmake#syntax#VariableSet('internal')
endfunction

function! cmake#syntax#Properties()
  call cmake#syntax#PropertySet('global')
  call cmake#syntax#PropertySet('directory')
  call cmake#syntax#PropertySet('target')
  call cmake#syntax#PropertySet('test')
  call cmake#syntax#PropertySet('source-file')
  call cmake#syntax#PropertySet('cache')
  call cmake#syntax#PropertySet('installed')
  call cmake#syntax#PropertySet('deprecated')
endfunction

function! cmake#syntax#Modules()
  call cmake#syntax#ModuleSet('utilities')
  call cmake#syntax#ModuleSet('check')
  call cmake#syntax#ModuleSet('cmake')
  call cmake#syntax#ModuleSet('ctest')
  call cmake#syntax#ModuleSet('cpack')
  call cmake#syntax#ModuleSet('test')
  call cmake#syntax#ModuleSet('use')

  call cmake#syntax#ModuleSet('deprecated')
  call cmake#syntax#ModuleSet('error')
endfunction

function! cmake#syntax#Subcommands()
  call cmake#syntax#SubcommandSet('add_custom_command')
  call cmake#syntax#SubcommandSet('get_property')
  call cmake#syntax#SubcommandSet('set_property')
  call cmake#syntax#SubcommandSet('install')
  call cmake#syntax#SubcommandSet('message')
  call cmake#syntax#SubcommandSet('string')
  call cmake#syntax#SubcommandSet('list')
  call cmake#syntax#SubcommandSet('file')
endfunction
