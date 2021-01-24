# dotfiles

Configuration files for my linux/unix computers. Most of these are named '.XXX', commonly referred to as dotfiles.

## Usage

* Add file(s) and/or directories to commit: `dotfiles add some-file-or-dir`

* Add all modified/deleted to commit: `dotfiles add -u`

* Add submodule to commit: `dotfiles submodule add https://github.com/USER/REPO LOCAL-DIR`

* Commit changes to local repo with msg: `dotfiles commit -m "comment"`

* Push local repo changes to github: `dotfiles push`

### Updating Submodules

```
dotfiles submodule update --remote --merge
dotfiles commit
```

See the following pages for more info/usage:

* https://www.atlassian.com/git/tutorials/dotfiles

* https://martijnvos.dev/using-a-bare-git-repository-to-store-linux-dotfiles/

* https://www.ackama.com/blog/posts/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained

## License

_Note, some files included in this repository are licensed under different terms by their authors/creators. In all other cases the following license shall apply:_

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>
