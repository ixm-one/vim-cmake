" Find all files as necessary and return the list. This *does not* compute
" the hash to see if files need to be regenerated.
function! s:files () abort 
  let paths = deepcopy(get(g:, 'cmake_api_path', []))
  let paths = join(map(paths, {idx, val -> fnamemodify(val, ':p') }), ',')
  let runtimefiles = globpath(&runtimepath, 'cmake/**/*.json', v:false, v:true)
  " TODO: make sure we get vim package behavior correct
  let apifiles = globpath(paths, 'cmake/**/*.json', v:false, v:true)
  return uniq(runtimefiles + apifiles)
endfunction

" Used to name variables.
function s:variable(json)
endfunction

" Used to mark properties.
function s:property(json)
endfunction

" Used to name modules that can be included
function s:include(json)
endfunction

" Used for module definition files (FetchContent.json, etc.)
function s:module(json) 
endfunction

" Used to load information on a command
function s:command(json)
endfunction

const switch = #{
  \ variable: function('s:variable')
  \ property: function('s:property')
  \ command: function('s:command')
  \ package: function('s:package')
  \ include: function('s:include')
  \ module: function('s:module'),
\}

" This returns the set of syntax and highlighting commands for a given file.
" The value returned is actually a dictionary, so that we can more easily
" order the syntax file correctly. Keys are:
" highlight
" cluster
" keyword
" match
" region
function! s:load(path) abort
  if !filereadable(a:path) |
    echoerr "Could not load " a:path
  endif
  let json = json_decode(join(readfile(a:path), "\n"))
  let func = get(switch, get(json, '@type', 'basic'))
  return func(json)
endfunction

let cmake#api#files = s:files()
