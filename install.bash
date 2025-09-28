#!/bin/bash
set -eu -o pipefail
THIS_FILE="$(readlink -e ${BASH_SOURCE[0]})"
THIS_DIR="$(dirname $THIS_FILE)"

cat_help() (cat) << EOF
Usage: install.bash [-h | --help]

Listens to the following environment variables:

    BACKUP_ROOT: Folder to put backups into, defaults to /tmp

EOF

for ARG in "$@"
do
    case "$ARG" in
        -h|--help) cat_help; exit 0;;
    esac
done

# Setup backup
BACKUP_ROOT="${BACKUP_ROOT:-/tmp}"
BACKUP_DIR="$BACKUP_ROOT"/dotFiles-"$(date +%s)"
mkdir -p "$BACKUP_DIR"
RESTORE_BASH="$BACKUP_DIR"/restore.bash
cat << EOF >> "$RESTORE_BASH"
#!/bin/bash
set -eux -o pipefail
EOF
chmod +x "$RESTORE_BASH"

HOME="${HOME:-~}"
DEST_CONFIG="${XDG_CONFIG_HOME:-$HOME}/.config"
DEST_CONFIG="$(readlink -m $DEST_CONFIG)"
mkdir -p "$DEST_CONFIG"

# Config folder install
install_under_home_folder() {
    DEST_SUB_PATH="$1"
    FROM_SUB_PATH="${2:-$DEST_SUB_PATH}"
    DEST_DIR="$HOME"/"$DEST_SUB_PATH"
    if [[ -e "$DEST_DIR" ]]
    then
        if [[ -L "$DEST_DIR" ]]
        then
            rm "$DEST_DIR"
        else
            BACKUP_DEST="$BACKUP_DIR"/"$DEST_SUB_PATH"
            mkdir -p "$(dirname $BACKUP_DEST)"
            mv -T "$DEST_DIR" "$BACKUP_DEST"
            cat << EOF >> "$RESTORE_BASH"
if [[ -L '$DEST_DIR' ]]
then
    rm '$DEST_DIR'
    mv -vT '$BACKUP_DEST' '$DEST_DIR'
fi
EOF
        fi
    fi
    ln -vs "$THIS_DIR"/"$FROM_SUB_PATH" "$DEST_DIR"
}
install_config_folder() {
    FOLDER_NAME="$1"
    DEST_DIR="$DEST_CONFIG"/"$FOLDER_NAME"
    if [[ -e "$DEST_DIR" ]]
    then
        if [[ -L "$DEST_DIR" ]]
        then
            rm "$DEST_DIR"
        else
            BACKUP_DEST="$BACKUP_DIR"/.config/"$FOLDER_NAME"
            mkdir -p "$(dirname $BACKUP_DEST)"
            mv -T "$DEST_DIR" "$BACKUP_DEST"
            cat << EOF >> "$RESTORE_BASH"
if [[ -L '$DEST_DIR' ]]
then
    rm '$DEST_DIR'
    mv -vT '$BACKUP_DEST' '$DEST_DIR'
fi
EOF
        fi
    fi
    ln -vs "$THIS_DIR"/.config/"$FOLDER_NAME" "$DEST_DIR"
}

# Git
install_config_folder git

# Vim
install_config_folder vim
install_under_home_folder .vim .config/vim

# ~/.bash*
for FILE_PATH in "$THIS_DIR"/.config/bash/*/
do
    FILENAME="$(basename "$FILE_PATH")"
    DEST="$HOME"/."$FILENAME"
    if [[ -f "$DEST" ]]
    then
        BACKUP_DEST="$BACKUP_DIR"/."$FILENAME"
        cp "$DEST" "$BACKUP_DEST"
        echo "cat '$BACKUP_DEST' > '$DEST'" >> "$RESTORE_BASH"
    else
        touch "$DEST"
    fi
    sed --in-place --file=- "$DEST" << EOF
1i \
source "${FILE_PATH}prepend"
\$a \
source "${FILE_PATH}append"
EOF
    echo "Prepend and appended 'source ...' to $DEST"
done
