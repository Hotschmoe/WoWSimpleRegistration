# WoW Simple Registration Dockerfile
# PHP 8.0+ with required extensions

FROM php:8.2-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libgmp-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libxml2-dev \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    gmp \
    zip \
    soap \
    pdo \
    pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# First, copy only composer files to leverage Docker cache
COPY application/composer.json application/composer.lock* /var/www/html/application/

# Change to application directory
WORKDIR /var/www/html/application

# Install dependencies as root (composer will warn but it works)
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-interaction --prefer-dist

# Now copy the rest of the application
WORKDIR /var/www/html
COPY . /var/www/html/

# Copy sample config if config doesn't exist
RUN if [ ! -f "/var/www/html/application/config/config.php" ]; then \
    cp /var/www/html/application/config/config.php.sample /var/www/html/application/config/config.php; \
    fi

# Set proper permissions after everything is copied
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Apache configuration to point to the correct directory
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html\n\
    <Directory /var/www/html>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
