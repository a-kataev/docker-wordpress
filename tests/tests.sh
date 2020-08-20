#!/bin/sh

set -ex

docker-compose pull -q

docker-compose up -d

sleep 30s

docker-compose exec -T mariadb \
  mysqladmin ping -P 3306 -h 127.0.0.1 -u"user" -p"password"

# docker-compose exec -T wordpress \
#   bash -c "mkdir /var/www/.wp-cli && chown -R www-data:www-data /var/www/.wp-cli"

(
  set +x
  for t in $(find $(pwd) -mindepth 1 -maxdepth 1 -type f -name "*.sh" -exec basename {} \; | \
    sort | grep -E "^[0-9]{2}-"); do
    "./${t}"
  done
)

docker-compose down -v --remove-orphans
