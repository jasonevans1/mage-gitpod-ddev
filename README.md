# Magento 2 Gitpod Cloud Environment using ddev

Spin up a Magento Open Source instance on Gitpod using ddev. Using [ddev](https://ddev.com/) greatly simplifies the setup and maintenance of a dev environment.

Or, with Adobe Commerce and/or Hyvä Themes in [3 simple steps](#getting-started).

Note: This project is based on [magento-gitpod](https://github.com/fisheyehq/magento-gitpod) repository.

## Overview

This repository contains a Gitpod configuration for a Magento 2 cloud environment that can be used for multiple purposes, such as:
* To demo sites to merchants during sales pitches
* To provide merchant training sessions
* Quick access to a blank Magento instance to test/debug default configuration options
* For a demo instance to help revise for Adobe Commerce certifications (e.g. Business Practitioner)
* For a quick, disposable development environment to 'hack around' on (great for developer training sessions)
* For those new to Magento 2 to quickly get hands-on and play around with the platform

## Key Benefits/Features
* Environments are quick to create (~5 mins) and even faster to restart, once created, after being stopped (<1 min)
* Each environment allows you full access to the storefront, admin panel, codebase, command line and more, and can even be connected to VS Code or PHP Storm remotely
* Everything is cloud hosted, so it takes up no space or resource on your machine (bar another browser tab)
* Each environment has it's own dedicated URL, which you can share others so they can access too (e.g. merchants and colleagues)
* You can create, run (and destroy) as many environments as you like and run up to 4 in parallel (on the free tier)
* Gitpod's free tier provides you 50 hours of uptime across all environments
* After 30 minutes of inactivity your instance will be turned off to save your usage time

> Be aware that after 14 days of inactivity your environment will be deleted!

## Roadmap
* Add option to install Adobe Live Search and Product Recommendations to the Adobe Commerce build
* Add option to install Varnish
* Add option to install RabbitMQ
* Add option to install Adobe Commerce CLI tools and configuration.
* Add documentation for the following: cron, Mailhog for email, PHPUnit.

## Getting Started

### Prerequisites
* Ensure you have a GitHub account and are logged in
* Install and enable the ([Gitpod browser extension](https://www.gitpod.io/docs/browser-extension))
* Ensure you have the relevant license keys to hand (for Adobe Commerce and Hyvä Themes only)

### Magento Open Source:
1. Add variables to your account at [https://gitpod.io/variables](https://gitpod.io/variables) for `MAGENTO_COMPOSER_AUTH_USER` and `MAGENTO_COMPOSER_AUTH_PASS` with composer credentials that have access to Magento open source.
2. Click the 'Gitpod' button, or simply visit [https://gitpod.io/#https://github.com/jasonevans1/mage-gitpod-ddev](https://gitpod.io/#https://github.com/jasonevans1/mage-gitpod-ddev)

### Adobe Commerce (installs the B2B extension):
1. Create a free Gitpod account by linking your GitHub account: [https://gitpod.io/login/](https://gitpod.io/login/)
2. Add variables to your account at [https://gitpod.io/variables](https://gitpod.io/variables) for `MAGENTO_EDITION` set to enterprise,  `MAGENTO_COMPOSER_AUTH_USER` and `MAGENTO_COMPOSER_AUTH_PASS` with composer credentials that have access to the Adobe Commerce repos and set the scope to `jasonevans1/mage-gitpod-ddev`\*
3. Click the 'Gitpod' button, or simply visit [https://gitpod.io/#https://github.com/jasonevans1/mage-gitpod-ddev](https://gitpod.io/#https://github.com/jasonevans1/mage-gitpod-ddev)

> \*Note: you must supply your own composer credentials to allow install of Adobe Commerce.

### Hyvä Themes (Magento Open Source):
1. Create a free Gitpod account by linking your GitHub account: [https://gitpod.io/login/](https://gitpod.io/login/)
2. Add variables to your account at [https://gitpod.io/variables](https://gitpod.io/variables) for `INSTALL_HYVA` set to YES, `HYVA_COMPOSER_TOKEN` and `HYVA_COMPOSER_PROJECT` with your Hyvä Themes composer token and project name (see [Hyvä's install docs](https://docs.hyva.io/hyva-themes/getting-started/index.html) for more detail) and set the scope to `jasonevans1/mage-gitpod-ddev`\*
3. Click the 'Gitpod' button, or simply visit [https://gitpod.io/#https://github.com/jasonevans1/mage-gitpod-ddev](https://gitpod.io/#https://github.com/jasonevans1/mage-gitpod-ddev)

> \*Note: you must supply your own Hyvä credentials that where provided to you when purchased a license. Installing Hyvä Themes via git is not supported.

### Hyvä Themes (Adobe Commerce):
1. Ensure you've followed steps 1 and 2. from both the Adobe Commerce and Hyvä Themes guides above
2. Visit: [https://gitpod.io/#INSTALL_HYVA=YES/https://github.com/jasonevans1/mage-gitpod-ddev](https://gitpod.io/#INSTALL_HYVA=YES/https://github.com/jasonevans1/mage-gitpod-ddev)

## Accessing the Magento Admin Panel
The Magento Admin Panel is is available at `/admin` and the username and password are `admin` and `password1` respectively.

## Modifying Configuration
The environments allow for multiple different configuration settings that can be overridden using [environment variables](https://www.gitpod.io/docs/environment-variables), including (but not limited to):
* Installation of Magento Open Source or Adobe Commerce
* Installation of sample data
* Magento version to install
* Installation and set up of Hyvä Themes
* Composer credentials
* Change the admin username and password

## ddev Notes
ddev is installed and configured within the gitpod.io environment. .gitpod.yml file is configured to use the `drud/ddev-gitpod-base:20221018` docker image.

* .ddev/config.yaml - ddev configuration file. Configured with: PHP 8.1, MariaDB 10.4, Composer 2, Nginx, node.js v16, xdebug is disabled.
* Elasticsearch and Redis containers are installed. See the .gitpod/start_repo.sh script
* Run `ddev ssh` from the terminal to SSH to the nginx docker container.

### xdebug
Steps to enable xdebug:

* Run command: `ddev xdebug on`
* PHPStorm: Open Settings > PHP > Servers. Add a server with the name of the gitpod URL on port 80. Map the Magento root directory to `/var/www/html`. Start Listenting for debug connections. See the ddev documentation for more information. https://ddev.readthedocs.io/en/stable/users/debugging-profiling/step-debugging/

### blackfire.io
Steps to enable blackfire.io for profiling

* Run command: `ddev config global --web-environment-add="BLACKFIRE_SERVER_ID=<id>,BLACKFIRE_SERVER_TOKEN=<token>,BLACKFIRE_CLIENT_ID=<id>,BLACKFIRE_CLIENT_TOKEN=<token>` . Replacing the <id> and <token> with your blackfire credentials. Note: you only need the client_id and client_token set if you are profiling CLI commands.
* Run command: `ddev blackfire on`
* Use the blackfire.io browser extension to profile a Magento page on your gitpod workspace.
* See the ddev documentation for more information. https://ddev.readthedocs.io/en/stable/users/debugging-profiling/blackfire-profiling/

## Gitpod Notes

### Overriding Environment Variables
There are multiple ways to override environment variables, [which are outlined in this guide](https://www.gitpod.io/docs/environment-variables), and which option you should choose depends on whether you want to override the configuration for a specific environment only, or every environment you create with Gitpod.

#### Global Overrides
To override values for all environments, which is recommended if you want to override composer credentials to allow installation of Adobe Commerce, see the Adobe Commerce set up steps above (under 'Getting Started') to add variables to your account at [https://gitpod.io/variables](https://gitpod.io/variables). You may also wish to use this to always enable Xdebug, for example.

#### Per Environment Overrides
There are some settings that you may want to override for a specific environment only, such as whether you want to install sample data, or change the version of Magento installed. You can do this by passing the environment variables as part of the URL to initiate the environment build.

All the 'Gitpod' button on GitHub does is direct you to a special Gitpod URL that includes the GitHub repo URL. For example, on this repo the URL is `https://gitpod.io/#https://github.com/jasonevans1/mage-gitpod-ddev`.

To override variables, they need to included between `https://gitpod.io/#` portion of the URL and the repo URL itself.

For example to install Magento 2.4.4 (managed by the `MAGENTO_VERSION` variable) and disable the installation of sample data (managed by the `INSTALL_SAMPLE_DATA` variable) you'd construct and visit the following URL:

[https://gitpod.io/#MAGENTO_VERSION=2.4.4,INSTALL_SAMPLE_DATA=NO/https://github.com/jasonevans1/mage-gitpod-ddev](https://gitpod.io/#MAGENTO_VERSION=2.4.4,INSTALL_SAMPLE_DATA=NO/https://github.com/jasonevans1/mage-gitpod-ddev)

> Note: for security reasons, it is not recommended to pass sensitive information (such as composer credentials) as URL parameters. Always use the [https://gitpod.io/variables](https://gitpod.io/variables) page in your account instead.

## Using mage-gitpod-ddev for an existing Magento project
You could use this project as a starting point for running an existing Magento project on Gitpod using ddev. Here are the steps:

* Copy the files into your existing Magento repository: .ddev/config.yaml, .gitpod/install_magento.sh, .gitpod/start_repo.sh, .gitpod.yml.
* Change the .ddev/config.yaml and .gitpod.yml as needed.
* Set these Gitpod environment variables `INSTALL_MAGENTO=NO`, `INSTALL_SAMPLE_DATA=NO`, `MAGENTO_EDITION=existing` and set the Magento/Hyva composer key variables as needed.
* Commit a database dump here `.gitpod/magento-db.sql.zip` . This database dump will be imported on the initial start of the workspace.
* Commit a `.gitpod/files.tgz` if you want to load media files.
* Commit a composer.json and composer.lock file.
* Customize .gitpod/install_magento.sh as needed. Example customizations: change how the database file is stored and loaded, change the magento settings on start. 
* TODO: Add option to load an existing app/etc/env.php file on workspace start.


