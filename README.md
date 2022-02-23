# ripgrep.vim

**This is ALPHA version plugin.**

A plugin for vim8/neovim to search text by `ripgrep` (`rg`).

# USAGE

For more details: `:help ripgrep.txt`

## FUNCTION

```vim
:call ripgrep#search('-w --ignore-case foo')
```

## CONFIG

You can create a command to call the function with a name you like.
For example:

```vim
Plug "kyoh86/vim-ripgrep",
command! -nargs=* -complete=file Ripgrep :call ripgrep#search(<q-args>)
```

# LICENSE

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg)](http://www.opensource.org/licenses/MIT)

This software is released under the [MIT License](http://www.opensource.org/licenses/MIT), see LICENSE.

- `autoload/ripgrep/job.vim` is from [async.vim](https://github.com/prabirshrestha/async.vim) and some patch.
