######################################
# Base image for common dependencies #
# between development and production #
######################################

FROM debian:trixie-slim AS base

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
    apt-get -y install lsb-release ca-certificates curl && \
    curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb && \
    dpkg -i /tmp/debsuryorg-archive-keyring.deb && \
    sh -c 'echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' && \
    apt-get update && \
    apt-get --yes install \
        php8.5-apcu \
        php8.5-cli \
        php8.5-curl \
        php8.5-dom \
        php8.5-fpm \
        php8.5-intl \
        php8.5-mbstring \
        php8.5-pdo \
        php8.5-pgsql \
        php8.5-zip && \
    apt-get clean && \
    apt-get --yes autoremove --purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p /run/php/

COPY app.ini /etc/php/8.5/cli/conf.d/99-app.ini

######################################
# PHP CLI image used for development #
######################################

FROM base AS dev

ENV XDEBUG_ENABLED=0

# Install Git and XDEBUG
RUN apt-get update && \
    apt-get --yes install \
        git \
        php8.5-xdebug \
        unzip && \
    apt-get clean && \
    apt-get --yes autoremove --purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure XDEBUG and make XDEBUG activable at container start
COPY xdebug.ini /etc/php/8.5/cli/conf.d/99-xdebug.ini

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer
