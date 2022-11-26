To have these hooks work globally for all git repositories set
the git config core.hooksPath and then copy these scripts to the
set path, e.g.

```
sudo mkdir -p /etc/git/hooks
git config --global --add core.hooksPath /etc/git/hooks
sudo rsync -av /<dotfiles repo>/git-hooks/* /etc/git/hooks --exclude=README.md
```
