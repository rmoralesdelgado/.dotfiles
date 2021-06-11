#! /usr/bin/env zsh
#### ZSHRC
####
#### Made by Raul Morales Delgado


### ACTIVE

## FORMATTING
#
# From https://stackoverflow.com/a/4332530
#
# Definitions:
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
NORMAL=$(tput sgr0)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)


## INIT
# Git command to manage dotfiles (as proposed here: https://www.atlassian.com/git/tutorials/dotfiles):
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
## END OF INIT


## PYENV (AND PLUGINS)
#
# Docs pyenv: https://github.com/pyenv/pyenv
# Docs pyenv-virtualenv: https://github.com/pyenv/pyenv-virtualenv
#
pyenv_init () {
    printf '%s' "[.zshrc][pyenv] "
    if command -v pyenv 1>/dev/null 2>&1; then
        eval "$(pyenv init -)" &&
        printf '%s\n' "Successfully initialized." ||
        printf '%s\n' "${RED}Failed to initialize.${NORMAL}"
    else
        printf '%s\n' "${RED}Command not found.${NORMAL}"
    fi
}
#
# To only add shims to PATH: 
# export PATH="$(pyenv root)/shims:$PATH"
#
# Additional setup to ensure successful compilation when installing new Python versions via pyenv: (from: https://github.com/pyenv/pyenv/wiki/Common-build-problems#error-the-python-ssl-extension-was-not-compiled-missing-the-openssl-lib)
export CFLAGS="-I$(brew --prefix openssl)/include"
export LDFLAGS="-L$(brew --prefix openssl)/lib"
#
# Initializing pyenv-virtualenv plugin:
pyenv_ve_init () {
    # Function that initializes pyenv-virtualenv
    _pyenv_ve_init () {
        eval "$(pyenv virtualenv-init -)" &&
        printf '%s\n' "Successfully initialized." ||
        printf '%s\n' "${RED} Failed to initialize.${NORMAL}"
    }

    printf '%s' "[.zshrc][pyenv-virtualenv] "
    # Checking of command is in PATH:
    if [[ $(command -v pyenv-virtualenv) && \
        $(command -v pyenv-virtualenv-init) ]]; then
        # Cases 
        case $1 in
            --manual) # Case to activate manually
                printf '%s\n' "${RED}Not initialized.${NORMAL} To initialize, run 'pyenv_ve_init --auto'.";;
            --auto) # Case to activate automatically
                _pyenv_ve_init;;
            *) # For all other cases
                printf '%s\n' "${RED}Argument not recognized.${NORMAL}";;
        esac
    else
        printf '%s\n' "${RED}Command not found.${NORMAL}"
    fi

    # Unsetting to not clog autocompletions:
    unset -f _pyenv_ve_init
}
#
# Initializing pyenv:
pyenv_init
# Unsetting pyenv_init:
unset -f pyenv_init
# Initializing pyenv-virtuallenv:
pyenv_ve_init --manual
# END OF PYENV


## PIPX (AND PLUGINS)
#
# Docs poetry: https://python-poetry.org/docs/
# Source poetry: https://github.com/python-poetry/poetry
#
# Initializing pipx if found:
pipx_init () {
    printf '%s' "[.zshrc][pipx] "
    if [[ -d ~/.local/bin ]]; then
        export PATH="$HOME/.local/bin:$PATH" && 
        printf '%s\n' "Successfully added to PATH." ||
        printf '%s\n' "${RED} Failed to be added to PATH.${NORMAL}"
    else
        printf '%s\n' "${RED}'~/.local/bin' not found.${NORMAL}"
    fi
}
#
# Initializing pipx:
pipx_init
# Unsetting pipx_init:
unset -f pipx_init
#
# END OF PIPX


## POETRY (AND PLUGINS)
#
# Docs poetry: https://python-poetry.org/docs/
# Source poetry: https://github.com/python-poetry/poetry
#
# Initializing poetry if found:
poetry_init () {
    printf '%s' "[.zshrc][poetry] "
    if [[ -d ~/.poetry/bin ]]; then
        export PATH="$HOME/.poetry/bin:$PATH" &&
        printf '%s\n' "Successfully added to PATH." ||
        printf '%s\n' "${RED}Failed to be added to PATH.${NORMAL}"
    else
        printf '%s\n' "${RED}'~/.poetry/bin' not found.${NORMAL}"
    fi
}
#
# Initializing poetry:
poetry_init
# Unsetting pipx_init:
unset -f poetry_init
#
# END OF POETRY


## OH-MY-ZSH
#
# Enabling oh-my-zsh via .oh-my-zsh.sh:
omz_init (){
    printf '%s' "[.zshrc][oh-my-zsh] "
    source ~/.oh-my-zsh.sh &&
    printf '%s\n' "Successfully initialized." ||
    printf '%s\n' "${RED}Failed to initialize.${NORMAL}"
}
#
# Initializing oh-my-zsh
omz_init
# Unsetting omz_init
unset -f omz_init
#
# END OF OH-MY-ZSH


## PATH APPENDS AND EXECUTABLES ENABLING
#
# Adding path for bin folder in Documents to the PATH:
export PATH="$PATH:/Users/rmoralesdelgado/.bin"
chmod +x /Users/rmoralesdelgado/.bin/*
#
# Adding path for keys folder in Documents to the PATH
# export PATH="$PATH:/Users/rmoralesdelgado/keys"


## ALIASES & SHORTCUTS
#

# Get current Python version:
alias py="python -c 'import platform; print(platform.python_version())'"
# Keep computer alive:
alias luxeterna="caffeinate -dis"
# Shortcut to sandbox:
SANDY="/Users/rmoralesdelgado/Documents/Omnis/4 Work/04 WIP/sandbox"
## END OF ALIASES & SHORTCUTS


## BACKUPS
#
# Function to automatically backup certain config files:
BACKUP_DESTINATION="/Users/rmoralesdelgado/Documents/Omnis/9 Sync/backup"

source backup.sh "$BACKUP_DESTINATION" \
    "/Users/rmoralesdelgado/.zshrc" \
    "/Users/rmoralesdelgado/.oh-my-zsh.sh" \
    "/Users/rmoralesdelgado/.oh-my-zsh/custom" \
    "/Users/rmoralesdelgado/.bin" \
    "/Users/rmoralesdelgado/.ssh" \
#    "/Users/rmoralesdelgado/keys" \
#
# Creating a backup copy of brew's installed pkgs if older than 30 days:
if [[ $( find "${BACKUP_DESTINATION}/brew-installed-pkgs.txt" -mtime -10d ) ]];then
    echo "[.zshrc] Homebrew installed pkgs backup list is up to date (< 10 days old)."
else
    brew list --formula > "${BACKUP_DESTINATION}/brew-installed-pkgs.txt" &&
    echo "[.zshrc] Homebrew installed pkgs list successfully backed up."
fi
#
# END OF BACKUPS


## SSH AGENT
#
# Adding the Github private key to ssh-agent:
if { ssh-add -l | grep "Git[Hh]ub" &> /dev/null ; } ; then
    echo "[.zshrc][ssh-agent] Github private key for rmoralesdelgado already added."
else 
    ssh-add ~/.ssh/github_ecdsa && echo "[.zshrc][ssh-agent] Github private key for rmoralesdelgado successfully added." || echo "[.zshrc][ssh-agent] Failed to add Github private key for rmoralesdelgado."
fi
#
# END OF SSH AGENT



### DEPRECATED

## CONDA
#
# Conda now runs via pyenv. See available conda installations via "pyenv versions".
# 
# Conda is set to NOT be activated at launch. This config was set in ~/.condarc and meant to not interfere with pyenv as the main Python version manager using "conda config --set auto_activate_base false".
# (Source: https://stackoverflow.com/a/54560785/11905552)
#
# END OF CONDA

#### END OF ZSHRC
