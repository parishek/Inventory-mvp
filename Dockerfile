# Use official PHP image with Apache
FROM php:8.2-apache

# Set working directory
WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && apt-get install -y \
    git unzip curl libonig-dev libzip-dev zip \
    npm \
    && docker-php-ext-install pdo_mysql mbstring zip

# Enable Apache rewrite module
RUN a2enmod rewrite

# Copy composer and install Laravel
COPY composer.json composer.lock ./
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev --optimize-autoloader

# Copy the rest of the app
COPY . .

# Install Node dependencies and build Vue
RUN npm install
RUN npm run build

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 10000
EXPOSE 10000

# Start Apache in foreground
CMD ["apache2-foreground"]
