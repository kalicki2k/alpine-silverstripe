#!/bin/sh
#
# Purpose: Installing Silverstripe CMS and starting Apache damon
# Version: 1.0
#

CGI_PATH=/var/www/localhost/cgi-bin
DOCUMENT_ROOT=/var/www/localhost/htdocs
ERROR_PATH=/var/www/localhost/error
ERROR_SKEL_PATH=/var/www/skel/error
LOGS_PATH=/var/www/localhost/logs
SS_VERSION=4.0.1

#
# Checks if required folder exists. If not, it will be created.
#
if [[ ! -d ${CGI_PATH} ]]
then
    mkdir ${CGI_PATH}
fi

if [[ ! -d ${DOCUMENT_ROOT} ]]
then
    mkdir ${DOCUMENT_ROOT}
fi

if [[ ! -d ${LOGS_PATH} ]]
then
    mkdir ${LOGS_PATH}
fi

if [[ ! -d ${ERROR_PATH} ]]
then
    cp -r ${ERROR_SKEL_PATH} ${ERROR_PATH}
fi

#
# Install silverstripe cms and framework
#
if [ ! "$(ls -A ${DOCUMENT_ROOT})" ]; then
    composer create-project silverstripe/installer ${DOCUMENT_ROOT} ${SS_VERSION}
fi

#
# Make sure we're not confused by old, incompletely-shutdown httpd context after restarting the container.
# httpd won't start correctly if it thinks it is already running.
#
rm -rf /run/apache2/*

#
# Starting Apache daemon...
#
exec /usr/sbin/httpd -D FOREGROUND
