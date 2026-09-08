#!/bin/bash
# ledger.sh - Resource ownership & package provenance state engine for kali-land

# Prevent re-sourcing
[ -n "${LEDGER_SH_SOURCED:-}" ] && return 0
readonly LEDGER_SH_SOURCED=1

# Source logging
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LIB_DIR}/logging.sh"

# Target user and home directory resolution (handles sudo execution)
if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
    TARGET_USER="${SUDO_USER}"
    TARGET_HOME="$(eval echo "~${SUDO_USER}")"
else
    TARGET_USER="$(id -un)"
    TARGET_HOME="${HOME}"
fi

STATE_DIR="${TARGET_HOME}/.local/state/kali-land"
STATE_SUBDIR="${STATE_DIR}/state"
LEDGER_FILE="${STATE_SUBDIR}/installation.json"

# init_ledger() - Initialize ownership ledger JSON file if it does not exist
init_ledger() {
    mkdir -p "${STATE_SUBDIR}"
    mkdir -p "${STATE_DIR}/backups"
    mkdir -p "${STATE_DIR}/logs"
    mkdir -p "${STATE_DIR}/reports"

    if [ ! -f "${LEDGER_FILE}" ]; then
        log_info "Initializing resource ownership ledger at ${LEDGER_FILE}"
        python3 -c '
import json, sys, time
data = {
    "version": "1.0.0",
    "installation_id": str(int(time.time())),
    "created_at": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
    "last_updated": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
    "profile": "unknown",
    "platform": "unknown",
    "packages": {},
    "resources": {}
}
with open(sys.argv[1], "w") as f:
    json.dump(data, f, indent=2)
' "${LEDGER_FILE}"

        if [ -n "${TARGET_USER}" ]; then
            local user_group
            user_group="$(id -gn "${TARGET_USER}" 2>/dev/null || echo "${TARGET_USER}")"
            chown -R "${TARGET_USER}:${user_group}" "${STATE_DIR}" 2>/dev/null || true
        fi
    fi
}

# record_installation_metadata() - Record overall installation metadata
record_installation_metadata() {
    local version="${1:-1.0.0}"
    local profile="${2:-default}"
    local platform="${3:-kali}"

    init_ledger

    python3 -c '
import json, sys, time
ledger_path = sys.argv[1]
ver, prof, plat = sys.argv[2], sys.argv[3], sys.argv[4]
try:
    with open(ledger_path, "r") as f:
        data = json.load(f)
except Exception:
    data = {"packages": {}, "resources": {}}

data["version"] = ver
data["profile"] = prof
data["platform"] = plat
data["last_updated"] = time.strftime("%Y-%m-%dT%H:%M:%SZ")

with open(ledger_path, "w") as f:
    json.dump(data, f, indent=2)
' "${LEDGER_FILE}" "${version}" "${profile}" "${platform}"
}

# record_package_provenance() - Record package installation status
# Usage: record_package_provenance <package_name> <status> [requested_by]
# status can be: "already_present", "installed_by_kali_land", "failed"
record_package_provenance() {
    local pkg_name="$1"
    local status="$2"
    local requested_by="${3:-kali-land-core}"

    [ -z "${pkg_name}" ] && return 0
    init_ledger

    python3 -c '
import json, sys, time
ledger_path = sys.argv[1]
pkg, status, req = sys.argv[2], sys.argv[3], sys.argv[4]
try:
    with open(ledger_path, "r") as f:
        data = json.load(f)
except Exception:
    data = {"packages": {}, "resources": {}}

if "packages" not in data:
    data["packages"] = {}

data["packages"][pkg] = {
    "status": status,
    "requested_by": req,
    "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ")
}
data["last_updated"] = time.strftime("%Y-%m-%dT%H:%M:%SZ")

with open(ledger_path, "w") as f:
    json.dump(data, f, indent=2)
' "${LEDGER_FILE}" "${pkg_name}" "${status}" "${requested_by}"
}

# record_file_provenance() - Record file or directory resource ownership
# Usage: record_file_provenance <target_path> <action> <component_name>
# action can be: "created", "modified", "backed_up", "owned"
record_file_provenance() {
    local target_path="$1"
    local action="$2"
    local component_name="${3:-kali-land}"

    [ -z "${target_path}" ] && return 0
    init_ledger

    python3 -c '
import json, sys, time
ledger_path = sys.argv[1]
path, act, comp = sys.argv[2], sys.argv[3], sys.argv[4]
try:
    with open(ledger_path, "r") as f:
        data = json.load(f)
except Exception:
    data = {"packages": {}, "resources": {}}

if "resources" not in data:
    data["resources"] = {}

data["resources"][path] = {
    "action": act,
    "component": comp,
    "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ")
}
data["last_updated"] = time.strftime("%Y-%m-%dT%H:%M:%SZ")

with open(ledger_path, "w") as f:
    json.dump(data, f, indent=2)
' "${LEDGER_FILE}" "${target_path}" "${action}" "${component_name}"
}

# get_package_provenance() - Query package status from ledger
get_package_provenance() {
    local pkg_name="$1"
    if [ ! -f "${LEDGER_FILE}" ]; then
        echo "unknown"
        return 0
    fi

    python3 -c '
import json, sys
ledger_path, pkg = sys.argv[1], sys.argv[2]
try:
    with open(ledger_path) as f:
        data = json.load(f)
    print(data.get("packages", {}).get(pkg, {}).get("status", "unknown"))
except Exception:
    print("unknown")
' "${LEDGER_FILE}" "${pkg_name}"
}

# get_file_provenance() - Query file action status from ledger
get_file_provenance() {
    local target_path="$1"
    if [ ! -f "${LEDGER_FILE}" ]; then
        echo "unknown"
        return 0
    fi

    python3 -c '
import json, sys
ledger_path, p = sys.argv[1], sys.argv[2]
try:
    with open(ledger_path) as f:
        data = json.load(f)
    print(data.get("resources", {}).get(p, {}).get("action", "unknown"))
except Exception:
    print("unknown")
' "${LEDGER_FILE}" "${target_path}"
}

# get_kali_land_installed_packages() - List packages installed BY kali-land
get_kali_land_installed_packages() {
    if [ ! -f "${LEDGER_FILE}" ]; then
        return 0
    fi

    python3 -c '
import json, sys
ledger_path = sys.argv[1]
try:
    with open(ledger_path) as f:
        data = json.load(f)
    for pkg, info in data.get("packages", {}).items():
        if info.get("status") == "installed_by_kali_land":
            print(pkg)
except Exception:
    pass
' "${LEDGER_FILE}"
}

# get_kali_land_owned_resources() - List file/directory paths owned/created by kali-land
get_kali_land_owned_resources() {
    if [ ! -f "${LEDGER_FILE}" ]; then
        return 0
    fi

    python3 -c '
import json, sys
ledger_path = sys.argv[1]
try:
    with open(ledger_path) as f:
        data = json.load(f)
    for path, info in data.get("resources", {}).items():
        act = info.get("action")
        if act in ("created", "modified", "owned"):
            print(path)
except Exception:
    pass
' "${LEDGER_FILE}"
}
