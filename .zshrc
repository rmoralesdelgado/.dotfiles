#! /usr/bin/env zsh
#### ZSHRC
####
#### Made by Raul Morales Delgado


#### STYLE 

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

#### END OF STYLE



#### VCS (for dotfiles)

## INIT
#
# Git command to manage dotfiles (as proposed here: https://www.atlassian.com/git/tutorials/dotfiles):
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
## END OF INIT


#### END OF VCS



#### ENVIRONMENT

## LOCAL EXPORTS
#
# Add local directories with binaries to PATH and set contents as executable
#
local_exports () {
    printf '%s' "[.zshrc][local_exports] "
    local DIRS=('.local/bin' '.bin') # Add more here
    local SUCCESSES=()
    local FAILS=()
    local NOT_FOUNDS=()
    for i in $DIRS; do
        local ABS_PATH="$HOME/${i}"
        if [[ -d $ABS_PATH ]]; then
            export PATH="$ABS_PATH:$PATH" && 
            chmod +x $ABS_PATH/* &&
            SUCCESSES+=${i} ||
            FAILS+=${i}
        else
            NOT_FOUNDS+=${i}
        fi;
    done;
    if (( ${#SUCCESSES} > 0 )); then
        printf '%s' "Successfully added $(printf '[%s] ' "${SUCCESSES[@]}")to PATH."
    fi
    if (( ${#FAILS} > 0 )); then
        printf '%s' "${RED} Failed to add $(printf '[%s] ' "${FAILS[@]}")to PATH.${NORMAL}"
    fi
    if (( ${#NOT_FOUNDS} > 0 )); then
        printf '%s' "${RED} $(printf '[%s] ' "${NOT_FOUNDS[@]}")not found.${NORMAL}"
    fi
    printf '%s\n' "";
}
#
# Run function:
local_exports
# Unsetting function:
unset -f local_exports
#
# END OF LOCAL EXPORTS


## ALIASES & SHORTCUTS
#
# Get current Python version:
alias py="python -c 'import platform; print(platform.python_version())'"
# Keep computer alive:
alias luxeterna="caffeinate -dis"
# Pyenv: get only pure Python versions
alias pyenv-pythons="pyenv install --list|grep -E '^\W+\d\.\d+\.\d+$'"
# Git + FZF
alias gcb="git branch | fzf --preview 'git show --color=always {-1}' \
                            --bind 'enter:become(git checkout {-1})' \
                            --height 40% --layout reverse"
#
## END OF ALIASES & SHORTCUTS

#### END OF ENVIRONMENT



#### APPLICATIONS

## PYENV (AND PLUGINS)
#
# Docs pyenv: https://github.com/pyenv/pyenv
# Docs pyenv-virtualenv: https://github.com/pyenv/pyenv-virtualenv
#
# NOTE: The shims path is now being added in ~/.zprofile
# NOTE: Do not use oh-my-zsh pyenv plugin — it only activates pyenv and pyenv-virtualenv; it's not necessary for autocompletion
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


## ORBSTACK
#
# (Moved from ZPROFILE) Initialize Orbstack (i.e., add binaries to PATH and FPATH)
# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
#
# END OF ORBSTACK


## FZF (FuZzy Finder)
#
# Docs at https://junegunn.github.io/fzf/; installed via homebrew
#
fzf_init () {
    printf '%s' "[.zshrc][fzf] "
    if command -v fzf &> /dev/null; then
        source <(fzf --zsh) &&
        # Fix alt + C binding; originally -> ç
        bindkey "ç" fzf-cd-widget && 
        # Preview file content using bat
        export FZF_CTRL_T_OPTS="
            --walker-skip .git,node_modules,target
            --preview 'bat -n --color=always {}'
            --bind 'ctrl-/:change-preview-window(down|hidden|)'"
        # Print tree structure in the preview window
        export FZF_ALT_C_OPTS="
        --walker-skip .git,node_modules,target
        --preview 'tree -C {}'"
        printf '%s\n' "Successfully initialized." ||
        printf '%s\n' "${RED}Failed to initialize.${NORMAL}"
    else
        printf '%s\n' "${RED}Command not found.${NORMAL}"
    fi
}
#
# Initializing FZF:
fzf_init
# Unsetting fzf_init:
unset -f fzf_init


## BACKUPS
#
# Function to automatically backup certain config files:
BACKUP_DESTINATION="/Users/rmoralesdelgado/Documents/Omnis/9_extra_sync/backup"

source backup.sh "$BACKUP_DESTINATION" \
    "/Users/rmoralesdelgado/.ssh"
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

#### END OF APPLICATIONS



#### SHELL & PROMPT

## ZSH-COMPLETIONS
#
# Add brew-installed zsh-completions
#
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    # These (below) are not needed since they are ran via oh-my-zsh:
    
    # autoload -Uz compinit
    # compinit
fi


## OH-MY-ZSH
#
# Enabling oh-my-zsh via .oh-my-zsh.sh:
omz_init (){
    printf '%s' "[.zshrc][oh-my-zsh] "
    source ~/.oh-my-zsh-custom/.oh-my-zsh.sh &&
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


## STARSHIP (custom prompt)
#
# NOTE: Needs to be at the end of ZSHRC
# Initialize Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"
#
# END OF STARSHIP


### DEPRECATED
#
## SSH AGENT
#
# Moved to ZPROFILE since keys should only be added once.
#
# END OF SSH AGENT

## CONDA
#
# Conda now runs via pyenv. See available conda installations via "pyenv versions".
# 
# Conda is set to NOT be activated at launch. This config was set in ~/.condarc and meant to not interfere with pyenv as the main Python version manager using "conda config --set auto_activate_base false".
# (Source: https://stackoverflow.com/a/54560785/11905552)
#
# END OF CONDA

## POETRY (AND PLUGINS)
#
# Deprecation reason: Poetry is now installed via PIPX and there's no need to expose bin files. For more information on installation, run `pipx environment` and `pipx`
#
# Docs poetry: https://python-poetry.org/docs/
# Source poetry: https://github.com/python-poetry/poetry
#
# Initializing poetry if found:
#poetry_init () {
#    printf '%s' "[.zshrc][poetry] "
#    if [[ -d ~/.poetry/bin ]]; then
#        export PATH="$HOME/.poetry/bin:$PATH" &&
#        printf '%s\n' "Successfully added to PATH." ||
#        printf '%s\n' "${RED}Failed to be added to PATH.${NORMAL}"
#    else
#        printf '%s\n' "${RED}'~/.poetry/bin' not found.${NORMAL}"
#    fi
#}
#
# Initializing poetry:
#poetry_init
# Unsetting pipx_init:
# unset -f poetry_init
#
# END OF POETRY

#### END OF ZSHRC
