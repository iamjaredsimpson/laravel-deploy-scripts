# Laravel Deploy Scripts
Shell scripts to manage Laravel app deployment on an Linux server running Nginx. This was built for Laravel 5.8, but should work with any version 5.0+. There are currently three main scripts, two to deploy and one to revert to a previous deployment. There is also .env example file for your custom variables and a script to handle the git post-receive hook.

## Overview

The deploy script will deploy a Laravel application with almost zero downtime. Instead of updating the currently running version, it checks out a new clone of the passed in branch and builds it in a timestamped folder, then recreates a symlink at the very end. The symlink represents the root folder of your website. It will only keep 5 copies of the site and will delete any sites older than the fifth.

## Assumptions
* I assume that you already have a non root sudo user on your server and that everything is already set up to serve your website. That meaning PHP, MySQL, Ngnix are already installed and working properly.
* Nginx must have your root folder be the same name as your git repository name. For example, your root could be located at /var/www/html/app-name/public. This folder will actually be a symlink to the current build.
* In your working directory (/var/www/html in the previous example), you must place your production .env file. The contents of this file will be copied to every clone you make. This will most likely be the only file in this directory until you make a deployment.
* You’ll need to attach a SSH key to your git repository so that the git-deploy/post-receive scripts can access your repo.

Note: this script will not run database migrations.

## Installation
* Clone scripts repository.
* Rename example.env.sh to .env.sh
* Update the variables in .env.sh

** Stop here and jump to the Manual Deploy section if you do not want to tie your deployments to git. I would recommend setting up a git remote. If you just want to try the script out, skip this and use the manual-deploy script. **

* SFTP into your server.
* Copy the scripts folder to your users folder. 
* Exit.

* SSH into your server.
* Navigate to your scripts folder
```
cd ~/scripts
```
* Run the install script. 
```
./install.sh
```
* If all goes well, it should install successfully.
* Exit the server

* On your local machine, navigate in terminal to your project repository.
* Add a remote repository. This can be named anything you want. Depending on the situation, I usually use production, dev, or staging. **Be sure to update your ssh information.**
```
git remote add REMOTE_NAME 
ssh://username@ip.address/home/sitename/sitename.git
```

* Thats it! You should be able to now run the following command from your repository folder on your local machine.
```
git push REMOTE_NAME BRANCH_TO_PUSH
```

## How to Manually Deploy
The manual deploy script allows you to clone a repository branch without having to set up a git remote or have changes in your repository. 

If you didn't run the install script, do the following.
* Clone scripts repository.
* Rename example.env.sh to .env.sh
* Update the variables in .env.sh
* Remove .sh from all filenames except .env.sh.
* SFTP into your server. Copy the .env.sh, manual-deploy, and revert to your Linux server at /usr/local/bin/. 
* Exit
* SSH into the server.
* Make script files executable.

```
sudo chmod +x /usr/local/bin/manual-deploy /usr/local/bin/revert
```

Once that is done, you can run the manual deploy script with the following command format.

```
manual-deploy branch-name
```

## Results of Deployment
The script will take "app-name" from the .env.sh file and create a folder formated with the time, such as app-name-2019_01_01-15-34-65. Inside this folder, it will clone your repository branch. Once that is finished, it will run composer, update permissions, copy your .env file, copy your storage file from the previous deployment, and restart your server. Finally, it will create a symlink with the title of your app-name and point it at the new app-name-2019_01_01-15-34-65 folder. 

By doing this, you still have your previous build and can revert it back if needed, while pushing a new build to the server with almost 0 downtime. 

## How to Revert Back to a Previous Deployment
All you have to do is run the revert command with the following format
```
revert app-folder
```

So in reality it may look like the following:

```
revert app-name-2019_01_01-15-34-65
```


