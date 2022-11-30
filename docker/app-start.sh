#!/bin/bash

APP_DEFAULT_TITLE='WordPress'
APP_DEFAULT_LOCALE='en_US'

# Install WordPress core if not installed
if ! $(wp core is-installed); then
    if [[ -z $APP_URL ]]; then
        echo "APP_URL variable was not set"
        exit 1
    fi

    if [[ -z "$APP_ADMIN_USER" ]]; then
        echo "APP_ADMIN_USER variable was not set"
        exit 1
    fi

    if [[ -z "$APP_ADMIN_EMAIL" ]]; then
        echo "APP_ADMIN_EMAIL variable was not set"
        exit 1
    fi

    if [[ -z "$APP_TITLE" ]]; then
        echo "APP_TITLE variable was not set. Defaulting to '$APP_DEFAULT_TITLE'"
        APP_TITLE=$APP_DEFAULT_TITLE
    fi

    if [[ -z "$APP_LOCALE" ]]; then
        echo "APP_LOCALE variable was not set. Defaulting to '$APP_DEFAULT_LOCALE'"
        APP_LOCALE=$APP_DEFAULT_LOCALE
    fi

    # Generate password
    PASSWORD=$(tr -dc 'A-Za-z0-9!#$%&()*+-<=>?@^_|~' </dev/urandom | head -c 16)

    echo "Generated admin password is: $PASSWORD"
    echo "Check generated 'admin-pass.txt' file with generated password"

cat > /var/www/html/admin-pass.txt<< EOF
# Generated password is:
# Please save this password somewhere else or change it and delete this file after
# DO NOT deploy this file on production server
$PASSWORD
EOF

    # Check if installation was succesfull
    if ! $(wp core is-installed); then
        echo "Something went wrong during installation"
        echo "Erasing admin password..."
        echo "# Something went wrong during installation" > /var/www/html/admin-pass.txt

        exit 1
    fi
fi

# Start PHP Web Server
exec php -S 0.0.0.0:80 -t /var/www/html/web