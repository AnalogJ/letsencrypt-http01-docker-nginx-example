#!/usr/bin/env bash

# set the letsencrypt domain to test.example.com if its not already set as an environmental variable.
export LETSENCRYPT_DOMAIN=${LETSENCRYPT_DOMAIN:-"test.example.com"}

echo "Populate confd templates"
confd -onetime -backend env

echo "Enable the http endpoint"
ln -s /etc/nginx/sites-available/http.conf /etc/nginx/sites-enabled/http.conf

echo "Starting nginx service..."
service nginx start

echo "Generate Letsencrypt SSL certificates"
/srv/letsencrypt/letsencrypt.sh --cron

echo "Register Letsencrypt to run weekly"
echo "5 8 * * 7 root /srv/letsencrypt/letsencrypt.sh --cron && service nginx reload" > /etc/cron.d/letsencrypt.sh
chmod u+x  /etc/cron.d/letsencrypt.sh

echo "Enable the https endpoint"
ln -s /etc/nginx/sites-available/https.conf /etc/nginx/sites-enabled/https.conf

echo "Reload nginx service..."
service nginx reload

#tail -f /var/log/nginx/error.log -f /var/log/nginx/access.log -f /var/log/nginx/https.log -f /var/log/nginx/http.log