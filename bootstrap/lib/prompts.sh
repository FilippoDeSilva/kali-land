#!/bin/bash
# prompts.sh - User interaction and confirmation utilities

# Prevent re-sourcing
[ -n "${PROMPTS_SH_SOURCED:-}" ] && return 0
readonly PROMPTS_SH_SOURCED=1

# Source logging
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LIB_DIR}/logging.sh"

# Colors for prompts (use same color support as logging)
if ${SUPPORTS_COLOR:-false}; then
    COLOR_PROMPT='\033[0;36m'
    COLOR_CONFIRM='\033[0;32m'
    COLOR_CANCEL='\033[0;31m'
else
    COLOR_PROMPT=''
    COLOR_CONFIRM=''
    COLOR_CANCEL=''
fi

# confirm() - Ask for user confirmation
# Usage: confirm <message> [default]
# Returns: 0 for yes, 1 for no
confirm() {
    local message=$1
    local default=${2:-n}
    local prompt
    local response
    
    # Set prompt based on default
    if [ "${default}" = "y" ]; then
        prompt="${COLOR_PROMPT}${message} [Y/n]${COLOR_RESET} "
    else
        prompt="${COLOR_PROMPT}${message} [y/N]${COLOR_RESET} "
    fi
    
    # Read response
    # Use printf with -e to properly handle escape sequences
    printf "%b" "${prompt}"
    read response
    
    # Handle empty response (use default)
    if [ -z "${response}" ]; then
        response="${default}"
    fi
    
    # Check response
    case "${response,,}" in
        y|yes) return 0 ;;
        n|no) return 1 ;;
        *) return 1 ;;
    esac
}

# prompt() - Ask for user input
# Usage: prompt <message> [default]
prompt() {
    local message=$1
    local default=${2:-}
    local response
    
    if [ -n "${default}" ]; then
        printf "%b" "${COLOR_PROMPT}${message} [${default}]:${COLOR_RESET} "
        read response
        [ -z "${response}" ] && response="${default}"
    else
        printf "%b" "${COLOR_PROMPT}${message}:${COLOR_RESET} "
        read response
    fi
    
    echo "${response}"
}

# select_option() - Select from a list of options
# Usage: select_option <message> <option1> <option2> ...
select_option() {
    local message=$1
    shift
    local options=("$@")
    
    printf "%b\n" "${COLOR_PROMPT}${message}${COLOR_RESET}"
    
    local i=1
    for option in "${options[@]}"; do
        echo "  ${i}) ${option}"
        i=$((i + 1))
    done
    
    local choice
    printf "%b" "${COLOR_PROMPT}Select [1-${#options[@]}]:${COLOR_RESET} "
    read choice
    
    # Validate choice
    if [[ ! "${choice}" =~ ^[0-9]+$ ]] || [ "${choice}" -lt 1 ] || [ "${choice}" -gt ${#options[@]} ]; then
        log_error "Invalid choice"
        return 1
    fi
    
    echo "${options[$((choice - 1))]}"
}

# confirm_destructive() - Confirm destructive operation
# Usage: confirm_destructive <operation> <target>
confirm_destructive() {
    local operation=$1
    local target=$2
    
    log_warn "You are about to perform a destructive operation:"
    log_warn "  Operation: ${operation}"
    log_warn "  Target: ${target}"
    log_warn ""
    
    if confirm "Do you want to continue?" "n"; then
        return 0
    else
        log_info "Operation cancelled by user"
        return 1
    fi
}

# show_menu() - Show a menu and return selection
# Usage: show_menu <title> <option1> <option2> ...
show_menu() {
    local title=$1
    shift
    local options=("$@")
    
    clear
    echo "=== ${title} ==="
    echo ""
    
    local i=1
    for option in "${options[@]}"; do
        echo "  ${i}) ${option}"
        i=$((i + 1))
    done
    
    echo ""
    local choice
    printf "Select [1-${#options[@]}]: "
    read choice
    
    # Validate choice
    if [[ ! "${choice}" =~ ^[0-9]+$ ]] || [ "${choice}" -lt 1 ] || [ "${choice}" -gt ${#options[@]} ]; then
        log_error "Invalid choice"
        return 1
    fi
    
    return $((choice - 1))
}

# progress_bar() - Show a simple progress bar
# Usage: progress_bar <current> <total> <width>
progress_bar() {
    local current=$1
    local total=$2
    local width=${3:-40}
    
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    printf "\r["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' ' '
    printf "] %d%%" "${percent}"
}

# spinner() - Show a spinner during long operations
# Usage: spinner <pid> <message>
spinner() {
    local pid=$1
    local message=$2
    local delay=0.1
    local spinstr='|/-\'
    
    while kill -0 "${pid}" &>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c] %s" "${spinstr}" "${message}"
        spinstr=${temp}${spinstr%"${temp}"}
        sleep "${delay}"
        printf "\r"
    done
    
    printf "   \r"
}
