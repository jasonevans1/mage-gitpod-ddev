#!/bin/bash

set -eu

url=$(gp url | awk -F"//" {'print $2'}) && url+="/" &&
url="https://8080-"$url"/"

cd ${GITPOD_REPO_ROOT}
# Temporarily use an empty config.yaml to get ddev to use defaults
# so we can do composer install. If there's already one there,
# this does no harm.
mkdir -p .ddev && touch .ddev/config.yaml

# If there's a composer.json, do `ddev composer install` (which auto-starts projct)
if [ -f composer.json ]; then
  ddev start
  ddev composer install
else
  ddev composer config -g -a http-basic.repo.magento.com ${MAGENTO_COMPOSER_AUTH_USER} ${MAGENTO_COMPOSER_AUTH_PASS}
  ddev composer create --no-interaction --no-progress --repository-url=https://repo.magento.com/ magento/project-${MAGENTO_EDITION}-edition=${MAGENTO_VERSION}
  git reset && git checkout . && git checkout -- .gitignore;
fi

sed -i "s/AUTH_USER/${MAGENTO_COMPOSER_AUTH_USER}/g" ${GITPOD_REPO_ROOT}/auth.json &&
sed -i "s/AUTH_PASS/${MAGENTO_COMPOSER_AUTH_PASS}/g" ${GITPOD_REPO_ROOT}/auth.json &&

if [ ! -f bin/magerun2 ]; then
  ddev exec curl -L https://files.magerun.net/n98-magerun2.phar --output bin/magerun2
  ddev exec chmod +x bin/magerun2
fi

ddev get drud/ddev-redis
ddev get drud/ddev-elasticsearch

# This won't be required in ddev v1.18.2+
printf "host_webserver_port: 8080\nhost_https_port: 2222\nhost_db_port: 3306\nhost_mailhog_port: 8025\nhost_phpmyadmin_port: 8036\nbind_all_interfaces: true\n" >.ddev/config.gitpod.yaml
ddev stop -a
ddev start -y
