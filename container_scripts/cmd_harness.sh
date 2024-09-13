#!/bin/bash

# This script calls the CP-specific utility based on the passed arguments.
# Note to developers: DO NOT MODIFY THIS FILE

set -e
set -E
set -u
set -o pipefail

: "${CP_BASE_BUILD_PREFIX:=}"
: "${CP_BASE_BUILD_SUFFIX:=}"
: "${CP_HARNESS_BUILD_PREFIX:=}"
: "${CP_HARNESS_BUILD_SUFFIX:=}"

# get name and directory of this script
SCRIPT_FILE="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

# target binary to call
CMD_NAME=${1:-}
TARGET_UTILITY="${SCRIPT_DIR}/cp_${CMD_NAME}"
shift

# trapped error handler (argument is the exit code from error)
function __error_handler() {
    local __status=$1
    echo "Error in ${SCRIPT_DIR}/${SCRIPT_FILE} from ${TARGET_UTILITY}: ${__status}" >&2
    # shellcheck disable=SC2086
    exit ${__status}
}

# test if utility template exists
if [[ -f "${TARGET_UTILITY}.tmpl" ]]; then
    envsubst '$CP_BASE_BUILD_PREFIX,$CP_BASE_BUILD_SUFFIX,$CP_HARNESS_BUILD_PREFIX,$CP_HARNESS_BUILD_SUFFIX' < "${TARGET_UTILITY}.tmpl" | sudo tee "${TARGET_UTILITY}.gen" >/dev/null
    sudo chmod 777 "${TARGET_UTILITY}.gen"
    [[ -n ${LOCAL_USER} ]] && sudo chown ${LOCAL_USER} "${TARGET_UTILITY}.gen"
    TARGET_UTILITY="${TARGET_UTILITY}.gen"
fi

# test if executable utility exists
test -x "${TARGET_UTILITY}" || \
    {
        echo "Error in ${SCRIPT_DIR}/${SCRIPT_FILE},"\
              "missing executable ${TARGET_UTILITY}: 1" >&2;
        exit 1;
    }

# set error handler
trap  '__error_handler $?' ERR

# call CP-specific application
"${TARGET_UTILITY}" "$@"

exit 0
