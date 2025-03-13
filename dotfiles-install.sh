#! /usr/bin/env bash

git clone --bare https://github.com/rmoralesdelgado/.dotfiles.git $HOME/.dotfiles

# Temp function to operate on the dotfiles repo using Git
function _config {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}

# Backup pre-existing dot files (e.g., .bash_profile) and checkout main branch of dotfiles
mkdir -p .config-backup
_config checkout main
if [ $? = 0 ]; then
    echo "Checked out config.";
else
    echo "Backing up pre-existing dot files.";
    _config checkout main 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
    _config checkout main
fi;

_config config status.showUntrackedFiles no