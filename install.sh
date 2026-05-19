#!/bin/sh
#set -e

# Create necessary directories
mkdir -p bootstrap/cache \
         storage/framework/cache \
         storage/framework/sessions \
         storage/framework/views

# Set permissions
chown -R www-data:www-data bootstrap storage || true
chmod -R ug+rwx bootstrap storage || true

# Build frontend assets (tanpa dev server)
npm install --legacy-peer-deps --no-audit --progress=false
#npm run build
npm run dev

# Install PHP dependencies
composer install --optimize-autoloader --no-interaction

# Setup .env file
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Generate app key
php artisan key:generate --force

# Fix DB_HOST (pakai nama service, bukan IP)
sed -i 's/DB_HOST=127.0.0.1/DB_HOST=mysql/g' .env
sed -i 's/DB_PASSWORD=/DB_PASSWORD=password/g' .env

echo "Installation completed! (migration will run at container startup)"
