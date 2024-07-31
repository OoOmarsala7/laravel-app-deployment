#!/bin/bash

# Remove default configurations
rm /etc/apache2/sites-available/default-ssl.conf
rm /etc/apache2/sites-available/000-default.conf

# Define the new configuration file
CONF_FILE="/etc/apache2/sites-available/laravel.conf"

# Create the configuration file with the specified content
cat > $CONF_FILE <<EOL
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName localhost
    DocumentRoot /var/www/html/public

    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>

    <Directory /var/www/html/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/laravel_error.log
    CustomLog \${APACHE_LOG_DIR}/laravel_access.log combined
</VirtualHost>
EOL

# Enable the site
a2ensite laravel.conf

# Stop Apache if it's running
apachectl stop

# Wait for the database to be ready
until nc -z -v -w30 db 3306; do
  echo "Waiting for database connection..."
  sleep 1
done

# Generate application key
php artisan key:generate

# Run migrations
echo "Database is ready, running migrations..."
php artisan migrate --force

# Start Apache in the foreground
apache2-foreground
