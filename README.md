# WordPress Local Development Docker Environment

**Docker environment for local WordPress development with Bedrock configuration**

## Introduction

This package provides simple Docker environment for WordPress development - just fill some variables, up Docker container and you're done! It uses built-in PHP web server and MySQL connection with no fancy configs yet still customizable. By default it works with Bedrock site structure

Comes with [Wp-Cli](https://wp-cli.org/), [Composer](https://getcomposer.org/) and [NodeJS](https://nodejs.org/en/) (npm) installed

## Configuration

On a first run fill variables in `.env` file (same meaning as [for Bedrock](https://docs.roots.io/bedrock/master/installation/#getting-started))

There are few more within `docker-compose.yml` file

```yml
app:
    container_name: kawa
    build:
      context: ./docker
      dockerfile: Dockerfile
    image: czernika/kawa-8.0
    volumes:
      - .:/var/www/html
      - ./docker/php.ini:/usr/local/etc/php/conf.d/php.ini
    ports:
      - 80:80
    environment:
      WP_CLI_PACKAGES_DIR: /var/www/html/.wp-cli/packages
      APP_URL: ${WP_HOME}
      APP_ADMIN_USER: 'wolat'
      APP_ADMIN_EMAIL: 'wolat@example.com'
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      - bedrock
```

Here within `environment` section you should fill some variables

- `APP_URL` - full WordPress site home URL. Should have same value as `WP_HOME`

User settings:

- `APP_ADMIN_USER` - admin user name
- `APP_ADMIN_EMAIL` - admin user email

These both variables required to create an admin user during first run. User password will be created in a `admin-pass.txt` file

> Please DO NOT put this file on production server or better change admin password after WordPress core being installed

There are also two optional variables

- `APP_TITLE` - website title - same as `get_bloginfo('name')`. Defaulted to "WordPress"
- `APP_LOCALE` - installation locale. Default is `en_US`

You may notice `WP_CLI_PACKAGES_DIR` variable with predefined value - it sets Wp-Cli packages directory where all packages will be installed. It allows you to keep wp cli packages persistent and not to loose them on a next run

On a first run database name `DB_NAME` will be created and WordPress core installed - so just visit browser, login and enjoy

To run any command use `docker exec -it kawa <command>`

```sh
# Check plugins list
docker exec -it kawa wp plugin list

# Require composer package
docker exec -it kawa composer require <vendor/package>

# Enter shell
docker exec -it kawa bash
```

Note: if you wish to enter MySQL shell use another container name - `kawa-db`

```sh
# Enter MySQL shell
docker exec -it kawa-db mysql -uwolat -ppassword

mysql> USE <database_name>;
```

## TODO

- Add MailHog support
- Add Yarn?

## License

Open-source under [MIT license](LICENSE.md)