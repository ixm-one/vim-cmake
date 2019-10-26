# vim-cmake

A new, next generation, CMake plugin for vim, because the one Kitware gives us
is broken.

## Roadmap

 * [ ] Generate vim syntax files from API files
 * [x] Better highlighting settings
 * [ ] Configure and Build support
 * [ ] Automatic tag file generation
 * [ ] Support for using vscode cmake tool configuration files
 * [x] Support for editing IXM dict files
 * [ ] Support for converting IXM dict files to VimL Dictionaries

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
