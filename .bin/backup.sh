#!bin/zsh

## Script to automate recurrent backups

## Syntax: backup <destination dir> <file or dir to backup> [, <file or dir to backup>]


backup() {

    local backup_destination="$1"

    # Checking if backup destination directory exists:
    if [ ! -d "${backup_destination}" ]; then
        echo "${backup_destination} is not a directory."
        return 1
    fi

    # Creating array to hold successful and unsuccessful backups:
    local successful_backups=() # Just backed up
    local ok_backups=() # Already backed up
    local failed_backups=() # Failed to back up

    # Skipping first argument (i.e. backup destination path):
    shift

    # Looping through remaining args (i.e. files to backup)
    for i in "$@"; do

        # Setting up local variables:
        local original_path="$i"
        local original_file="${original_path##*/}"
        local backup_file="${original_file}.bak"
        local backup_path="${backup_destination}/${backup_file}"

        # Checking if original file or dir exists:
        if [[ ! -e "${original_path}" ]]; then
            echo "[.zshrc] ${original_path} is not a file. Cannot backup."
            failed_backups+=( "${original_file}" )
            continue
        elif [[ -d "${original_path}" ]]; then
            if [[ -z $( ls -A "${original_path}" ) ]]; then
                echo "[.zshrc] ${original_path} is an empty dir. Cannot backup."
                failed_backups+=( "${original_file}" )
                continue
            fi
        fi

        # Backing up if original is newer than backup or if backup does not exist:
        if [[ ( "${original_path}" -nt "${backup_path}" ) \
        || ( ! -e "${backup_path}" ) ]]; then
            rsync -au --modify-window=5 "${original_path}" "${backup_path}" -q \
            && { successful_backups+=( "${original_file}" ); touch "${backup_path}"; } \
            || failed_backups+=( "${original_file}" )
        else
            ok_backups+=( "${original_file}" )
        fi

        done

    # Print backup summary:
    [ ${#} -gt 0 ] && echo "[.zshrc] Backup summary: Total=${#} (new=${#successful_backups[@]}; ok=${#ok_backups[@]}; failed=${#failed_backups[@]})"

    # Print failed backups:
    [ ${#failed_backups[@]} -gt 0 ] && echo "[.zshrc] Failed to back up: ${failed_backups[*]}."

    return 0
}

backup "$@"