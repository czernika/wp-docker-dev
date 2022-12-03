# WordPress Local Development Docker Environment

Docker environment for local WordPress development (supports [Bedrock](https://docs.roots.io/bedrock/master/installation/) configuration)

## Introduction

This package provides simple Docker compose environment for **WordPress local development** - just fill in variables for your site, [start Docker containers](https://docs.docker.com/engine/reference/commandline/compose_up/) with `docker compose up` command and you're done! Check your browser - you'll see your site have been installed **already** - no need to download WordPress core and create database - it all has been done for you!

It uses built-in PHP web server and MySQL connection with no fancy configs yet still customizable. This is why we're not recommending this package in production - any other web-server provides much more options. However in a development process most of the time all you need is to run simple working server

By default it install WordPress core into `wordpress` directory but you may provide any custom directory plus you may specify if you want to install Bedrock configuration

## Installation

> This package requires [Docker](https://www.docker.com/) installed on your local machine

Just clone this repository

```sh
git clone git@github.com:czernika/wp-docker-dev.git <project>
```

Set required variables in a `.env` file and run command

```sh
docker compose up -d
```

## Content

This package comes with

- [WP-Cli](https://wp-cli.org/)
- PHP 8.0
- MySQL 8
- [Composer](https://getcomposer.org/)
- [NodeJS](https://nodejs.org/en/) (npm)

## Configuration

### Database connection

- `DB_NAME` - Database name **(required)**
- `DB_USER` - Database user **(required)**
- `DB_PASSWORD` - Database password **(required)**
- `DB_PREFIX` - Database prefix

Note: no need to specify database host - it will be set as `kawa-db` by default (same as MySQL container name)

### App settings

- `APP_URL` - Application url. Basically same thing as `WP_HOME` for Bedrock - full home WordPress url. Default `http://127.0.0.1`
- `APP_ADMIN_USER` - Admin user name **(required)**
- `APP_ADMIN_EMAIL` - Admin user email **(required)**
- `APP_TITLE` - Website title. Default `WordPress`
- `APP_LOCALE` - Language of installed WordPress site. Default `en_US`

> `APP_URL` should point on localhost in `/etc/hosts` file (we're assuming you're working on a local machine)

### WordPress settings

Within `docker-compose.yml` in `environment` section you may note some other variables like `WP_CLI_PACKAGES_DIR` and `WP_CLI_CACHE_DIR` with predefined values - they set WP-Cli directories where all [packages will be installed](https://make.wordpress.org/cli/handbook/guides/sharing-wp-cli-packages/#wp_cli_packages_dir-environment-variable). It allows you to keep wp cli packages persistent and not to loose them on a next run

There is also one setting - `IS_BEDROCK` - set `0` if you wish to install regular WordPress or `1` if you prefer to use Bedrock configuration

On a first run database named `DB_NAME` will be created and WordPress core installed - so just open your browser at `APP_URL` or `http://127.0.0.1`, log in and enjoy

## Usage

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

## TODO (Things to consider)

- Add MailHog support

## License

Open-source under [MIT license](LICENSE.md)