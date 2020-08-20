#!/bin/sh

basename "${0}"

set -ex

docker-compose exec -T wordpress \
  cmd extract
docker-compose exec -T wordpress \
  bash -c "test \"\$(stat -c "%U:%G" /var/www/wordpress/index.php)\" == 'www-data:www-data'|| exit 1"
