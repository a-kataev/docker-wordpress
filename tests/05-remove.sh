#!/bin/sh

basename "${0}"

set -ex

docker-compose exec -T wordpress \
  cmd remove
docker-compose exec -T wordpress \
  bash -c "test ! -f /var/www/wordpress/index.php || exit 1"
