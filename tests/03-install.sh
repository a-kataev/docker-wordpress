#!/bin/sh

basename "${0}"

set -ex

docker-compose exec -T wordpress \
  cmd wp core install --url="http://localhost" --title="test" --admin_user="admin" \
    --admin_password="password" --admin_email="admin@localhost.local" --path="/var/www/wordpress"
docker-compose exec -T wordpress \
  bash -c "test \"\$(curl -s -o /dev/null -I -w \"%{http_code}\" http://localhost/wp-json/wp/v2/posts/1)\" == '200'|| exit 1"
