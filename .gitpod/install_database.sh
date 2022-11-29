#!/bin/bash

set -eu

url=$(gp url | awk -F"//" {'print $2'}) && url+="/" &&
url="https://8080-"$url"/"

cd ${GITPOD_REPO_ROOT}

if [ "${INSTALL_MAGENTO}" = "YES" ]; then
  sleep 15
  ddev redis-cli flushall
  ddev exec rm -rf /var/www/html/var/cache/ /var/www/html/generated/
  cp .gitpod/env.php app/etc/env.php
  ddev magento setup:install --db-name='db' --db-user='db' --db-password='db' --base-url=$url --backend-frontname='admin' --admin-user=$MAGENTO_ADMIN_USERNAME --admin-password=$MAGENTO_ADMIN_PASSWORD --admin-email=$GITPOD_GIT_USER_EMAIL --admin-firstname='Admin' --admin-lastname='User' --use-rewrites='1' --use-secure='1' --base-url-secure=$url --use-secure-admin='1' --language='en_US' --db-host='db' --cleanup-database --timezone='America/Chicago' --currency='USD' --session-save='files' --search-engine='elasticsearch7' --elasticsearch-host='elasticsearch' --elasticsearch-port='9200';
  ddev magento deploy:mode:set developer
fi

if [ "${INSTALL_SAMPLE_DATA}" = "YES" ]; then
  ddev magento sampledata:deploy;
fi

if [ "${INSTALL_MAGENTO}" = "NO" ] && [ -f ".gitpod/magento-db.sql.zip" ]; then
  ddev import-db --src=.gitpod/magento-db.sql.zip
else
  echo "No database was imported. No .gitpod/magento-db.sql.zip was provided and magedbm2 was not configured."
fi
if [ -f ".gitpod/files.tgz" ]; then
  ddev import-files --src=.gitpod/files.tgz
else
  echo "No files.tgz was provided in .gitpod"
fi

ddev magento setup:upgrade
ddev magento config:set web/cookie/cookie_path "/"
ddev magento config:set web/cookie/cookie_domain ".gitpod.io"
ddev magento setup:store-config:set --base-url="${url}"
ddev magento setup:store-config:set --base-url-secure="${url}"
ddev magento setup:config:set --session-save=redis --session-save-redis-host=redis --session-save-redis-log-level=3 --session-save-redis-db=0 --session-save-redis-port=6379 -n;
ddev magento setup:config:set --cache-backend=redis --cache-backend-redis-server=redis --cache-backend-redis-db=1 -n;
ddev magento setup:config:set --page-cache=redis --page-cache-redis-server=redis --page-cache-redis-db=2 -n;
ddev magento module:disable Magento_Csp Magento_TwoFactorAuth
ddev magento cache:flush
ddev redis-cli flushall

touch ${GITPOD_REPO_ROOT}/.gitpod/db-installed.flag
gp ports await 8080 && sleep 1 && gp preview $(gp url 8080)
