#!/bin/bash

# Get the directory of the currently executing script
DIR="$(dirname "${BASH_SOURCE[0]}")"

# Include files
INCLUDE_FILES=(
    ".env.sh"
)
for INCLUDE_FILE in "${INCLUDE_FILES[@]}"
do
    if [[ ! -f "${DIR}/${INCLUDE_FILE}" ]] ; then
        echo "File ${DIR}/${INCLUDE_FILE} is missing, aborting."
        exit 1/var/www/html/.env
    fi
    source "${DIR}/${INCLUDE_FILE}"
done

# if [ $# -eq 0 ]
# then
	echo -e "\n\n====> Copying script to /usr/local/bin \n\n"
	sudo cp ./git-deploy.sh /usr/local/bin/git-deploy
	sudo cp ./manual-deploy.sh /usr/local/bin/manual-deploy
	sudo cp ./revert.sh /usr/local/bin/revert
	sudo cp ./git-post-receive.sh /usr/local/bin/git-post-receive
	sudo cp ./.env.sh /usr/local/bin/.env.sh

	echo -e "\n\n====> Updating script permissions \n\n"
	sudo chmod +x /usr/local/bin/.env.sh /usr/local/bin/revert /usr/local/bin/git-post-receive /usr/local/bin/manual-deploy /usr/local/bin/git-deploy

	echo -e "\n\n====> Initializing bare git repository in your home directory \n\n"
	cd ~
	mkdir ${APP}.git
	cd ${APP}.git
	git init --bare

	echo -e "\n\n====> Updating post receive hook \n\n"
	echo "git-post-receive" >> ~/${APP}.git/hooks/post-receive
	sudo chmod +x ~/${APP}.git/hooks/post-receive

	echo -e "\n\n====> Updating /etc/sudoers to allow for git-deploy to run without sudo \n\n"
	echo ${SERVER_USER}	'ALL=NOPASSWD: /usr/local/bin/git-deploy *' | sudo EDITOR='tee -a' visudo

	echo -e "\n\n====> Scripts were installed successfully \n\n"

	exit 0;
# else
# 	REMOTE=$1
# 	git remote add ${REMOTE} ssh://${GIT_USERNAME}@${HOST_NAME}/home/${SERVER_USER}/${APP}.git
# fi
