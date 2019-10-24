" Needed so we know where the data directory in our plugin is
let s:path = finddir('data', expand('<sfile>:h') . ';')

function! cmake#Warn(...)
  echohl WarningMsg | echomsg join(a:000, ' ') | echohl None
endfunction

function! cmake#Load(path)
  if !filereadable(a:path) | return {} | endif
  return json_decode(join(readfile(a:path), "\n"))
endfunction

" Loads a json file from <plugin-root>/data. If the file doesn't exist, return
" an empty dictionary
function! cmake#Data(...)
  let l:tail = join(a:000, '/')
  let l:file = fnamemodify(resolve(join([s:path, l:tail], '/') . '.json'), ':p')
  return cmake#Load(l:file)
endfunction

" Flattens lists of lists
function! cmake#Flatten(items)
  if type(a:items) != v:t_list | return [a:items] | endif
  if empty(a:items) | return a:items | endif
  let l:result = []
  for item in a:items
    let l:result += cmake#Flatten(item)
  endfor
  return l:result
endfunction

" converts snake_case to PascalCase
function! cmake#Capitalize(name)
  let l:words = split(a:name, '_')
  let l:words = map(l:words, {idx, val -> substitute(val, '^.', '\u\0', "") })
  return join(l:words, '')
endfunction

" Applies f to each element in list, and returns the result
function! cmake#Apply(list, f, ...)
  let l:result = []
  for item in a:list
    eval add(l:result, function(a:f, a:000)(item))
  endfor
  return l:result
endfunction

function! cmake#Execute(...)
  execute(join(cmake#Flatten(a:000), ' '))
endfunction
