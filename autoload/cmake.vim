" Needed so we know where the data directory in our plugin is
let s:path = finddir('data', expand('<sfile>:h') . ';')

function! cmake#Warn(...)
  echohl WarningMsg | echomsg join(a:000, ' ') | echohl None
endfunction

" Flattens lists of lists

" Applies f to each element in list, and returns the result
function! cmake#Apply(list, f, ...)
  let l:result = []
  for item in a:list
    eval add(l:result, function(a:f, item)
  endfor
  return l:result
endfunction
