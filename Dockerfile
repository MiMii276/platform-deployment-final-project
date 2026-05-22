# 1. Use the official PHP 8.3 image packaged with the Apache web server
FROM php:8.3-apache

# 2. Install essential system utilities needed for downloading packages
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install pdo_mysql zip # Install PHP database extensions

# 3. Set the working directory inside the container to match our project space
WORKDIR /app

# 4. Change Apache's default path (/var/www/html) to look at Symfony's /app/public folder
ENV APACHE_DOCUMENT_ROOT /app/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 5. Enable Apache's mod_rewrite module so pretty URLs work seamlessly
RUN a2enmod rewrite

# 6. Change Apache's port from 80 to 8000 to line up with our container port mapping
RUN sed -i 's/Listen 80/Listen 8000/g' /etc/apache2/ports.conf /etc/apache2/sites-available/*.conf

# 7. Download the official Composer package manager directly into our build stage
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 8. Copy all files from your computer's local directory into the container's /app directory
COPY . /app

# 9. Force production mode environment variables for the build stage
ENV APP_ENV=prod
ENV COMPOSER_ALLOW_SUPERUSER=1

# 10. Install Symfony dependencies for production safely
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# 11. Grant file permission ownership to Apache's default execution user (www-data)
RUN chown -R www-data:www-data /app

# 12. Document that this container will broadcast traffic out of port 8000
EXPOSE 8000