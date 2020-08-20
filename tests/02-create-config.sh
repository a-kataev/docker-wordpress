#!/bin/sh

basename "${0}"

set -ex

docker-compose exec -T wordpress \
  cmd wp config create --url="http://localhost" --dbname="wordpress" --dbuser="user" \
    --dbpass="password" --dbhost="mariadb" --path="/var/www/wordpress"
docker-compose exec -T wordpress \
  bash -c "test -f /var/www/wordpress/wp-config.php || exit 1"
