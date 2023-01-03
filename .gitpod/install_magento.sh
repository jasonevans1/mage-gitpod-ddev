#!/bin/bash

set -eu

url=$(gp url | awk -F"//" {'print $2'}) && url+="/" &&
url="https://8080-"$url"/"

INSTALL_MAGENTO="${INSTALL_MAGENTO:=YES}"
INSTALL_SAMPLE_DATA="${INSTALL_SAMPLE_DATA:=YES}"
MAGENTO_EDITION="${MAGENTO_EDITION:=community}"
MAGENTO_ADMIN_USERNAME="${MAGENTO_ADMIN_USERNAME:=admin}"
MAGENTO_ADMIN_PASSWORD="${MAGENTO_ADMIN_PASSWORD:=password1}"
INSTALL_HYVA="${INSTALL_HYVA:=NO}"

cd ${GITPOD_REPO_ROOT}

if [ "${INSTALL_MAGENTO}" = "YES" ]; then
  ddev redis-cli flushall
  ddev exec rm -rf /var/www/html/var/cache/ /var/www/html/generated/
  cp .gitpod/config.php app/etc/config.php
  rm -rf app/etc/env.php
  ddev magento setup:install --db-name='db' --db-user='db' --db-password='db' --base-url=$url --backend-frontname='admin' --admin-user=$MAGENTO_ADMIN_USERNAME --admin-password=$MAGENTO_ADMIN_PASSWORD --admin-email=$GITPOD_GIT_USER_EMAIL --admin-firstname='Admin' --admin-lastname='User' --use-rewrites='1' --use-secure='1' --base-url-secure=$url --use-secure-admin='1' --language='en_US' --db-host='db' --cleanup-database --timezone='America/Chicago' --currency='USD' --session-save='files' --search-engine='elasticsearch7' --elasticsearch-host='elasticsearch' --elasticsearch-port='9200' || true
  #Run setup:install again because of error when installing Magento from scratch.
  ddev magento setup:install --db-name='db' --db-user='db' --db-password='db' --base-url=$url --backend-frontname='admin' --admin-user=$MAGENTO_ADMIN_USERNAME --admin-password=$MAGENTO_ADMIN_PASSWORD --admin-email=$GITPOD_GIT_USER_EMAIL --admin-firstname='Admin' --admin-lastname='User' --use-rewrites='1' --use-secure='1' --base-url-secure=$url --use-secure-admin='1' --language='en_US' --db-host='db' --cleanup-database --timezone='America/Chicago' --currency='USD' --session-save='files' --search-engine='elasticsearch7' --elasticsearch-host='elasticsearch' --elasticsearch-port='9200';
fi

if [ "${INSTALL_SAMPLE_DATA}" = "YES" ]; then
  ddev magento sampledata:deploy;
fi

if [ "${MAGENTO_EDITION}" = "enterprise" ]; then
    ddev composer require magento/extension-b2b;
fi

if [ "${INSTALL_HYVA}" = "YES" ] && [ ! -z "${HYVA_COMPOSER_TOKEN}" ] && [ ! -z "${HYVA_COMPOSER_PROJECT}" ]; then
    ddev composer config --auth http-basic.hyva-themes.repo.packagist.com token ${HYVA_COMPOSER_TOKEN}
    ddev composer config repositories.private-packagist composer https://hyva-themes.repo.packagist.com/${HYVA_COMPOSER_PROJECT}/
    ddev composer require hyva-themes/magento2-default-theme
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

ddev magento deploy:mode:set developer
ddev magento setup:upgrade
ddev magento config:set web/cookie/cookie_path "/"
ddev magento config:set web/cookie/cookie_domain ".gitpod.io"
ddev magento setup:store-config:set --base-url="${url}"
ddev magento setup:store-config:set --base-url-secure="${url}"
ddev magento setup:config:set --session-save=redis --session-save-redis-host=redis --session-save-redis-log-level=3 --session-save-redis-db=0 --session-save-redis-port=6379 -n;
ddev magento setup:config:set --cache-backend=redis --cache-backend-redis-server=redis --cache-backend-redis-db=1 -n;
ddev magento setup:config:set --page-cache=redis --page-cache-redis-server=redis --page-cache-redis-db=2 -n;
ddev magento module:disable Magento_Csp Magento_TwoFactorAuth

if [ "${MAGENTO_EDITION}" = "enterprise" ]; then
    ddev exec magerun2 config:store:set btob/website_configuration/company_active "1"
    ddev exec magerun2 config:store:set btob/website_configuration/sharedcatalog_active "1"
    ddev exec magerun2 config:store:set btob/website_configuration/negotiablequote_active "1"
    ddev exec magerun2 config:store:set btob/website_configuration/quickorder_active "1"
    ddev exec magerun2 config:store:set btob/website_configuration/requisition_list_active "1"
    ddev exec magerun2 config:store:set btob/default_b2b_payment_methods/available_payment_methods "braintree_ach_direct_debit,braintree_applepay,banktransfer,cashondelivery,checkmo,braintree,payflow_advanced,payflow_link,payflowpro,braintree_googlepay,braintree_local_payment,free,braintree_paypal,paypal_billing_agreement,payflow_express_bml,paypal_express_bml,paypal_express,payflow_express,hosted_pro,companycredit,purchaseorder,braintree_paypal_vault,braintree_cc_vault,payflowpro_cc_vault,braintree_venmo"
    ddev exec magerun2 config:store:set btob/default_b2b_shipping_methods/applicable_shipping_methods "0"
    ddev exec magerun2 config:store:set btob/website_configuration/purchaseorder_enabled "1"
    ddev exec magerun2 config:store:set catalog/magento_catalogpermissions/enabled "1"
    ddev exec magerun2 config:store:set catalog/magento_catalogpermissions/grant_catalog_category_view "1"
    ddev exec magerun2 config:store:set catalog/magento_catalogpermissions/grant_catalog_product_price "1"
    ddev exec magerun2 config:store:set catalog/magento_catalogpermissions/grant_checkout_items "1"
    ddev exec magerun2 config:store:set sales/product_sku/my_account_enable "1"
fi &&

if [ "${INSTALL_HYVA}" = "YES" ] && [ ! -z "${HYVA_COMPOSER_TOKEN}" ] && [ ! -z "${HYVA_COMPOSER_PROJECT}" ]; then
    # TODO: find a more reliable way to check hyva/default theme ID
    if ddev exec magerun2 dev:theme:list | grep -q "spectrum"; then
        ddev exec magerun2 config:store:set design/theme/theme_id 6
    else
        ddev exec magerun2 config:store:set design/theme/theme_id 5
    fi

    ddev exec magerun2 config:store:set customer/captcha/enable 0
fi
ddev magento cache:flush
ddev redis-cli flushall

touch ${GITPOD_REPO_ROOT}/.gitpod/db-installed.flag
gp ports await 8080 && sleep 5 && gp preview $(gp url 8080)
