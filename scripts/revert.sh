#!/bin/bash

# REVERT LARAVEL APP TO A PREVIOUS DEPLOYMENT
#> revert git_reponame folder_to_use

if (( $# < 2 )); then
        echo "Deploy Script requires an app name and a folder. The app name should match your git repository name."
        exit 1
fi

#UPDATE THIS
WORKING_DIR=/var/www/html

APP=$1 FOLDER=$2

echo -e "\n====> Reverting...\n"

cd $WORKING_DIR

sudo rm -rf ${WORKING_DIR}/${APP} && ln -s ${WORKING_DIR}/${FOLDER}/${APP} ${WORKING_DIR}/${APP}

#delete old site?
# readlink -f ${APP} | sudo rm -rf

echo -e "\n====> Site Reverted Successfully.\n\n"
