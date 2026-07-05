#!/bin/sh

set -e


echo "memory_limit = 256M" > /etc/php85/conf.d/99-memory.ini

sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/' /etc/php85/php-fpm.d/www.conf


echo "Waiting for MariaDB..."
while ! mariadb-admin ping -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --ssl=false --silent 2>/dev/null; do
    echo "MariaDB is not ready yet..."
    sleep 2
done
echo "MariaDB is ready!"


# check if wordpress is installed
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root --path=/var/www/html
    
    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb" \
        --allow-root \
        --path=/var/www/html
    
    echo "Installing WordPress..."
    wp core install \
        --url="${WP_URL}" \
        --title="Inception Blog" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root \
        --path=/var/www/html
    
    echo "Creating regular user..."
    wp user create "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=subscriber \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root \
        --path=/var/www/html
    
    echo "WordPress installation complete!"
else
    echo "WordPress already installed."
fi


chown -R nobody:nobody /var/www/html
chown -R nobody:nobody /var/log/php85
chmod -R 755 /var/www/html
chmod 644 /var/www/html/wp-config.php


exec gosu nobody php-fpm85 -F
