#!/bin/bash

WORKDIR=$(pwd)

# Duplicating variable values as there are plans to separate them
APP_CORE_PATH=$WORKDIR

# For Bedrock these values will be rewritten
APP_WEB_CORE_PATH=$APP_CORE_PATH
APP_WP_CORE_PATH=$APP_CORE_PATH

ADMIN_PASS_FILE="$WORKDIR/admin-pass.txt"

function is_bedrock()
{
    [ $IS_BEDROCK -eq 1 ]
}

function wp_core_is_installed()
{
    $(wp core is-installed --path=$APP_WP_CORE_PATH)
}

function empty_installation_dir()
{
    rm -r $WORKDIR/{.[!.]*,*}
}

function replace_env()
{
    sed -i "s/database_name/$DB_NAME/g" $ENV_FILE
    sed -i "s/database_user/$DB_USER/g" $ENV_FILE
    sed -i "s/database_password/$DB_PASSWORD/g" $ENV_FILE

    sed -i "s/# DB_HOST='localhost'/DB_HOST='kawa-db'/g" $ENV_FILE
    sed -i "s/# DB_PREFIX='wp_'/DB_PREFIX='$DB_PREFIX'/g" $ENV_FILE

    sed -i "s#http://example.com#$APP_URL#g" $ENV_FILE
}


# If this is Bedrock installation
# Point web server into `web` subdirectory
if is_bedrock; then
    APP_WEB_CORE_PATH="$APP_CORE_PATH/web"
    APP_WP_CORE_PATH="$APP_WEB_CORE_PATH/wp"
fi

echo "App core path: $APP_CORE_PATH"
echo "WordPress core path: $APP_WP_CORE_PATH"

# Install WordPress core if not installed
if ! wp_core_is_installed; then

    if [[ -z "$APP_ADMIN_USER" ]]; then
        echo "APP_ADMIN_USER variable was not set"
        exit 1
    fi

    if [[ -z "$APP_ADMIN_EMAIL" ]]; then
        echo "APP_ADMIN_EMAIL variable was not set"
        exit 1
    fi

    # Download WordPress Core depends on environemnt
    if is_bedrock; then

        ENV_FILE="$APP_CORE_PATH/.env"

        # Empty directory before first run
        empty_installation_dir

        composer create-project roots/bedrock . --prefer-dist

        # Composer.json not found - probably some error during installation
        if [ ! -f $APP_CORE_PATH/composer.json ]; then
            echo "Reverting installation..."
            empty_installation_dir

            exit 1
        fi

        if [ ! -f $ENV_FILE ]; then
            echo "$ENV_FILE file not found"

            cp $APP_CORE_PATH/.env.example $ENV_FILE
        fi

        replace_env

        if [[ ! ($APP_LOCALE == "en_US") ]]; then
            wp language core install $APP_LOCALE --path=$APP_WP_CORE_PATH --activate
        fi
    else
        wp core download --path=$APP_WP_CORE_PATH --locale=$APP_LOCALE

        wp config create --path=$APP_WP_CORE_PATH --dbname=$DB_NAME --dbuser=$DB_USER --dbpass="$DB_PASSWORD" --dbhost='kawa-db' --dbprefix=$DB_PREFIX --locale=$APP_LOCALE
    fi

    # Generate password
    PASSWORD=$(tr -dc 'A-Za-z0-9!#$%&()*+-<=>?@^_|~' </dev/urandom | head -c 16)

    echo "Generated admin password is: $PASSWORD"
    echo "Check $ADMIN_PASS_FILE file with generated password"

    echo "Installing WordPress..."
    wp core install --path=$APP_WP_CORE_PATH --url=$APP_URL --title="$APP_TITLE" --admin_user=$APP_ADMIN_USER --admin_password=$PASSWORD --admin_email=$APP_ADMIN_EMAIL --skip-email 

cat > $ADMIN_PASS_FILE<< EOF
# Generated password is:
# Please save this password somewhere else or change it and delete this file after
# DO NOT deploy this file on production server

$PASSWORD
EOF

    # Check if installation was succesfull
    if ! wp_core_is_installed; then
        echo "Something went wrong during installation"
        echo "Erasing admin password..."

        echo "# Something went wrong during installation" > $ADMIN_PASS_FILE

        exit 1
    fi

fi

# Start PHP Web Server
php -S 0.0.0.0:80 -t $APP_WEB_CORE_PATH