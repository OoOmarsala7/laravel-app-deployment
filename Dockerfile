# FROM composer:latest AS composer

# FROM php:8.1.0-apache

# WORKDIR /var/www/html

# RUN apt-get update -y && apt-get install -y \
#     libicu-dev \
#     libmariadb-dev \
#     unzip \
#     zip \
#     zlib1g-dev \
#     libpng-dev \
#     libjpeg62-turbo-dev \
#     libfreetype6-dev \
#     netcat \
#     && docker-php-ext-configure gd --with-freetype --with-jpeg \
#     && docker-php-ext-install -j$(nproc) gd \
#     && docker-php-ext-install -j$(nproc) gettext intl pdo_mysql

# COPY --from=composer /usr/bin/composer /usr/bin/composer

# COPY . /var/www/html

# RUN chown -R www-data:www-data /var/www/html

# RUN composer install --no-dev --optimize-autoloader

# RUN a2enmod rewrite



# RUN php artisan key:generate 
# RUN php artisan migrate 

# # Expose port 80
# EXPOSE 80

# # Start Apache
# CMD ["apache2-foreground"]

# First stage: Use the composer image to get Composer
FROM composer:latest AS composer

# Second stage: Use the PHP image
FROM php:8.1.0-apache

WORKDIR /var/www/html

# Install necessary packages and PHP extensions
RUN apt-get update -y && apt-get install -y \
    libicu-dev \
    libmariadb-dev \
    unzip \
    zip \
    zlib1g-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    netcat \
    iputils-ping \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) gettext intl pdo_mysql

# Copy Composer from the first stage
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Copy application code
COPY . /var/www/html

# Set permissions
RUN chown -R www-data:www-data /var/www/html

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Add a script to wait for the database to be ready and run migrations
COPY wait-for-db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wait-for-db.sh

# Expose port 80
EXPOSE 80

# Use the script as the command
CMD ["wait-for-db.sh"]

