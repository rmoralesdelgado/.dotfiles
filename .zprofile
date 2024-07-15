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


## PYENV
#
# This section is used to add the shims path to $PATH
# This is necessary, as explained here https://github.com/pyenv/pyenv/issues/1906
#
printf '%s' "[.zprofile][pyenv] "
    if command -v pyenv 1>/dev/null 2>&1; then
        eval "$(pyenv init --path)" &&
        printf '%s\n' "Shims path added to PATH." ||
        printf '%s\n' "${RED}Failed to add shims path to PATH.${NORMAL}"
    else
        printf '%s\n' "${RED}Command not found.${NORMAL}"
    fi
#
# END OF PYENV


#### END OF ZPROFILE

