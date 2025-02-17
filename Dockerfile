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
RUN apt-get install -y default-mysql-client default-libmysqlclient-dev \
    && docker-php-ext-configure mysqli \
    && docker-php-ext-install mysqli

# Installation et configuration des extensions PHP nécessaires pour Symfony
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        intl \
        zip \
        gd \
        opcache

# Installation de l'extension PDO MySQL
RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql \
    && docker-php-ext-install pdo pdo_mysql

# Optimisation des performances PHP
COPY docker/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Configuration PHP optimisée
RUN echo "memory_limit=256M" > /usr/local/etc/php/conf.d/memory-limit.ini \
    && echo "max_execution_time=30" >> /usr/local/etc/php/conf.d/memory-limit.ini \
    && echo "realpath_cache_size=4096K" >> /usr/local/etc/php/conf.d/memory-limit.ini \
    && echo "realpath_cache_ttl=600" >> /usr/local/etc/php/conf.d/memory-limit.ini

# Installation de Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Configuration PHP pour le développement
COPY docker/php/php.ini /usr/local/etc/php/php.ini

# Configurer les permissions
RUN usermod -u 1000 www-data

WORKDIR /var/www/html

# Exposer le port PHP-FPM
EXPOSE 9000