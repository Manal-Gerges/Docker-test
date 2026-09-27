# 1. Base Image: PHP 8.3 FPM
FROM php:8.3-fpm

# 2. Install system dependencies and required libraries
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    zip \
    unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Install PHP extensions (PDO, PostgreSQL, Multibyte strings, GD, etc.)
RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    pgsql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd

# 4. Install and enable Redis extension using PECL
RUN pecl install redis \
    && docker-php-ext-enable redis

# 5. Get the latest Composer binary from the official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 6. Set working directory inside the container
WORKDIR /var/www

# 7. Copy the existing application files into the container
COPY . /var/www

# 8. Install production composer dependencies (excluding dev dependencies)
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# 9. Set correct permissions for Laravel storage and bootstrap cache directories
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# 10. Expose port 9000 and start PHP-FPM server
EXPOSE 9000
CMD ["php-fpm"]