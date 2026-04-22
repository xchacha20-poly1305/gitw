# Install

```shell
INSTALL_DIR="$(pwd)" # Or where you want

git clone https://github.com/xchacha20-poly1305/gitw.git "$INSTALL_DIR/gitw"
echo "alias gitw=\"$INSTALL_DIR/gitw/gitw.sh\"" >> ~/.profile
```

# Usage

```shell
$ gitw help
gitw.sh <command> [options]

commands:
    help                show this message
    add                 add all file to git
    commits             git commit -s
    commita             git commit --amend
    sync                force sync remote
    clean               clean git reflog
    squash [HEAD]       squash some commits
    now                 Show now HEAD
    pick [HEAD]         auto pick commit
    cleanb              Clean the branches that remotes not have
    reword [HEAD]       Rewrite commit message (git history reword)

options:
    options for git

HEAD:
    git header, like HEAD^ or commit hash
```