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

# Installation de Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Configuration PHP pour le développement
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# Configurer les permissions
RUN usermod -u 1000 www-data

WORKDIR /var/www/html

# Exposer le port PHP-FPM
EXPOSE 9000