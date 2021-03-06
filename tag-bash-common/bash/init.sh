#!/usr/bin/env bash
#
# Load shared custom bash configurations

# {{{ Preparation
_BASE_DIR="${BASH_DIR:-${HOME}/.bash}"
_SCRIPTS="${BASH_SCRIPTS[@]}"
# }}}

# {{{ Helper functions
have() { command -v "$@" &>/dev/null; }

# Loads scripts/plugins and takes two arguments:
# - directory: The folder to load scripts from.
# - scripts: A space separated list of script names or "*" for all scripts in the folder.
load_scripts() {
    local directory="$1"
    [[ -d "${directory}" ]] && shift || return 1
    local extension="sh"
    local -a scripts

    if [[ -n "$@" ]]; then
        # Only load the files passed as arguments after $directory.
        while read -rd ' ' script || [[ -n "${script}" ]]; do
            scripts+=("${directory}/${script}.${extension}")
        done <<< "$@"
    else
        # Load all files in the given $directory, as long as they end with .$extension.
        scripts=(${directory}/*.$extension) # &>/dev/null
    fi

    for script in "${scripts[@]}"; do
        if [[ -r "${script}" ]]; then
            source "${script}"
        fi
    done
}
# }}}

main() {
    load_scripts "${_BASE_DIR}/scripts" "${_SCRIPTS[@]}"
    #have fasd && eval "$(fasd --init auto)"
    unset _BASE_DIR _SCRIPTS
}

main
