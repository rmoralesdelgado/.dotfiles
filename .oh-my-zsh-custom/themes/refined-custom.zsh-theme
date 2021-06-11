#!/usr/bin/env zsh

# ------------------------------------------------------------------------------
#
# Pure - A minimal and beautiful theme for oh-my-zsh
#
# Based on the custom Zsh-prompt of the same name by Sindre Sorhus. A huge
# thanks goes out to him for designing the fantastic Pure prompt in the first
# place! I'd also like to thank Julien Nicoulaud for his "nicoulaj" theme from
# which I've borrowed both some ideas and some actual code. You can find out
# more about both of these fantastic two people here:
#
# Sindre Sorhus
#   Github:   https://github.com/sindresorhus
#   Twitter:  https://twitter.com/sindresorhus
#
# Julien Nicoulaud
#   Github:   https://github.com/nicoulaj
#   Twitter:  https://twitter.com/nicoulaj
#
# ------------------------------------------------------------------------------

# Set required options
#
setopt prompt_subst

# Load required modules
#
autoload -Uz vcs_info

# Load colors
autoload -U colors && colors 

# Set vcs_info parameters
#
zstyle ':vcs_info:*' enable git # hg (Mercurial) and bzr (Bazaar) were left out
zstyle ':vcs_info:*:*' unstagedstr '!'
zstyle ':vcs_info:*:*' stagedstr '+'
zstyle ':vcs_info:*:*' formats "%n@${HOST%.*} $FX[bold]%r$FX[no-bold]/%S" "%s/%b" "%%u%c"
zstyle ':vcs_info:*:*' actionformats "%n@${HOST%.*} $FX[bold]%r$FX[no-bold]/%S" "%s/%b" "%u%c (%a)"
zstyle ':vcs_info:*:*' nvcsformats "%n@%m %~" "" ""

# Fastest possible way to check if repo is dirty
#
git_dirty() {
    # Check if we're in a git repo
    command git rev-parse --is-inside-work-tree &>/dev/null || return
    # Check if it's dirty
    command git diff --quiet --ignore-submodules HEAD &>/dev/null; [ $? -eq 1 ] && echo "*"
}

# Display information about the current repository
#
repo_information() {
    echo "%F{blue}${vcs_info_msg_0_%%/.} %F{8}$vcs_info_msg_1_`git_dirty` $vcs_info_msg_2_%f"
}

# Python info:
#
py_info() {
  local _py_version _py_short _pyenv_bin _marker
  _py_version="$(pyenv version)"
  # Find if current pyenv version is *conda-like: 
  if [[ $_py_version = *"conda"* ]]; then
    _py_short=' via conda';
  else
    _py_short=${_py_version%%[[:blank:]]*};
  fi
  # Look for *conda*/bin in $PATH for possible Python path conflict (/condabin is ok)
  grep -Ev 'conda[^:]*?\/bin:' &> /dev/null <<< "$PATH" \
    && _marker='%K{221}' \
    || _marker='%K{red}'
  echo "%{$_marker%}%F{0} py${_py_short} %f%k"
}

# Displays the exec time of the last command if set threshold was exceeded
#
cmd_exec_time() {
    local stop=`date +%s`
    local start=${cmd_timestamp:-$stop}
    let local elapsed=$stop-$start
    [ $elapsed -gt 5 ] && echo ${elapsed}s
}

# Get the initial timestamp for cmd_exec_time
#
preexec() {
    cmd_timestamp=`date +%s`
}

# Output additional information about paths, repos and exec time
#
precmd() {
    vcs_info # Get version control info before we start outputting stuff
    print -P "\n$(repo_information) %F{yellow}$(cmd_exec_time)%f $(py_info)"
    unset cmd_timestamp #Reset cmd exec time.
}

# Define prompts
#
PROMPT="%(?.%F{yellow}.%F{red})❯%f " # Display a red prompt char on failure
RPROMPT="%F{8}${SSH_TTY:+%n@%m}%f %(?.%F{yellow}.%F{red})%D{%H:%M:%S.%.}%f"    # Display username if connected via SSH

# ------------------------------------------------------------------------------
#
# List of vcs_info format strings:
#
# %b => current branch
# %a => current action (rebase/merge)
# %s => current version control system
# %r => name of the root directory of the repository
# %S => current path relative to the repository root directory
# %m => in case of Git, show information about stashes
# %u => show unstaged changes in the repository
# %c => show staged changes in the repository
#
# List of prompt format strings:
#
# prompt:
# %F => color dict
# %f => reset color
# %~ => current path
# %* => time
# %n => username
# %m => shortname host
# %(?..) => prompt conditional - %(condition.true.false)
#
# ------------------------------------------------------------------------------
