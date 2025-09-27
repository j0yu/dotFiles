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

# Git
DEST_GIT="$DEST_CONFIG"/git
if [[ -L "$DEST_GIT" ]]
then
    rm "$DEST_GIT"
else
    BACKUP_DEST="$BACKUP_DIR"/.config/git
    mkdir -p "$(dirname $BACKUP_DEST)"
    mv -T "$DEST_GIT" "$BACKUP_DEST"
    cat << EOF >> "$RESTORE_BASH"
if [[ -L '$DEST_GIT' ]]
then
    rm '$DEST_GIT'
    mv -vT '$BACKUP_DEST' '$DEST_GIT'
fi
EOF
fi
ln -vs "$THIS_DIR"/.config/git "$DEST_GIT"

# ~/.bash*
for FILE_PATH in "$THIS_DIR"/.config/bash/*
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
source "${FILE_PATH}/prepend"
\$a \
source "${FILE_PATH}/append"
EOF
    echo "Prepend and appended 'source ...' to $DEST"
done
