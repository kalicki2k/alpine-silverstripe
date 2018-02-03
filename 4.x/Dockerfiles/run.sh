#!/bin/sh
#
# Version: 1.0
# Purpose:
#   - Creating required folder and setup error pages for Apache
#   - Installing SilverStripe CMS and Framework via Composer
#   - Generating environment file for SilverStripe
#   - Starting Apache damon
#

CGI_PATH=/var/www/localhost/cgi-bin
DOCUMENT_ROOT=/var/www/localhost/htdocs
ERROR_PATH=/var/www/localhost/error
ERROR_SKEL_PATH=/var/www/skel/error
LOGS_PATH=/var/www/localhost/logs

#
# Checks if required folder exists. If not, it will be created.
#
if [[ ! -d ${CGI_PATH} ]]; then
    mkdir ${CGI_PATH}
fi

if [[ ! -d ${DOCUMENT_ROOT} ]]; then
    mkdir ${DOCUMENT_ROOT}
fi

if [[ ! -d ${LOGS_PATH} ]]; then
    mkdir ${LOGS_PATH}
fi

if [[ ! -d ${ERROR_PATH} ]]; then
    cp -r ${ERROR_SKEL_PATH} ${ERROR_PATH}
fi

#
# Install SilverStripe cms and framework
#
if [[ ! "$(ls -A ${DOCUMENT_ROOT})" ]]; then

    if [[ -z ${SS_VERSION} ]]; then
        SS_VERSION=4.0.1
    fi

    composer create-project silverstripe/installer ${DOCUMENT_ROOT} ${SS_VERSION}
fi

#
# Setup SilverStripe environment
#
if [[ ! -f ${DOCUMENT_ROOT}/.env ]]; then

    if [[ -z ${SS_ENVIRONMENT_TYPE} ]]; then
        SS_ENVIRONMENT_TYPE=dev
    fi

    if [[ -z ${SS_DATABASE_CLASS} ]]; then
        SS_DATABASE_CLASS=MySQLPDODatabase
    fi

    if [[ -z ${SS_DATABASE_SERVER} ]]; then
        SS_DATABASE_SERVER=mariadb
    fi

    if [[ -z ${SS_DATABASE_NAME} ]]; then
        SS_DATABASE_NAME=SS_mysite
    fi

    if [[ -z ${SS_DATABASE_USERNAME} ]]; then
        SS_DATABASE_USERNAME=root
    fi

    if [[ -z ${SS_DATABASE_PASSWORD} ]]; then
        SS_DATABASE_PASSWORD=root
    fi

    if [[ -z ${SS_DEFAULT_ADMIN_USERNAME} ]]; then
        SS_DEFAULT_ADMIN_USERNAME=admin
    fi

    if [[ -z ${SS_DEFAULT_ADMIN_PASSWORD} ]]; then
        SS_DEFAULT_ADMIN_PASSWORD=admin
    fi

    cat > ${DOCUMENT_ROOT}/.env << EOL
SS_ENVIRONMENT_TYPE="${SS_ENVIRONMENT_TYPE}"
SS_DATABASE_CLASS="${SS_DATABASE_CLASS}"
SS_DATABASE_SERVER="${SS_DATABASE_SERVER}"
SS_DATABASE_NAME="${SS_DATABASE_NAME}"
SS_DATABASE_USERNAME="${SS_DATABASE_USERNAME}"
SS_DATABASE_PASSWORD="${SS_DATABASE_PASSWORD}"
SS_DEFAULT_ADMIN_USERNAME="${SS_DEFAULT_ADMIN_USERNAME}"
SS_DEFAULT_ADMIN_PASSWORD="${SS_DEFAULT_ADMIN_PASSWORD}"
EOL
fi

#
# Make sure we're not confused by old, incompletely-shutdown httpd context after restarting the container.
# httpd won't start correctly if it thinks it is already running.
#
rm -rf /run/apache2/*

#
# Starting Apache daemon
#
exec /usr/sbin/httpd -D FOREGROUND
