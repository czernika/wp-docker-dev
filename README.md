# WordPress Local Development Docker Environment

**Docker environment for local WordPress development with Bedrock configuration**

## Introduction

This package provides simple Docker compose environment for WordPress development - just fill in some variables, [start Docker containers](https://docs.docker.com/engine/reference/commandline/compose_up/) with `docker compose up` and you're done! It uses built-in PHP web server and MySQL connection with no fancy configs yet still customizable. By default it works with [Bedrock](https://docs.roots.io/bedrock/master/installation/) site structure

## Content

- [WP-Cli](https://wp-cli.org/)
- PHP 8.0
- MySQL 8
- [Composer](https://getcomposer.org/)
- [NodeJS](https://nodejs.org/en/) (npm)

## Configuration

Fill variables in `.env` file (same meaning as [for Bedrock](https://docs.roots.io/bedrock/master/installation/#getting-started))

- `DB_NAME` - Database name **(required)**
- `DB_USER` - Database user **(required)**
- `DB_PASSWORD` - Database password **(required)**
- `DB_HOST` - Database host
- `DB_PREFIX` - Database prefix
- `WP_HOME` - Full WordPress site home URL **(required)**

There are few more required within `docker-compose.yml` file

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

- `APP_URL` - Should have same value as `WP_HOME` within `.env` file as it has same meaning **(required)**

`APP_URL` should point on localhost in `/etc/hosts` file

User settings:

- `APP_ADMIN_USER` - Admin user name **(required)**
- `APP_ADMIN_EMAIL` - Admin user email **(required)**

These both variables required to create admin user during first run. User password will be generated automatically and stored within `admin-pass.txt` file

> Please DO NOT put this file on production server - better change admin password after WordPress core being installed

There are also two optional variables

- `APP_TITLE` - Website title - same as `get_bloginfo('name')`. Defaulted to "WordPress"
- `APP_LOCALE` - Installation locale. Default is "en_US"

You may notice `WP_CLI_PACKAGES_DIR` variable with predefined value - it sets Wp-Cli packages directory where all [packages will be installed](https://make.wordpress.org/cli/handbook/guides/sharing-wp-cli-packages/#wp_cli_packages_dir-environment-variable). It allows you to keep wp cli packages persistent and not to loose them on a next run

On a first run database named `DB_NAME` will be created and WordPress core installed - so just open your browser at `APP_URL` or `http://127.0.0.1`, login and enjoy

> All `APP_` variables required only on a first run - they are used nowhere else

To run any command use `docker exec -it kawa <command>`

```sh
# Check plugins list
docker exec -it kawa wp plugin list

# Require composer package
docker exec -it kawa composer require <vendor/package>

# Enter shell
docker exec -it kawa bash
```

**Note:** if you wish to enter MySQL shell use another container name - `kawa-db`

```sh
# Enter MySQL shell
docker exec -it kawa-db mysql -u<db_user> -p<db_user_password>

mysql> USE <db_name>;
```

Close containers with `docker compose down`

## Contributing

Fill free to change content of any file depends on your needs. [PRs](https://github.com/czernika/wp-docker-dev/pulls) and [Issues](https://github.com/czernika/wp-docker-dev/issues) are welcome

## TODO

- [ ] Add MailHog support
- [ ] Add Yarn?

## License

Open-source under [MIT license](LICENSE.md)