# Use PHP 8.1 Alpine image
FROM php:8.1-fpm-alpine

# Install common PHP extension dependencies using apk
RUN apk update && apk add --no-cache \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    zlib-dev \
    libzip-dev \
    unzip

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install zip

# Set the working directory
WORKDIR /amaxonApp

# Copy the application files
COPY . .

# Set permissions for application files
RUN chown -R www-data:www-data /amaxonApp \
    && chmod -R 775 /amaxonApp/storage

# Install Composer
COPY --from=composer:2.6.5 /usr/bin/composer /usr/local/bin/composer

# Copy composer.json and install dependencies
COPY composer.json composer.lock ./
RUN composer install --no-scripts --no-autoloader

# Set the default command to run php-fpm
CMD ["php-fpm"]
