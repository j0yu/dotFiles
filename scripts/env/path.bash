#!/bin/bash
#
# Appends all immediate subfolders of "scripts" folder into $PATH
# and echos it. Use by exporting that as $PATH as needed e.g.
#
#    export PATH="$(path.bash)"
#
# Warning: Sensitive to how deep/where this file is placed in
set -eu -o pipefail

THIS_FILE="$(readlink -e "${BASH_SOURCE[0]}")"
SCRIPTS_DIR="$(readlink -m "$THIS_FILE"/../..)"
for FULL_PATH in "$SCRIPTS_DIR"/*/
do PATH="$PATH":"${FULL_PATH::-1}"
done
exec echo "$PATH"
