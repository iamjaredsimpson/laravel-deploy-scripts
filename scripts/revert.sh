#!/bin/bash

# REVERT LARAVEL APP TO A PREVIOUS DEPLOYMENT
#> revert git_reponame folder_to_use

if (( $# < 1 )); then
        echo "Revert Script requires a folder name."
        exit 1
fi

# Get the directory of the currently executing script
DIR="$(dirname "${BASH_SOURCE[0]}")"

# Include files
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

FOLDER=$1
APP_DIR=${WORKING_DIR}/${FOLDER}

echo -e "\n====> Reverting...\n"

cd $WORKING_DIR

sudo rm -rf ${WORKING_DIR}/${APP} && ln -s ${WORKING_DIR}/${FOLDER}/ ${WORKING_DIR}/${APP}

#delete old site?
# readlink -f ${APP} | sudo rm -rf

echo -e "\n\n====> Caching Configs...\n\n"
/usr/bin/php $APP_DIR/artisan cache:clear
/usr/bin/php $APP_DIR/artisan config:cache


echo -e "\n\n====> Restarting php-fpm...\n"
sudo service ${PHP} restart

which nginx > /dev/null 2>&1
if [ $? == 0 ]; then
    echo -e "\n====> Restarting nginx...\n"
    sudo service nginx restart
fi

which supervisord > /dev/null 2>&1
if [ $? == 0 ]; then
    echo -e "\n====> Restarting supervisord...\n"
    sudo service supervisor restart
fi

echo -e "\n====> Site Reverted Successfully.\n\n"
