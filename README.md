# ripgrep.vim

[![Test](https://github.com/kyoh86/vim-ripgrep/actions/workflows/test.yml/badge.svg)](https://github.com/kyoh86/vim-ripgrep/actions/workflows/test.yml)

A plugin for Vim8/Neovim to search text by `ripgrep` (`rg`).

**THIS IS EXPERIMENTAL PLUGIN AND UNDER DEVELOPMENT.**
**DESTRUCTIVE CHANGES MAY OCCUR.**

## What's different from [`jremmen/vim-ripgrep`](https://github.com/jremmen/vim-ripgrep)?

- Calling `ripgrep` asynchronously.
    - Even if it finds a lot of matches, editor won't freeze.
    - Exception in case of `Neovim` on `Windows`.
- There's no default command.
    - You can create a command with name what you like.
- Observability.
    - You can add observer for each event in searching process.

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
command! -nargs=+ -complete=file Ripgrep :call ripgrep#search(<q-args>)
```

# LICENSE

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg)](http://www.opensource.org/licenses/MIT)

This software is released under the [MIT License](http://www.opensource.org/licenses/MIT), see LICENSE.

- `autoload/ripgrep/job.vim` is from [`async.vim`](https://github.com/prabirshrestha/async.vim) and some patch.

