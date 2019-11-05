" Find all files as necessary and return the list. This does *not* compute the
" hash to see if files need to be regenerated.
function! cmake#json#find () abort
  let paths = deepcopy(get(g:, 'cmake_json_paths', []))
  let paths = join(map(paths, {_, val -> fnamemodify(val, ':p') }), ',')
  let runtimefiles = globpath(&runtimepath, 'cmake/**/*.json', v:false, v:true)
  let jsonfiles = globpath(paths, 'cmake/**/*.json', v:false, v:true)
  return uniq(runtimefiles + jsonfiles)
endfunction

function! cmake#json#load (path)
  if !filereadable(a:path) | echoerr "Could not load" a:path | endif
  let data = json_decode(join(readfile(a:path), "\n"))
  if !has_key(data, '@type')
    echohl WarningMsg | echomsg a:path "is missing '@type' key" | echohl None
    return {}
  endif
  return data
endfunction
