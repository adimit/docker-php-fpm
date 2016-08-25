FROM php:7-fpm
MAINTAINER Sascha Marcel Schmidt <docker@saschaschmidt.net>

ENV COMPOSER_HOME=/usr/local/lib/composer/
ENV COMPOSER_CACHE_DIR=/tmp/composer/cache/
ENV COMPOSER_BIN_DIR=/usr/local/lib/composer/bin/
ENV PATH=${PATH}:/usr/local/lib/composer/bin

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        imagemagick \
        libmagickwand-dev \
        openssh-client \
        sudo \
        git \
        libmemcached-dev \
        libssl-dev \
        libpng12-dev \
        libjpeg-dev \
        re2c \
        libfreetype6-dev \
        libmcrypt-dev \
        libxml2-dev && \
    rm -r /var/lib/apt/lists/*


RUN cd /tmp/ && \
    mkdir -p /usr/src/php/ext && \
    curl -O http://pecl.php.net/get/xdebug-2.4.0.tgz && \
    tar zxvf xdebug-2.4.0.tgz && \
    mv xdebug-2.4.0 /usr/src/php/ext/xdebug && \
    curl -O https://pecl.php.net/get/mongodb-1.1.5.tgz && \
    tar zxvf mongodb-1.1.5.tgz && \
    mv mongodb-1.1.5 /usr/src/php/ext/mongodb && \
    curl -O https://pecl.php.net/get/imagick-3.4.3RC1.tgz && \
    tar zxvf imagick-3.4.3RC1.tgz && \
    mv imagick-3.4.3RC1 /usr/src/php/ext/imagick && \
    git clone https://github.com/php-memcached-dev/php-memcached.git /usr/src/php/ext/memcached && \
    cd /usr/src/php/ext/memcached && \
    git checkout php7 && \
    git clone https://github.com/phpredis/phpredis.git /usr/src/php/ext/redis && \
    cd /usr/src/php/ext/redis && \
    git checkout php7 && \
    echo 'xdebug' >> /usr/src/php-available-exts && \
    echo 'mongodb' >> /usr/src/php-available-exts && \
    echo 'imagick' >> /usr/src/php-available-exts && \
    echo 'memcached' >> /usr/src/php-available-exts && \
    echo 'redis' >> /usr/src/php-available-exts && \
    cd / && \
    rm -rf /tmp/*

RUN cd /usr/src/ && tar -xf php.tar.xz && cp -rf php-${PHP_VERSION}/* php && cd /var/www/html && \
    docker-php-ext-configure gd --with-jpeg-dir --with-png-dir --with-freetype-dir && \
    docker-php-ext-install \
    imagick \
    xdebug \
    soap \
    iconv \
    mcrypt \
    mbstring \
    pdo_mysql \
    mysqli \
    zip \
    bcmath \
    opcache \
    mongodb \
    memcached \
    redis \
    pcntl && \
    rm -rf /usr/src/php*

RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer && \
    composer global require codeception/codeception:~2.1 \
                            squizlabs/php_codesniffer:~2.5 \
                            robmorgan/phinx:~0.5.3 && \
    phpcs --config-set ignore_warnings_on_exit 1 && \
    phpcs --config-set show_progress 1 && \
    phpcs --config-set default_standard PSR2

RUN addgroup superuser && \
    echo '%superuser        ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers

VOLUME ["/tmp/composer/cache"]
CMD ["php-fpm"]

COPY templates/ /usr/local/templates/
COPY fpm/ /usr/local/etc/php/fpm/pool.d/
COPY php/ /usr/local/etc/php/conf.d/

ENTRYPOINT ["bash", "-i", "/usr/local/bin/entrypoint.sh"]
COPY bin/* /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
