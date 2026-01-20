# PHP-FPM with Composer for Laravel/Bagisto
FROM php:8.3-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libicu-dev \
    libpq-dev \
    libcurl4-openssl-dev \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required for Laravel/Bagisto
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    intl \
    soap \
    opcache

# Install Redis extension
RUN pecl install redis \
    && docker-php-ext-enable redis

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u 1000 -d /home/bagisto bagisto
RUN mkdir -p /home/bagisto/.composer && \
    chown -R bagisto:bagisto /home/bagisto

# Copy existing application directory contents
COPY --chown=bagisto:bagisto . /var/www/html

# Copy existing application directory permissions
RUN chown -R bagisto:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Change current user to bagisto
USER bagisto

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
