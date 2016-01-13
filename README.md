# dotfiles

Modular cross-platform multi-host configuration files managed with [rcm](https://github.com/thoughtbot/rcm).

## About
I use these dotfiles on all my machines running OSX, (Arch-)Linux and Windows 7/10 (w/ Cygwin64).
They are very vim-centric and try to use the solarized dark theme wherever possible.

## Quick intro to rcm

rcm is a management suite for dotfiles. It works by creating symlinks from a source folder (e.g. this repository) to your $HOME directory based on the configuration you provide.
The default source path is ~/.dotfiles and ~/.rcrc for the configuration file.
Here are some of the commonly used commands:  

Status information:
* `lsrc` (lists all files managed by rcm)
* `lsrc -d ~/company_dotfiles` (specify a non-default directory)

Installing and deleting symlinks/tags:
* `rcup -v` (create/update all symlinks for ~/.dotfiles (and be verbose about it))
* `rcup -d ~/company_dotfiles` (install from a non-default dotfile directory)
* `rcup -t zsh -t vim` (only install the vim and zsh configurations)
* The same commands work with `rcdn` to unlink/deinstall tags or whole repositories.  

Adding and deleting files:
* `mkrc FILE` (add FILE to ~/.dotfiles/FILE)
* `mkrc -t TAG FILE` (will add FILE to ~/.dotfiles/tag-TAG)
* `mkrc -U -o FILE` (will add FILE to ~/.dotfiles/host-$HOSTNAME and install it without a leading dot)

## Installation

### On ArchLinux

```bash
    cd $HOME &&
    clone https://aur.archlinux.org/rcm-git.git && cd rcm-git &&
    makepkg -i &&
    git clone --recursive git://github.com/mikar/dotfiles.git $HOME/.dotfiles &&
    ln -s $HOME/.dotfiles/host-w541/rcrc $HOME/.rcrc &&
    rcup -v
```

### On OSX

```bash
    cd $HOME &&
    brew tap thoughtbot/formulae &&
    brew install rcm &&
    git clone --recursive git://github.com/mikar/dotfiles.git $HOME/.dotfiles &&
    ln -s $HOME/.dotfiles/host-w541/rcrc $HOME/.rcrc &&
    rcup -v
```

### On Windows

Cygwin doesn't come with a rcm package so we'll have to build it.

```bash
    cd $HOME &&
    git clone --recursive git://github.com.com/thoughtbot/rcm.git && cd rcm &&
    ./autogen.sh &&
    ./configure &&
    make &&
    make install &&
    git clone --recursive git://github.com/mikar/dotfiles.git $HOME/.dotfiles &&
    ln -s $HOME/.dotfiles/host-w541/rcrc $HOME/.rcrc &&
    rcup -v
```

A note on symlinks:  
Please note that Cygwin creates "fake" symlinks by default which Windows cannot read. So, if, like me, you want to be able to use the dotfiles both in Cygwin and in normal Windows applications (e.g. git/ssh/gpg configs), you have two options:  
1) Use the `COPY_ALWAYS` option in .rcrc, for instance with the entry `COPY_ALWAYS="*"` to match every file.
2) Tell Cygwin to use native NTFS symlinks. To do that, you'll have to `export CYGWIN="winsymlinks:native"` before running `rcup`. There are two drawbacks to this method: a) This requires administrator rights (i.e. start the Cygwin terminal emulator with "Run as administrator" and b) it requires Windows Vista/2008 or later. Even then, native NTFS symlinks might behave strangely but this method is what works for me.  

A word on `$PATH`:
You  might want to remove Windows applications from `$PATH` that provide Windows versions of unix tools e.g. Git for Windows. The latter will autocrlf, for instance, which means Cygwin can't read files cloned with the Windows version of Git unless you `dos2unix` each file.

### Portable installation script

You can create a portable installation script (e.g. for machines where you don't want to or can't install rcm) like this:

```bash
    rcup -B 0 -g -K > install.sh
```

## Customization

You can make your own customizations by adding `.local`files.
They will take precedence over their counterparts as they are loaded last.
For instance, to extend `.zshrc` you can make your changes in `.zshrc.local`.

To extend your `git` hooks, create executable scripts in
`~/.git_template.local/hooks/*` files.

Additional zsh configuration can go under the `~/.zsh/configs` directory. This
has two special subdirectories: `pre` for files that must be loaded first, and
`post` for files that must be loaded last.

## Features

[vim](http://www.vim.org/) configuration:

* [Ctrl-P](https://github.com/kien/ctrlp.vim) for fuzzy file/buffer/tag finding.
* Set `<leader>` to a single space.
* Switch between the last two files with space-space.
* Syntax highlighting for CoffeeScript, Textile, Cucumber, Haml, Markdown, and
  HTML.
* Use [vim-mkdir](https://github.com/pbrisbin/vim-mkdir) for automatically
  creating non-existing directories before writing the buffer.
* Use [vim-plug](https://github.com/junegunn/vim-plug) to manage plugins.

[tmux](http://robots.thoughtbot.com/a-tmux-crash-course) configuration:

* Improve color resolution.
* Remove administrative debris (session name, hostname, time) in status bar.
* Set prefix to `Ctrl+Space`
* Soften status bar color from harsh green to light gray.

[git](http://git-scm.com/) configuration:

* Adds a `create-branch` alias to create feature branches.
* Adds a `delete-branch` alias to delete feature branches.
* Adds a `merge-branch` alias to merge feature branches into master.
* Adds an `up` alias to fetch and rebase `origin/master` into the feature
  branch. Use `git up -i` for interactive rebases.
* Adds `post-{checkout,commit,merge}` hooks to re-index your ctags.
* Adds `pre-commit` and `prepare-commit-msg` stubs that delegate to your local
  config.

Shell aliases and scripts:

* `b` for `bundle`.
* `g` with no arguments is `hub status` and with arguments acts like `hub`.
* `git-churn` to show churn for the files changed in the branch.
* `mcd` to make a directory and change into it.
* `tat` to attach to tmux session named the same as the current directory.
* `v` for `$VISUAL`.

