"if exists('cmake_plugin_loaded') | finish | endif
let g:cmake_plugin_loaded = 1

function! CMakeGenerateSyntax()
  let paths = cmake#json#find()
  " TODO: Place hash check here? Or possible before the call to #find
  for path in paths
    let object = cmake#json#load(path)
    if !has_key(object, '@type') | continue | endif
    if object['@type'] == 'property'
      "echo cmake#syntax#property(object)
    elseif object['@type'] == 'variable'
      "echo cmake#syntax#variable(object)
    elseif object['@type'] == 'module'
      echo cmake#syntax#module(object)
    endif
  endfor
endfunction

function! s:cmake_find_build()
endfunction

" TODO: Change the autoload functions to be cmake#cli
command! -nargs=* CMakeConfigure call cmake#configure(<f-args>)
command! -nargs=* CMakePackage call cmake#package(<f-args>)
command! -nargs=* CMakeBuild call cmake#build(<f-args>)
command! -nargs=* CMakeClean call cmake#clean(<f-args>)
command! -nargs=* CMakeTest call cmake#test(<f-args>)
command! -nargs=* CMakeRun call cmake#run(<f-args>)
command! -nargs=+ CMake call cmake#cmd(<q-args>)
