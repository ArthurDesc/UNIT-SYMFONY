# Configuration Docker pour Symfony

Ce projet utilise Docker pour créer un environnement de développement Symfony. Voici les explications détaillées des différents fichiers de configuration.

## docker-compose.yml

Le fichier `docker-compose.yml` définit l'infrastructure complète de l'application :

```yaml
services:
  nginx:                         # Service Nginx qui sert de serveur web
    image: nginx:alpine         # Utilise l'image officielle Nginx version Alpine (légère)
    ports:
      - "8080:80"              # Expose le port 8080 sur l'hôte, mappé au port 80 du conteneur
    volumes:                    # Montage des volumes
      - ./:/var/www            # Monte le code source dans le conteneur
      - ./nginx/default.conf   # Monte la configuration Nginx
```

Le service PHP :
```yaml
  php:                          # Service PHP-FPM pour exécuter le code PHP
    build: .                    # Construit l'image à partir du Dockerfile local
    volumes:
      - ./:/var/www            # Monte le code source dans le conteneur
```

Le service MySQL :
```yaml
  database:                     # Service de base de données MySQL
    image: mysql:8.0           # Utilise MySQL 8.0
    environment:               # Variables d'environnement pour la configuration
      MYSQL_DATABASE: symfony_db
      MYSQL_ROOT_PASSWORD: root
      MYSQL_PASSWORD: symfony
      MYSQL_USER: symfony
```

## nginx/default.conf

La configuration Nginx gère les requêtes HTTP :

```nginx
server {
    listen 80;                # Écoute sur le port 80
    root /var/www/public;     # Dossier racine de l'application Symfony

    location / {
        try_files $uri /index.php$is_args$args;  # Redirige vers index.php si le fichier n'existe pas
    }

    location ~ ^/index\.php(/|$) {
        fastcgi_pass php:9000;  # Transmet les requêtes PHP au service PHP-FPM
        # Configuration FastCGI pour Symfony
    }
}
```

## Dockerfile

Le Dockerfile configure l'environnement PHP :

```dockerfile
FROM php:8.2-fpm-alpine      # Image de base PHP 8.2 avec FPM sur Alpine Linux

# Installation des dépendances système nécessaires
RUN apk add --no-cache \     # Installe les paquets système requis
    git \
    zip \
    unzip \
    libzip-dev \
    icu-dev

# Installation des extensions PHP requises
RUN docker-php-ext-configure intl && \
    docker-php-ext-install \
    pdo_mysql \              # Support MySQL
    zip \                    # Support ZIP
    intl                     # Support Internationalisation

# Installation de Composer (gestionnaire de dépendances PHP)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www            # Définit le répertoire de travail
EXPOSE 9000                 # Expose le port PHP-FPM
```

## Utilisation

1. Assurez-vous que Docker est installé sur votre système
2. Clonez ce dépôt
3. Lancez l'environnement avec :
   ```bash
   docker-compose up -d
   ```
4. Accédez à l'application via `http://localhost:8080` 