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

## Types d'Installation Symfony

Symfony propose deux types d'installation principaux :

### 1. symfony/website-skeleton (Installation Complète)

```bash
composer create-project symfony/website-skeleton my-project
```

Cette installation est celle utilisée dans le dossier `app/`. C'est une version complète qui inclut :
- Tous les composants essentiels de Symfony
- Doctrine ORM pour la gestion de base de données
- Twig pour les templates
- Security bundle pour la sécurité
- Forms et Validator pour la gestion des formulaires
- Mailer pour l'envoi d'emails
- Profiler et Debug bundle pour le développement
- Tests unitaires et fonctionnels
- Asset management
- Internationalisation

Idéal pour :
- Applications web complètes
- Sites avec backend administratif
- Projets nécessitant de nombreuses fonctionnalités
- Applications complexes avec beaucoup de fonctionnalités

### 2. symfony/skeleton (Installation Minimale)

```bash
composer create-project symfony/skeleton my-project
```

Cette installation est celle utilisée dans le dossier `app-skeleton/`. C'est une version minimaliste qui inclut uniquement :
- Le framework de base Symfony
- Le système de routage
- Le conteneur de services
- Le composant HTTP Foundation
- Flex pour la gestion des recettes

Idéal pour :
- Microservices
- APIs REST
- Applications légères
- Projets où vous voulez ajouter uniquement les composants nécessaires
- Applications personnalisées avec des besoins spécifiques

### Principales différences

1. **Taille du projet** :
   - website-skeleton : ~100MB (avec vendor)
   - skeleton : ~30MB (avec vendor)

2. **Nombre de dépendances** :
   - website-skeleton : ~100 packages
   - skeleton : ~30 packages

3. **Configuration** :
   - website-skeleton : Configuration complète pour tous les composants
   - skeleton : Configuration minimale, à enrichir selon les besoins

4. **Performance** :
   - website-skeleton : Plus lourd au démarrage
   - skeleton : Démarrage plus rapide, empreinte mémoire plus légère

## Utilisation

1. Assurez-vous que Docker est installé sur votre système
2. Clonez ce dépôt
3. Lancez l'environnement avec :
   ```bash
   docker-compose up -d
   ```
4. Accédez à l'application via `http://localhost:8080` 