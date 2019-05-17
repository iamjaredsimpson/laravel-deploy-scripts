#!/bin/bash

# DEPLOY LARAVEL APP AND DO FULL INSTALL
# This deploy has almost zero downtime.
# Instead of updating the currently-running version,
# it checks out a new clone of the passed in branch and builds it in a timestamped folder, then
# recreates a symlink at the very end.

# This script assumes you have put your production .env file in your WORKING_DIR folder and your master branch has been commited with all npm assets compiled (npm run production).
# We have the file at /usr/local/bin/deploy and executable.
# Also you’ll need to use a deploy key for ssh access to your repo.
#> deploy git_reponame

if (( $# < 1 )); then
        echo "Deploy Script requires a repository branch."
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

BRANCH=$1 TIME=$(date +%Y_%m_%d-%H_%M_%S) FOLDER=${APP}-${TIME} APP_DIR=${WORKING_DIR}/${FOLDER}

echo -e "\n\n====> Building $FOLDER from $ACCOUNT.github.com:$ACCOUNT/$APP\n"

echo -e "\n====> Cloning...\n\n"
mkdir ${WORKING_DIR}/${FOLDER}
cd ${WORKING_DIR}/${FOLDER}
git clone --single-branch --branch $BRANCH https://github.com/$ACCOUNT/$APP

if [ ! -d "${WORKING_DIR}/${FOLDER}" ]; then
        echo "There was an issue with $FOLDER. Please try again." echo exit 1
fi

cd ${WORKING_DIR}
touch ${APP_DIR}/${APP}/.env
cp .env ${APP_DIR}/${APP}/.env

cp -R ${APP_DIR}/${APP}/. $APP_DIR/
sudo rm -rf ${APP_DIR}/${APP}

cd ${APP_DIR}
echo -e "\n\n====> Installing composer dependencies...\n\n"
composer install --no-interaction --no-dev --prefer-dist

echo -e "\n\n====> Copying Public/Private Storage...\n\n"
cp -R ${WORKING_DIR}/${APP}/storage/app/public ${APP_DIR}/storage/app/
cp -R ${WORKING_DIR}/${APP}/storage/app/private ${APP_DIR}/storage/app/
/usr/bin/php $APP_DIR/artisan storage:link

echo -e "\n\n====> Modifying permissions...\n\n"
sudo touch $APP_DIR/storage/logs/laravel.log
sudo touch $APP_DIR/storage/logs/laravel.json
sudo mkdir -p $APP_DIR/storage/framework/cache/data
sudo chown -R wwworkshop-staging:www-data $APP_DIR
sudo chmod -R 2777 $APP_DIR/storage

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

echo -e "\n====> Updating Symlink...\n"
sudo rm -rf ${WORKING_DIR}/${APP} && ln -s $APP_DIR ${WORKING_DIR}/${APP}

echo -e "\n====> Deleting Old Site Clones...\n"
cd $WORKING_DIR
sudo ls -dt */ | tail -n +7 | xargs rm -rf

echo -e "\n====> Listing directory contents for ${FOLDER}\n\n"

ls -alrth "${APP_DIR}"

echo -e "\n\n====> Site Deployed Successfully.\n\n"
