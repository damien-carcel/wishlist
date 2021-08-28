######################################
# Base image for common dependencies #
# between development and production #
######################################

FROM debian:buster-slim as base

ENV DEBIAN_FRONTEND=noninteractive\
    PHP_CONF_DATE_TIMEZONE=UTC \
    PHP_CONF_DISPLAY_ERRORS=0 \
    PHP_CONF_DISPLAY_STARTUP_ERRORS=0 \
    PHP_CONF_MAX_EXECUTION_TIME=60 \
    PHP_CONF_MAX_INPUT_VARS=1000 \
    PHP_CONF_MAX_POST_SIZE=40M \
    PHP_CONF_MEMORY_LIMIT=512M \
    PHP_CONF_ERROR_REPORTING=22527 \
    PHP_CONF_UPLOAD_LIMIT=40M \
    PHP_CONF_OPCACHE_VALIDATE_TIMESTAMP=0 \
    PHP_CONF_ZEND_ASSERTIONS=-1

RUN echo 'APT::Install-Recommends "0" ; APT::Install-Suggests "0" ;' > /etc/apt/apt.conf.d/01-no-recommended && \
    echo 'path-exclude=/usr/share/doc/*' > /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/groff/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/info/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/linda/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/lintian/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/locale/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/man/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    apt-get update && \
    apt-get --yes install apt-transport-https ca-certificates gpg gpg-agent wget && \
    echo 'deb https://packages.sury.org/php/ buster main' > /etc/apt/sources.list.d/sury.list && \
    wget -O sury.gpg https://packages.sury.org/php/apt.gpg && apt-key add sury.gpg && rm sury.gpg && \
    apt-get update && \
    apt-get --yes install \
        php8.0-apcu \
        php8.0-cli \
        php8.0-curl \
        php8.0-dom \
        php8.0-fpm \
        php8.0-intl \
        php8.0-mbstring \
        php8.0-opcache \
        php8.0-pdo \
        php8.0-pgsql \
        php8.0-zip && \
    apt-get clean && \
    apt-get --yes autoremove --purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    ln -s /usr/sbin/php-fpm8.0 /usr/local/sbin/php-fpm && \
    mkdir -p /run/php/

COPY docker/php/wishlist.ini /etc/php/8.0/cli/conf.d/99-wishlist.ini
COPY docker/php/wishlist.ini /etc/php/8.0/fpm/conf.d/99-wishlist.ini
COPY docker/php/fpm.conf /etc/php/8.0/fpm/pool.d/zzz-wishlist.conf

######################################
# PHP CLI image used for development #
######################################

FROM base as dev

ENV XDEBUG_ENABLED=0

# Install Git and XDEBUG
RUN apt-get update && \
    apt-get --yes install \
        git \
        php8.0-xdebug \
        unzip && \
    apt-get clean && \
    apt-get --yes autoremove --purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure XDEBUG and make XDEBUG activable at container start
COPY docker/php/xdebug.ini /etc/php/8.0/cli/conf.d/99-wishlist-xdebug.ini
COPY docker/php/xdebug.ini /etc/php/8.0/fpm/conf.d/99-wishlist-xdebug.ini

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

#######################################
# Intermediate image used to prepare  #
# the application for production      #
#######################################

FROM dev as back-end-builder

ENV COMPOSER_CACHE_DIR=/tmp/composer/cache
ENV APP_ENV=prod
ENV APP_DEBUG=0

WORKDIR /var/www/html

COPY . .
RUN mkdir -p /tmp/composer/cache && \
    composer install --optimize-autoloader --no-interaction --no-scripts --prefer-dist --no-dev && \
    composer dump-env prod && \
    bin/console ca:c

#######################################
# Intermediate image used to prepare  #
# the application for production      #
#######################################

FROM node:slim as front-end-builder

ENV YARN_CACHE_FOLDER=/tmp/yarn/cache

WORKDIR /var/www/html

COPY --from=back-end-builder /var/www/html /var/www/html
RUN mkdir -p /tmp/yarn/cache && \
    yarn install --frozen-lockfile --check-files && \
    yarn build

###############################
# Image used for production   #
# It contains the application #
###############################

FROM base as fpm

ENV APP_ENV=prod
ENV APP_DEBUG=0

WORKDIR /var/www/html
VOLUME /var/www/html/public

COPY --from=front-end-builder /var/www/html/bin /var/www/html/bin
COPY --from=front-end-builder /var/www/html/config /var/www/html/config
COPY --from=front-end-builder /var/www/html/migrations /var/www/html/migrations
COPY --from=front-end-builder /var/www/html/public /var/www/html/public
COPY --from=front-end-builder /var/www/html/src /var/www/html/src
COPY --from=front-end-builder /var/www/html/templates /var/www/html/templates
COPY --from=front-end-builder /var/www/html/translations /var/www/html/translations
COPY --from=front-end-builder /var/www/html/var/cache/prod /var/www/html/var/cache/prod
COPY --from=front-end-builder /var/www/html/vendor /var/www/html/vendor
COPY --from=front-end-builder /var/www/html/.env.local.php /var/www/html/.env.local.php
COPY --from=front-end-builder /var/www/html/composer.json /var/www/html/composer.json
COPY --from=front-end-builder /var/www/html/composer.lock /var/www/html/composer.lock

RUN chown -R www-data:www-data /var/www/html
