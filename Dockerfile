FROM php:8.2-apache

# System dependencies
RUN apt-get update && apt-get install -y \
    git unzip curl libonig-dev libzip-dev zip \
    nodejs npm default-mysql-client \
    && docker-php-ext-install pdo_mysql mbstring zip \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Apache → Laravel public folder
RUN sed -i 's|/var/www/html|/var/www/html/public|g' \
    /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html

COPY . .

# Composer
RUN curl -sS https://getcomposer.org/installer | php \
    -- --install-dir=/usr/local/bin --filename=composer

RUN composer install --no-dev --optimize-autoloader --no-interaction

# ✅ HTTPS Environment Variables
ENV APP_ENV=production
ENV APP_URL=https://inventory-mvp-1.onrender.com
ENV ASSET_URL=https://inventory-mvp-1.onrender.com

# Vite URLs
ENV VITE_APP_URL=https://inventory-mvp-1.onrender.com

# Build frontend (ye environment variables use karegi)
RUN npm install
RUN npm run build

# Permissions
RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 80

CMD ["apache2-foreground"]