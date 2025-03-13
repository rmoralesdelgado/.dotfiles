#!/usr/bin/env zsh

# CONSOLIDATED ALIASES
# Source file with consolidated aliases


# Git for dotfiles repo
# (as proposed here: https://www.atlassian.com/git/tutorials/dotfiles)
if [[ -d ~/.dotfiles ]]; then
    alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
fi


# Luxeterna
# Keep computer alive
if (( $+commands[caffeinate] )); then
    alias luxeterna='caffeinate -dis'
fi


# Python
if (( $+commands[python] )); then
    alias pyv='python -c "import platform, sys; print(f"Current Python: version {platform.python_version()} at {sys.executable}")"'
fi


# Pyenv
# Get pure Python versions only
if (( $+commands[pyenv] )); then
    alias pyvs="pyenv install --list|grep -E '^\W+\d\.\d+\.\d+$'"
fi


# Eza
# Replacement for `ls`
if (( $+commands[eza] )); then
  typeset -ag eza_params

  eza_params=(
    '--long'  # -l
    '--all'  # -a
    '--header'  # -h 
    '--modified'  # -m
    '--octal-permissions'  # -o
    '--icons' 
    '--git' 
    '--time-style=+%Y-%m-%d %H:%M:%S'
    '--color=always'
    '--group-directories-first'
  )

  [[ ! -z $_EZA_PARAMS ]] && eza_params=($_EZA_PARAMS)

  alias ls='eza $eza_params'
  alias li='eza --git-ignore $eza_params'
  alias lm='eza --sort=modified $eza_params'
  alias lla='eza -lbhHigUmuSa'
  alias llx='eza -lbhHigUmuSa@'
  alias lt='eza --tree --level=4 --color=always --group-directories-first --icons'
  alias tree='eza --tree --level=4 --color=always --group-directories-first --icons'

else
  print "'eza' not installed; alias not loaded." >&2
  return 1
fi
