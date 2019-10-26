if exists('cmake_plugin_loaded') | finish | endif
let g:cmake_plugin_loaded = 1

" TODO: load vscode/settings.json if set
" TODO: load cmake-variants.json if it exists
" keys
" sourceDirectory -> path
" buildDirectory -> path
" installPrefix -> path
" cmakePath -> path
" buildBeforeRun -> bool
" configureSettings -> dict (with limited substitution)
" environment -> dict
" configureEnvironment -> dict
" buildEnvironment -> dict
" buildArgs -> array
" buildToolArgs -> array
" preferredGenerators
" generator
" defaultVariants
" copyCompileCommands
" loggingLevel

function! s:cmake_find_build()
endfunction

"command! -nargs=? CMake call s:cmake(<f-args>)

function! s:cmake(...)
  if !s:find_build_dir() | return | endif
  let &makeprg = 'cmake --build ' . shellescape(b:build_dir) . ' --target'
endfunction

function! CMakeRegenerateSyntax()
  call cmake#syntax#Subcommands()
  call cmake#syntax#Properties()
  call cmake#syntax#Variables()
  call cmake#syntax#Modules()

  call cmake#syntax#References()

  "if !filereadable(g:cmake#syntax#cache)
    call extend(g:cmake#syntax#text, g:cmake#syntax#syntax_text)
    call extend(g:cmake#syntax#text, g:cmake#syntax#highlight_text)
    call writefile(g:cmake#syntax#text, g:cmake#syntax#cache)
  "endif
endfunction
