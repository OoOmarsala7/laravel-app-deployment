#!/bin/bash

# Wait for the database to be ready
until ping -c 1 db &> /dev/null; do
  echo "Waiting for database to be ready..."
  sleep 1
done

# Run migrations
echo "Database is ready, running migrations..."
php artisan migrate --force

# Start Apache
apache2-foreground
