FROM php:8.2-fpm

# Installation des dépendances système nécessaires
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    default-mysql-client \
    zip

# Installation des dépendances MySQL
RUN docker-php-ext-configure mysqli \
    && docker-php-ext-install mysqli pdo pdo_mysql

# Installation et configuration des extensions PHP nécessaires pour Symfony
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        intl \
        zip \
        gd \
        opcache

# Optimisation des performances PHP
COPY docker/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY docker/php/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Configuration PHP optimisée
RUN echo "memory_limit=512M" > /usr/local/etc/php/conf.d/memory-limit.ini \
    && echo "max_execution_time=60" >> /usr/local/etc/php/conf.d/memory-limit.ini \
    && echo "realpath_cache_size=4096K" >> /usr/local/etc/php/conf.d/memory-limit.ini \
    && echo "realpath_cache_ttl=600" >> /usr/local/etc/php/conf.d/memory-limit.ini \
    && echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/memory-limit.ini \
    && echo "opcache.memory_consumption=512" >> /usr/local/etc/php/conf.d/memory-limit.ini \
    && echo "opcache.max_accelerated_files=40000" >> /usr/local/etc/php/conf.d/memory-limit.ini \
    && echo "opcache.validate_timestamps=1" >> /usr/local/etc/php/conf.d/memory-limit.ini

# Installation de Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Configuration PHP pour le développement
COPY docker/php/php.ini /usr/local/etc/php/php.ini

# APCu pour le cache
RUN pecl install apcu && docker-php-ext-enable apcu

# Configurer les permissions
RUN usermod -u 1000 www-data

WORKDIR /var/www/html

# Nettoyage
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Exposer le port PHP-FPM
EXPOSE 9000