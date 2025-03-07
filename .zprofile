#! /usr/bin/env zsh

#### ZPROFILE
####
#### Made by Raul Morales Delgado


## SSH AGENT
#
# Starting the ssh-agent:
printf '%s' "[.zprofile][ssh-agent] "
#
# Creating function to run ssh-agent in sub-shell (notice "()" instead of "{}"):
run_ssh_agent () (

    # Creating function to add keys:
    add_key_to_ssh_agent () {
        # Create local placeholder for associative array:
        local tmp="$1"
        # Check if specific private key has already been added (notice "--" in grep command, this is because its expanding a variable; won't work without):
        if { ssh-add -l|grep -i -- "${(P)${tmp}[1]}" &> /dev/null ; } ; then
                printf '%s' "${(P)${tmp}[1]} private key already added. "
            else
                # Add key if not added yet:
                ssh-add "${(P)${tmp}[2]}" &>/dev/null && 
                printf '%s' "${(P)${tmp}[1]} private key successfully added. " || 
                printf '%s' "${RED} Failed to add private key for ${(P)${tmp}[1]}${NORMAL}. "
        fi
    }

    # Running ssh-add, error code tells status of ssh-agent:
    ssh-add -l &>/dev/null
    
    # Locally storing exit status:
    local ssh_agent_status=$?

    # Check if $?<=2 (2: not initialized; 1: initialized with no keys; 0: initialized with keys):
    if [[ "ssh_agent_status" -le 2 ]]; then
        # Check if $?=2, this means agent not initialized: 
        if [[ "ssh_agent_status" -eq 2 ]]; then
            eval "$(ssh-agent)" >/dev/null &&
            printf '%s' "Agent initialized. " ||
            { printf '%s\n' "${RED}Failed to initialize agent.${NORMAL}"; exit 1 ; }
        fi
        # Adding the Github private key to ssh-agent:
        for i in "$@"; do
            add_key_to_ssh_agent "$i"
        done
        printf '%s\n' ""
    fi
)
#
# Setting keys to be used:
github=('Github' "$HOME/.ssh/github_ecdsa")
#
# Run:
run_ssh_agent "github"
#
unset -f run_ssh_agent
unset github
# END OF SSH AGENT


## HOMEBREW

# Load Homebrew's env vars and binaries to PATH and Zsh completions to FPATH
# Docs: https://docs.brew.sh/Homebrew-on-MacOS
# This assumes Homebrew is already installed
# TODO: Update script to install Homebrew if not installed

brew_init () {
    printf '%s' "[.zprofile][brew] "
    if command -v brew &>/dev/null; then
        eval "$(/usr/local/bin/brew shellenv)" &&
        printf '%s\n' "Successfully initialized." ||
        printf '%s\n' "${RED}Failed to initialize.${NORMAL}"
    else
        printf '%s\n' "${RED}Command not found.${NORMAL}"
    fi
}

brew_init

# Unset function
unset -f brew_init

## END OF HOMEBREW


#### END OF ZPROFILE
