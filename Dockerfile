FROM php:8.2-apache

# System dependencies
RUN apt-get update && apt-get install -y \
    git unzip curl libonig-dev libzip-dev zip \
    nodejs npm default-mysql-client \
    && docker-php-ext-install pdo_mysql mbstring zip \
    && a2enmod rewrite headers \
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

# ✅ Build Arguments (Render se pass honge)
ARG VITE_API_URL=https://inventory-mvp-1.onrender.com/api
ARG APP_URL=https://inventory-mvp-1.onrender.com

# ✅ Environment Variables (Build time + Runtime)
ENV APP_ENV=production
ENV APP_URL=${APP_URL}
ENV ASSET_URL=${APP_URL}
ENV VITE_API_URL=${VITE_API_URL}

# ✅ Create .env file for build
RUN echo "VITE_API_URL=${VITE_API_URL}" > .env.production

# Build frontend (environment variables use karegi)
RUN npm install
RUN npm run build

# ✅ Cleanup
RUN rm -rf node_modules .env.production

# Permissions
RUN chown -R www-data:www-data storage bootstrap/cache public/build

# ✅ Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
    CMD curl -f http://localhost/api/health || exit 1

EXPOSE 80

CMD ["apache2-foreground"]