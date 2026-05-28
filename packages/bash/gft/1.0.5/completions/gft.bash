# Bash completion for gft
# Source this file or install to /usr/share/bash-completion/completions/gft

_gft() {
    local cur prev opts cmds
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    opts="--help --version --check-update --upgrade --assets --detect --get --install --releases --list --notes --json --quiet --pre --prerelease --source --checksum --verify --open --no-color --no-cache --clear-cache"
    cmds="update delete uninstall stash"

    case "$prev" in
        --get)
            # No completion for pattern argument
            return 0
            ;;
        --source)
            COMPREPLY=($(compgen -W "zip tar" -- "$cur"))
            return 0
            ;;
        stash)
            COMPREPLY=($(compgen -W "list ls show diff drop rm clean clear" -- "$cur"))
            return 0
            ;;
    esac

    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "$opts" -- "$cur"))
        return 0
    fi

    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=($(compgen -W "$cmds" -- "$cur"))
        return 0
    fi
}

complete -F _gft gft
complete -F _gft gfv
