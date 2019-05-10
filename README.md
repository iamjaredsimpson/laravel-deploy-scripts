# laravel-deploy-scripts
Shell scripts to manage Laravel app deployment on an Linux server running Nginx. This was built for Laravel 5.8, but should work with any version 5.0+. There is are currently two scripts, one to deploy and one to revert to a previous deployment.

## Overview

The deploy script will deploy a Laravel application with almost zero downtime. Instead of updating the currently-running version, it checks out a new clone of the master branch and builds it in a timestamped folder, then recreates a symlink at the very end. The symlink represents your root folder.

## Installation
* SSH into your server. Copy the deploy.sh script to your linux server at /usr/local/bin/ in a file called deploy. Copy the revert.sh script to your linux server at /usr/local/bin/ in a file called revert. Make both files executable.

```
sudo chmod +x /usr/local/bin/deploy /usr/local/bin/revert
```

## Assumptions
* On your Linux server, you must have your root folder be the same name as your git repository name. For example, your root could be located at /var/www/html/app-name. This folder will actually be a symlink to the current build.
* In your working directory (/var/www/html in the previous example), you must place your production .env file. The contents of this file will be copied to every clone you make.
* You will need to update two variables in the files, USERNAME and WORKING_DIR. Username is your git username that the repository is associated with and is only needed in the deploy script. You may also need to update your php and nginx versions near the bottom of the deploy script.
* You’ll need to use a deploy key for SSH access to your repo.

Note: this script will not run database migrations.

## How to Deploy
Once the script is installed, you can run the script with the following command format
```
deploy app-name branch-name
```

So in reality, it may look something like this
```
deploy app-name master
OR
deploy app-name staging
```

## Results of Deployment
The script will take "app-name" and create a folder formated with the time, such as app-name-2019_01_01-15-34-65. Inside this folder, it will clone your repository branch. Once that is finished, it will run composer, update permissions, copy your .env file, and restart your server. Finally, it will create a symlink with the title of your app-name and point it at this new folder. 

By doing this, you still have your previous build and can revert it back if needed. 

## How to Revert Back to a Previous Deployment
All you have to do is run the revert command with the following format
```
revert app-name app-folder
```

So in reality it may look like the following:

```
revert app-name app-name-2019_01_01-15-34-65
```


