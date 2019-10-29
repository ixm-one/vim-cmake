" Convenience functions to serialize IXM dict() files to and from Vim
let s:nel = join(map([194, 133], {_, val -> nr2char(val) }), '')
let s:ind = join(map([194, 132], {_, val -> nr2char(val) }), '')
let s:us = nr2char(31)
let s:rs = nr2char(30)

function! s:conceal(text)
  return substitute(substitute(a:text, '\n', s:nel, "g"), '\r', s:ind, "g")
endfunction

function! s:reveal(text)
  return substitute(substitute(a:text, s:nel, "\n", "g"), s:ind, "\r", "g")
endfunction

" TODO: Need to deny lists of lists 
function! s:into(expr)
  if type(a:expr) == v:t_string
    return a:expr
  elseif count([v:t_number, v:t_float], type(a:expr))
    return string(a:expr)
  elseif type(a:expr) == v:t_bool
    return a:expr ? "YES" : "NO"
  elseif type(a:expr) == v:t_none
    return ""
  elseif type(a:expr) == v:t_list
    return join(map(a:expr, {_, val -> s:into(val) }), s:us)
  else
    throw "ixm#convert: Cannot convert expression of type " .. type(a:expr)
  endif
endfunction

function! s:from(expr)
  if count(['FALSE', 'OFF', 'N', 'IGNORE', 'NO'], a:expr) || a:expr =~ "-NOTFOUND$"
    return v:false
  elseif count(['TRUE', 'ON', 'Y', 'YES'], a:expr)
    return v:true
  elseif a:expr =~ '\v^\d+$'
    return str2nr(a:expr)
  elseif a:expr =~ s:us
    return map(split(s:reveal(a:expr), s:us), {_,val -> s:from(val) })
  endif
  return a:expr
endfunction

" Takes Either a List (as returned by readfile), Blob (as returned by readfile)
" or String. Returns a Dictionary. If a:expr is empty, Dictionary is empty.
" If the input is invalid, an error is thrown.
function! ixm#decode(expr)
  if !count([v:t_blob, v:t_list, v:t_string], type(a:expr))
    throw "ixm#decode: expected a Blob, String, or List but got " .. type(a:expr)
  endif
  let expr = a:expr
  let result = {}
  for line in expr
    let [key, val] = split(line, s:rs)
    let result[key] = s:from(val)
  endfor
  return result
endfunction

" Only takes a dictionary. Values cannot be dictionaries, and lists can only
" be one depth. Returns a list of strings
function! ixm#encode(dict)
  if type(a:dict) != v:t_dict
    throw "ixm#encode: expected v:t_dict but got " .. type(a:dict)
  endif
  let result = []
  for [key, value] in items(a:dict)
    let key ..= s:rs .. s:into(value)
    eval add(result, conceal(key))
  endfor
  return result
endfunction

" Convenience function around ixm#decode to load a file in-situ
function! ixm#load(path)
  let path = resolve(expand(a:path))
  let path = path =~ "[.]ixm$" ? a:path : a:path .. ".ixm"
  if !filereadable(path)
    throw "ixm#load: " .. path .. " is not readable or doesn't exist"
  endif
  return ixm#decode(readfile(path))
endfunction

" Convenience function around ixm#encode to save a file in-situ
function! ixm#save(path, dict)
  let path = resolve(expand(a:path))
  let path = path =~ "[.]ixm$" ? a:path : a:path .. ".ixm"
  let dir = fnamemodify(path, ":h")
  eval mkdir(dir, "p")
  writefile(path, data)
endfunction
