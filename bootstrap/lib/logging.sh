#!/bin/bash
# logging.sh - Logging utilities for bootstrap scripts

# Prevent re-sourcing
[ -n "${LOGGING_SH_SOURCED:-}" ] && return 0
readonly LOGGING_SH_SOURCED=1

# Log directory
LOG_DIR="${HOME}/.local/state/kali-land/logs"
LOG_FILE="${LOG_DIR}/$(date +%Y-%m-%dT%H-%M-%S).log"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Log levels
LOG_DEBUG=0
LOG_INFO=1
LOG_WARN=2
LOG_ERROR=3
LOG_CURRENT_LEVEL=${LOG_INFO}

# Check if terminal supports colors
# Note: Running with sudo can affect terminal detection, so we check both stdout and stderr
if [ -t 1 ] || [ -t 2 ]; then
    colors=$(tput colors 2>/dev/null || echo 0)
    if [ "${colors}" -ge 8 ]; then
        SUPPORTS_COLOR=true
    else
        SUPPORTS_COLOR=false
    fi
else
    SUPPORTS_COLOR=false
fi

# Fallback: if tput failed but we have a terminal, assume color support
if [ "${SUPPORTS_COLOR}" = "false" ] && ([ -t 1 ] || [ -t 2 ]); then
    SUPPORTS_COLOR=true
fi

# Additional check: if we're running with sudo, assume no color support to be safe
if [ -n "${SUDO_USER:-}" ] || [ -n "${SUDO_UID:-}" ]; then
    # Try to use colors anyway, but handle potential issues
    if ! command -v tput &>/dev/null; then
        # If tput is not available but we have a terminal, still try colors
        if ! ([ -t 1 ] || [ -t 2 ]); then
            SUPPORTS_COLOR=false
        fi
    fi
fi

export SUPPORTS_COLOR

# Colors for terminal output
if ${SUPPORTS_COLOR}; then
    COLOR_RESET='\033[0m'
    COLOR_RED='\033[0;31m'
    COLOR_YELLOW='\033[0;33m'
    COLOR_GREEN='\033[0;32m'
    COLOR_BLUE='\033[0;34m'
    COLOR_GRAY='\033[0;90m'
else
    COLOR_RESET=''
    COLOR_RED=''
    COLOR_YELLOW=''
    COLOR_GREEN=''
    COLOR_BLUE=''
    COLOR_GRAY=''
fi

# log() - Generic logging function
# Usage: log <level> <message>
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local level_name
    
    case $level in
        ${LOG_DEBUG}) level_name="DEBUG"; color="${COLOR_GRAY}" ;;
        ${LOG_INFO})  level_name="INFO";  color="${COLOR_GREEN}" ;;
        ${LOG_WARN})  level_name="WARN";  color="${COLOR_YELLOW}" ;;
        ${LOG_ERROR}) level_name="ERROR"; color="${COLOR_RED}" ;;
        *) level_name="UNKNOWN"; color="${COLOR_RESET}" ;;
    esac
    
    # Write to log file
    echo "[${timestamp}] [${level_name}] ${message}" >> "${LOG_FILE}"
    
    # Write to terminal if level is high enough
    if [ ${level} -ge ${LOG_CURRENT_LEVEL} ]; then
        echo -e "${color}[${level_name}]${COLOR_RESET} ${message}"
    fi
}

# Convenience functions
log_debug() { log ${LOG_DEBUG} "$@"; }
log_info()  { log ${LOG_INFO} "$@"; }
log_warn()  { log ${LOG_WARN} "$@"; }
log_error() { log ${LOG_ERROR} "$@"; }

# log_step() - Log a major step
log_step() {
    log_info "===== $* ====="
}

# log_command() - Log a command before executing
log_command() {
    log_debug "Executing: $*"
}

# log_success() - Log a success message
log_success() {
    log_info "✓ $*"
}

# log_failure() - Log a failure message
log_failure() {
    log_error "✗ $*"
}
