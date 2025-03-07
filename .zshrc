#! /usr/bin/env zsh
#### ZSHRC
#### Made by Raul Morales Delgado
#### Based mildly on https://github.com/dreamsofautonomy/zensh/blob/main/.zshrc


#### ENVIRONMENT

## GENERAL EXPORTS

export CONFIG_DIR="${HOME}/.config"  # Config files
export INSTALLS_DIR="${HOME}/.installs"  # Install scripts
export LOCAL_COMPS_DIR="${HOME}/.zfunc"  # Manual made completions

## END OF GENERAL EXPORTS


## ZINIT (ZSH plugin manager)

# Set directory to store Zinit source code and local completions
export ZINIT_DIR="${HOME}/.local/share/zinit"
export ZINIT_HOME="${ZINIT_DIR}/zinit.git"

# Download Zinit if not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
#
# Source and load Zinit
source "${ZINIT_HOME}/zinit.zsh"
#
# Autoload ZSH modules and initialize completions
autoload -Uz compinit && compinit

# INSTALL CORE ZINIT ANNEXES

# IMPORTANT NOTE: On ices resolution order (from observation; not all possibilities incl)
# atclone -> atinit -> pick -> src -> atload. atpull runs individually (i.e., no atinit, no src...)

# Annex to not modify PATH when installing binaries; uses $ZPFX
zinit light zdharma-continuum/z-a-bin-gem-node

# INSTALL APPS AND BINARIES VIA ZINIT
zinit ice wait lucid from"gh-r" as"null" sbin"fzf" \
    atclone"./fzf --zsh > init.zsh" \
    atpull"%atclone" \
    src"init.zsh" \
    atload"source ${CONFIG_DIR}/fzf/config.zsh"
zinit light junegunn/fzf

zinit wait"1" lucid from"gh-r" as"null" for \
  sbin"**/bat" completions \
    atclone"**/bat --completion zsh > _bat; **/bat cache --build" \
    atpull"%atclone" \
    atload"export BAT_CONFIG_DIR=${CONFIG_DIR}/bat" \
    @sharkdp/bat  # Modern version of `cat`
  # sbin"**/eza" eza-community/eza -- DARWIN BINARY NOT AVAILABLE ATM

export EZA_CONFIG_DIR="${CONFIG_DIR}/eza"  # TODO: Add to Zinit loading of eza when ready

# Load Starship software with local theme
# line 1: beginning of ice cmds: fetch from github release, sbin to add binary as shim 
# line 1 NOTE: not using as"program" because it only adds path to PATH; used sbin to avoid it
# line 2: set starship instructions right after cloning (create init.zsh, add completion)
# line 3: repeat atclone instructions in atpull (atpull happens when updating)
# line 4: use atload to export starship config file and make it available
# line 5: source init.zsh
zinit ice from"gh-r" sbin"starship" \
    atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
    atpull"%atclone" \
    atload"export STARSHIP_CONFIG=${CONFIG_DIR}/starship/starship.toml" \
    src"init.zsh"
zinit light starship/starship

# Light-load zsh plugins
# Based on https://zdharma-continuum.github.io/zinit/wiki/Example-Minimal-Setup/
zinit wait'1' lucid light-mode for \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    has"fzf" \
        Aloxaf/fzf-tab
    

# LOAD COMPLETIONS
# Load local completions
_zinit_load_local_completions () {
    if [[ -n "$(ls -A $LOCAL_COMPS_DIR)" ]]; then
        for file in $LOCAL_COMPS_DIR/*(.); do
            zinit ice as"completion"
            zinit snippet $file
        done
    else
        echo "Local completions directory is empty"
    fi
}
_zinit_load_local_completions

# IMPORTANT NOTE: This is a patch to fix the following error:
# Zinit does not append the bin dir ($ZPFX) to PATH upon installation (i.e., 1st run);
# it does work on the second run and onwards, though.
source "${ZINIT_HOME}/zinit.zsh"

# Run Zinit compdef replay quietly
zinit cdreplay -q

## END OF ZINIT


## Z-STYLE
# Based on https://github.com/Aloxaf/fzf-tab

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 -a --icons --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

## END OF Z-STYLE


## HISTORY
# Setup history params
HISTSIZE=9999
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory  # Append to the history file
setopt sharehistory  # Share history across terminals
setopt hist_ignore_space  # Ignore commands that start with a space
setopt hist_ignore_all_dups  # Ignore duplicate commands
setopt hist_save_no_dups  # Don't save duplicate commands
setopt hist_ignore_dups  # Ignore duplicate entries
setopt hist_find_no_dups  # Ignore duplicate entries
setopt hist_reduce_blanks  # Remove superfluous blanks

## END OF HISTORY


## LOCAL DIR EXPORTS
# Add local directories with binaries to PATH and set contents as executable

local_dir_exports () {
    printf '%s' "[.zshrc][local_dir_exports] "
    local DIRS=("${HOME}/.local/bin" "${HOME}/.bin") # Add more here
    local SUCCESSES=()
    local FAILS=()
    local NOT_FOUNDS=()
    for i in $DIRS; do
        local ABS_PATH="${i}"
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

# Run function:
local_dir_exports
# Unsetting function:
unset -f local_dir_exports

## END OF LOCAL EXPORTS


## ALIASES & SHORTCUTS

# Alias for Git command to manage dotfiles 
# (as proposed here: https://www.atlassian.com/git/tutorials/dotfiles)
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
# Keep computer alive
alias luxeterna="caffeinate -dis"
# Get current Python version
alias py="python -c 'import platform; print(platform.python_version())'"
# Pyenv: get only pure Python versions
alias pyenv-pythons="pyenv install --list|grep -E '^\W+\d\.\d+\.\d+$'"
# Git + FZF
alias gcb="git branch | fzf --preview 'git show --color=always {-1}' \
                            --bind 'enter:become(git checkout {-1})' \
                            --height 40% --layout reverse"

## END OF ALIASES & SHORTCUTS

#### END OF ENVIRONMENT



#### APPLICATIONS LOADING

## PYENV (AND PLUGINS)
# Docs pyenv: https://github.com/pyenv/pyenv
# Docs pyenv-virtualenv: https://github.com/pyenv/pyenv-virtualenv
# NOTE: The eval command adds shims to PATH and initializes pyenv

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

# To only add shims to PATH: 'export PATH="$(pyenv root)/shims":$PATH'

# Additional setup to ensure successful compilation when installing new Python versions via pyenv: 
# (from: https://github.com/pyenv/pyenv/wiki/Common-build-problems#error-the-python-ssl-extension-was-not-compiled-missing-the-openssl-lib)
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
## END OF PYENV


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

unset BACKUP_DESTINATION
#
# END OF BACKUPS

#### END OF APPLICATIONS



#### SHELL & PROMPT

## ADDITIONAL ZSH-COMPLETIONS
# Some apps installed via brew or pipx require completions to be added manually.
# This function updates them.
# TODO: Integrate this function with a general installation process for all apps

# Function to manually update ZSH shell completions
update_zsh_completions () {
    local SUCCESSES=()
    local FAILS=()
    local NOT_FOUNDS=()
    
    printf '%s' "[.zshrc][update_zsh_completions] "

    if (( $+commands[ruff] )); then
        ruff generate-shell-completion zsh > ${LOCAL_COMPS_DIR}/_ruff &&
        SUCCESSES+='ruff' ||
        FAILS+=ruff
    else
        NOT_FOUNDS+='ruff'
    fi

    if (( $+commands[poetry] )); then
        poetry completions zsh > ${LOCAL_COMPS_DIR}/_poetry &&
        SUCCESSES+='poetry' ||
        FAILS+='poetry'
    else
        NOT_FOUNDS+='poetry'
    fi

    if (( $+commands[snow] )); then
        snow --show-completion > ${LOCAL_COMPS_DIR}/_snow &&
        SUCCESSES+='snow' ||
        FAILS+='snow'
    else
        NOT_FOUNDS+='snow'
    fi

    if (( $+commands[orbctl] )); then
        orbctl completion zsh > ${LOCAL_COMPS_DIR}/_orbctl &&
        compdef _orbctl orb orbctl &&
        SUCCESSES+='orb/orbctl' ||
        FAILS+='orb/orbctl'
    else
        NOT_FOUNDS+='orb/orbctl'
    fi
    # Add more fns here...

    # Load manual completions with Zinit
    _zinit_load_local_completions && zinit cdreplay -q
    
    # Count and report
    if (( ${#SUCCESSES} > 0 )); then
        printf '%s' "Successfully updated completions for $(printf '[%s] ' "${SUCCESSES[@]}")."
    fi
    if (( ${#FAILS} > 0 )); then
        printf '%s' "${RED} Failed to update completions for $(printf '[%s] ' "${FAILS[@]}").${NORMAL}"
    fi
    if (( ${#NOT_FOUNDS} > 0 )); then
        printf '%s' "${RED} $(printf '[%s] ' "${NOT_FOUNDS[@]}")commands not found. Completions not updated.${NORMAL}"
    fi
    printf '%s\n' "";
}
#
## END OF ADDITIONAL COMPLETIONS


#### END OF ZSHRC
