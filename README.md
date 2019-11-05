# vim-cmake

A new, next generation, CMake plugin for vim, because the one Kitware gives us
is broken.

## Roadmap

The following features are currently planned for a 1.0 release.

### General 

 * [ ] Investigate [text-prop][] for better syntax highlighting performance.
 * [ ] Generate syntax files from JSON
 * [ ] Generate dictionary files
 * [ ] Generate tag files
 * [ ] Configure and Build support
 * [ ] Automatic tag file generation
 * [ ] Support for using [vscode-cmake-tool][] configuration files
 * [x] Support for editing IXM dict files
 * [ ] Support for converting IXM dict files to and from VimL Dictionaries
 * [ ] Menu options for common actions (configure, build, etc.)
 * [x] Better highlighting settings

### Vim Options

 * [ ] ['completefunc'][] 
 * [ ] ['omnifunc'][] 
 * [ ] ['includeexpr'][] 
 * [ ] ['formatexpr'][] 
 * [ ] ['indentexpr'][] 
 * [x] ['commentstring'][] 
 * [ ] ['dictionary'][]
 * [ ] ['statusline'][] 
 * [x] ['comments'][] 
 * [ ] ['include'][] 
 * [ ] ['define'][]

 * [ ] [text-prop][]
 * [ ] [tags][] 

## Installation

Installation is fairly simple as with most other managers. It's available as
one package, so dump it into a directory and `packadd`, or use something like
[vim-plug][1]

```
<PluginManagerCommand> 'ixm-one/vim-cmake'
```

## Usage

All information is available in the documentation. Generate it via `:helptags`,
or read the [documentation file][2] directly.


[1]: https://github.com/junegunn/vim-plug 
[2]: doc/cmake.txt

[vscode-cmake-tools]: https://github.com/microsoft/vscode-cmake-tools

[text-prop]: https://vimhelp.org/textprop.txt.html 
[tags][]: https://vimhelp.org/tagsrch.txt.html 

['completefunc']: https://vimhelp.org/options.txt.html#'completefunc' 
['omnifunc']: https://vimhelp.org/options.txt.html#'omnifunc'

['includeexpr']: https://vimhelp.org/options.txt.html#'includeexpr' 
['formatexpr']: https://vimhelp.org/options.txt.html#'formatexpr' 
['indentexpr']: https://vimhelp.org/options.txt.html#'indentexpr'

['commentstring']: https://vimhelp.org/options.txt.html#'commentstring' 
['dictionary']: https://vimhelp.org/options.txt.html#'dictionary'
['statusline']: https://vimhelp.org/options.txt.html#'statusline' 
['comments']: https://vimhelp.org/options.txt.html#'comments'
['include']: https://vimhelp.org/options.txt.html#'include' 
['define']: https://vimhelp.org/options.txt.html#'define'
