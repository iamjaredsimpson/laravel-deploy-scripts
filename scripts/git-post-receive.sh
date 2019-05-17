#!/bin/bash

# Script to handle the git post receive hook. This will run the git-deploy script.
# Place this file in usr/local/bin.
# In your post-received file, add "git-post-receive"

DIR="$(dirname "${BASH_SOURCE[0]}")"

# Include files
INCLUDE_FILES=(
    ".env.sh"
)
for INCLUDE_FILE in "${INCLUDE_FILES[@]}"
do
    if [[ ! -f "${DIR}/${INCLUDE_FILE}" ]] ; then
        echo "File ${DIR}/${INCLUDE_FILE} is missing, aborting."
        exit 1
    fi
    source "${DIR}/${INCLUDE_FILE}"
done

DATE=$(date +%Y_%m_%d-%H_%M_%S)
FOLDER=${APP}-${DATE}

mkdir ${WORKING_DIR}/${FOLDER}
git --work-tree=${WORKING_DIR}/${FOLDER} --git-dir=/home/${SERVER_USER}/${APP}.git checkout -f
sudo /usr/local/bin/git-deploy $DATE
