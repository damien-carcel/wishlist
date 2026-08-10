######################################
# PHP CLI image used for development #
######################################

FROM debian:trixie-slim AS base

ENV DEBIAN_FRONTEND=noninteractive\
    PHP_CONF_DATE_TIMEZONE=UTC \
    PHP_CONF_DISPLAY_ERRORS=1 \
    PHP_CONF_DISPLAY_STARTUP_ERRORS=1 \
    PHP_CONF_MAX_EXECUTION_TIME=60 \
    PHP_CONF_MAX_INPUT_VARS=1000 \
    PHP_CONF_MAX_POST_SIZE=40M \
    PHP_CONF_MEMORY_LIMIT=512M \
    PHP_CONF_ERROR_REPORTING=32767 \
    PHP_CONF_UPLOAD_LIMIT=40M \
    PHP_CONF_OPCACHE_VALIDATE_TIMESTAMP=1 \
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
    apt-get -y install lsb-release ca-certificates curl && \
    curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb && \
    dpkg -i /tmp/debsuryorg-archive-keyring.deb && \
    sh -c 'echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' && \
    apt-get update && \
    apt-get --yes install \
        git \
        php8.5-apcu \
        php8.5-cli \
        php8.5-curl \
        php8.5-dom \
        php8.5-intl \
        php8.5-mbstring \
        php8.5-pdo \
        php8.5-pgsql \
        php8.5-zip \
        unzip && \
    apt-get clean && \
    apt-get --yes autoremove --purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p /run/php/

COPY docker/php/app.ini /etc/php/8.5/cli/conf.d/99-app.ini

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer


################################################
# PHP CLI image used for development and tests #
################################################

FROM base AS dev

RUN echo 'APT::Install-Recommends "0" ; APT::Install-Suggests "0" ;' > /etc/apt/apt.conf.d/01-no-recommended && \
    echo 'path-exclude=/usr/share/doc/*' > /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/groff/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/info/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/linda/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/lintian/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/locale/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/man/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    apt-get update && \
    apt-get --yes install php8.5-xdebug && \
    apt-get clean && \
    apt-get --yes autoremove --purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY docker/php/xdebug.ini /etc/php/8.5/cli/conf.d/99-xdebug.ini


###################################################
# Builder image to prepare the app for production #
###################################################

FROM base AS builder

COPY . /app

WORKDIR /app

RUN composer install --no-dev -a && \
    composer dump-env prod && \
    rm -rf /app/var && \
    bin/console --env=prod cache:clear && \
    bin/console --env=prod asset-map:compile


########################################
# FrankenPHP image used for production #
########################################

FROM dunglas/frankenphp:1.12.7-php8.5-trixie AS prod

ENV DEFAULT_URI="https://localhost"
ENV FRANKENPHP_CONFIG="worker ./public/index.php"
ENV SERVER_NAME="localhost"

RUN install-php-extensions \
        apcu \
        curl \
        dom \
        intl \
        mbstring \
        opcache \
        pdo \
        pdo_pgsql \
        zip

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY --from=builder /app/bin /app/bin
COPY --from=builder /app/config /app/config
COPY --from=builder /app/migrations /app/migrations
COPY --from=builder /app/public /app/public
COPY --from=builder /app/src /app/src
COPY --from=builder /app/templates /app/templates
COPY --from=builder /app/var /app/var
COPY --from=builder /app/vendor /app/vendor
COPY --from=builder /app/composer.json /app/composer.json
COPY --from=builder /app/importmap.php /app/importmap.php
COPY --from=builder /app/.env.local.php /app/.env.local.php
