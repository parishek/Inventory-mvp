#!/bin/sh
set -e

echo "Waiting for database at $DB_HOST:$DB_PORT..."

# Loop until MySQL is ready
while ! mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -p"$DB_PASSWORD" --ssl-mode=DISABLED -e "SELECT 1" &> /dev/null
do
  echo "Database not ready yet, sleeping 2 seconds..."
  sleep 2
done

echo "Database is ready! Running migrations..."
php artisan migrate --force

echo "Starting Apache on port $PORT..."
# Replace Apache port with Render's $PORT
sed -i "s/80/${PORT}/g" /etc/apache2/ports.conf
sed -i "s/80/${PORT}/g" /etc/apache2/sites-available/000-default.conf

# Start Apache in foreground
apache2-foreground
