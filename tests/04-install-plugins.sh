#!/bin/sh

basename "${0}"

set -ex

docker-compose exec -T wordpress \
  cmd wp plugin install redis-cache --activate --path="/var/www/wordpress"
docker-compose exec -T wordpress \
  cmd wp plugin install nginx-helper --activate --path="/var/www/wordpress"
docker-compose exec -T wordpress \
  cmd wp config set RT_WP_NGINX_HELPER_CACHE_PATH '/var/cache/nginx/wordpress' --path="/var/www/wordpress"
docker-compose exec -T wordpress \
  sh -c "echo '{\"enable_purge\":\"1\",\"cache_method\":\"enable_fastcgi\",\"purge_method\":\"unlink_files\",\"enable_map\":null,\"enable_log\":null,\"log_level\":\"INFO\",\"log_filesize\":\"5\",\"enable_stamp\":null,\"purge_homepage_on_edit\":\"1\",\"purge_homepage_on_del\":\"1\",\"purge_archive_on_edit\":\"1\",\"purge_archive_on_del\":\"1\",\"purge_archive_on_new_comment\":null,\"purge_archive_on_deleted_comment\":null,\"purge_page_on_mod\":\"1\",\"purge_page_on_new_comment\":\"1\",\"purge_page_on_deleted_comment\":\"1\",\"redis_hostname\":\"redis\",\"redis_port\":\"6379\",\"redis_prefix\":\"nginx-cache:\",\"purge_url\":\"\",\"redis_enabled_by_constant\":0}' | cmd wp option add rt_wp_nginx_helper_options --format=json --path="/var/www/wordpress""
docker-compose exec -T wordpress \
  bash -c "test \"\$(curl -s -o /dev/null -I -w \"%{http_code}\" http://localhost/wp-json/wp/v2/posts/1)\" == '200'|| exit 1"
