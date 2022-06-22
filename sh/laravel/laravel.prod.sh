#!/bin/bash

# erreur stream : https://stackoverflow.com/questions/64551170/laravel-the-stream-or-file-storage-laravel-log-could-not-be-opened-in-append-m
chown -R www-data:www-data ./storage
find ./storage -type d -exec chmod 775 {} \;
find ./storage -type f -exec chmod 664 {} \;
sudo chown www-data:www-data ./bootstrap/cache -R
find ./bootstrap/cache -type d -exec chmod 775 {} \;
chown -R www-data:www-data .env
find .env -type d -exec chmod 775 {} \;

# initialize laravel
cd /var/www/src
composer install
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run Laravel migration (by force, since it would be a prod-environment)
php artisan migrate --force

# Run Apache in "foreground" mode (the default mode that runs in Docker)
apache2-foreground