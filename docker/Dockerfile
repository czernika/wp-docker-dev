FROM ubuntu:22.04

ARG id=1000
ARG user=kawa

WORKDIR /var/www/html

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y software-properties-common \
    less \
    curl \
    zip \
    unzip \
    nano \
    git

# Install PHP
RUN add-apt-repository ppa:ondrej/php \
    && apt-get update

# Install PHP extensions
# https://make.wordpress.org/hosting/handbook/server-environment/#php-extensions
RUN apt-get install -y php8.0-common php8.0-cli php8.0-fpm \
    php8.0-gd php8.0-curl php8.0-mysql php8.0-mbstring \
    php8.0-xml php8.0-zip php8.0-bcmath php8.0-intl \
    php8.0-gd php8.0-imagick php8.0-pcov php8.0-xdebug \
    && apt-get install -y mariadb-client

RUN update-alternatives --set php /usr/bin/php8.0

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs \
    && npm install -g npm

# Add user
# To run wp-cli and composer commands
RUN useradd -m -G www-data,root -u $id $user
RUN mkdir -p /home/$user/.composer \
    && chown -R $user:$user /var/www/html

RUN apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./app-start.sh /usr/local/bin/app-start.sh
RUN chmod +x /usr/local/bin/app-start.sh

USER $user

CMD [ "/usr/local/bin/app-start.sh" ]
