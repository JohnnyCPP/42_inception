#!/bin/sh

# remove users with empty usernames
#
# mariadb creates anonymous users during installation
# these allow anyone to connect without credentials
# which is a security risk
# DELETE FROM mysql.user WHERE User='';

# remove root users that can connect from remote hosts
#
# root should only connect from localhost for security
# DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

# delete the default "test" database
#
# it's publicly accessible and 
# can be used as a vector for attacks
# DROP DATABASE IF EXISTS test;

# remove permissions from the test databases
#
# even if "test" database is deleted, 
# the permissions might still exist in mysql.db
#
# 'test\\_%' translates to any string starting 
# with 'test_' (test_1, test_2...)
# DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

# - principle of least privilege
# - wordpress should not use root
# - if compromised, only wordpress data is exposed
# - the @'%' allows connection from any host
#   (the wordpress container will connect to it)
# CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

# read the privilege tables 
# so changes take effect immediately
#
# mariadb caches permissions
# without this, the new user might not work
# FLUSH PRIVILEGES;

set -e


wait_for_mariadb()
{
    local max_attempts=30
    local attempt=1

    echo "Waiting for MariaDB service"
    while [ $attempt -le $max_attempts ]; do
        if mariadb-admin ping -h localhost --silent 2>/dev/null; then
            echo "MariaDB is ready"
            return 0
        fi
        echo "Attempt $attempt/$max_attempts: MariaDB is not ready"
        sleep 1
        attempt=$((attempt + 1))
    done
    echo "Error: MariaDB failed to start within $max_attempts seconds"
    return 1
}


is_db_initialized()
{
    [ -d "/var/lib/mysql/mysql" ]
}


if ! is_db_initialized; then
    echo "Initializing MariaDB data directory"
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db
    echo "Starting MariaDB in the background"
    gosu mysql mariadbd --datadir=/var/lib/mysql --skip-networking &
    wait_for_mariadb
    echo "Setting up WordPress database"
    mariadb -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    echo "Shutting down MariaDB"
    mariadb-admin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
    while mariadb-admin ping -h localhost --silent 2>/dev/null; do
        echo "Waiting for MariaDB to shutdown"
        sleep 1
    done
    echo "MariaDB shutdown complete"
else
    echo "Executing MariaDB"
fi

exec gosu mysql "$@"
