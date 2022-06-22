FROM composer:latest as build
WORKDIR /app
COPY . /app

FROM php:8.0-apache
COPY docker/php.ini /usr/local/etc/php/
RUN apt update
RUN apt install -y git
RUN apt install -y vim
RUN apt install -y zip unzip
RUN docker-php-ext-install bcmath pdo_mysql

# composer install
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
EXPOSE 8080
COPY --from=build /app /var/www
COPY docker/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN chmod 777 -R /var/www

WORKDIR /
RUN echo "Listen 8080" >> /etc/apache2/ports.conf
RUN chown -R www-data:www-data /var/www
RUN a2enmod rewrite

RUN ls /var/www/
RUN ls /var/www/src/

RUN chown -R www-data:www-data /var/www/src/storage
RUN find /var/www/src/storage -type d -exec chmod 775 {} \;
RUN find /var/www/src/storage -type f -exec chmod 664 {} \;
RUN chown www-data:www-data /var/www/src/bootstrap/cache -R
RUN find /var/www/src/bootstrap/cache -type d -exec chmod 775 {} \;

RUN ls -l /var/www/src/storage/logs/
RUN chown 666 /var/www/src/storage/logs/laravel.log
RUN ls -l /var/www/src/storage/logs/
#RUN chown -R www-data:www-data /var/www/env
#RUN /var/www/env -type d -exec chmod 775 {} \;


# Make the file executable, or use "chmod 777" instead of "chmod +x"
RUN chmod +x /var/www/sh/laravel/laravel.prod.sh

# This will run the shell file at the time when container is up-and-running successfully (and NOT at the BUILD time)
ENTRYPOINT ["/var/www/sh/laravel/laravel.prod.sh"]