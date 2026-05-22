# 1. Use the official PHP 8.2 image packaged with the Apache web server
FROM php:8.2-apache

# 2. Install essential system utilities needed for downloading packages
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install pdo_mysql zip

# 3. Set the working directory inside the container to match our project space
WORKDIR /app

# 4. Change Apache's default path (/var/www/html) to look at Symfony's /app/public folder
ENV APACHE_DOCUMENT_ROOT /app/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 5. Enable Apache's mod_rewrite module so pretty URLs (e.g., /home, /login) work
RUN a2enmod rewrite

# 6. Explicitly ensure directory permissions are granted to Apache for Symfony's public directory
RUN echo "<Directory /app/public>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride All\n\tRequire all granted\n</Directory>" >> /etc/apache2/apache2.conf

# 7. Download the official Composer package manager directly into our build stage
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 8. Copy all files from your computer's local directory into the container's /app directory
COPY . /app

# 9. Run composer install to compile Symfony dependencies for production
RUN composer install --no-dev --optimize-autoloader --no-interaction

# 10. Grant file permission ownership to Apache's default execution user (www-data)
RUN chown -R www-data:www-data /app

# 11. Document that this container will broadcast traffic out of port 80
EXPOSE 80