ARG BASE_IMAGE=

ARG CONFIGS_PATH=

ARG RCLONE_VERSION=1.54.0

FROM "${BASE_IMAGE}"

LABEL maintainer="Alex Kataev <dlyavsehpisem@gmail.com>"

ARG CONFIGS_PATH

ARG RCLONE_VERSION

ENV SERVICE=wordpress \
  SERVICE_VERSION=${WORDPRESS_VERSION:-latest} \
  WORDPRESS_VERSION=${WORDPRESS_VERSION:-latest} \
  WORDPRESS_LOCALE=${WORDPRESS_LOCALE:-en_US}

RUN set -x && \
#
  /docker-entrypoint.sh php-ext-enable gd,mysqli,opcache,soap,zip,redis && \
#
  apt-get update && \
  apt-get install -y --no-install-recommends mariadb-client-core-10.3 && \
  rm -rf /var/lib/apt/lists/* && \
#
  curl -sL -o /tmp/rclone.deb \
   "https://github.com/rclone/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-amd64.deb" && \
  dpkg -i /tmp/rclone.deb && \
  rm -rf /tmp/rclone.deb && \
#
  curl -sL -o /usr/local/bin/wp \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
  chmod +x /usr/local/bin/wp && \
#
  mkdir "/var/www/${SERVICE}" /var/www/.wp-cli && \
  chown -R www-data:www-data "/var/www/${SERVICE}" /var/www/.wp-cli && \
  su -l www-data -s /bin/bash -c "wp core download \
    --path=/var/www/${SERVICE} --locale=${WORDPRESS_LOCALE} --version=${WORDPRESS_VERSION}" && \
  rm -rf /var/www/.wp-cli && \
#
  tar cJf "/usr/src/${SERVICE}-${SERVICE_VERSION}.tar.xz" -C /var/www "${SERVICE}" && \
  rm -rf "/var/www/${SERVICE}"

ADD "${CONFIGS_PATH}/" /

ADD scripts/cmd.sh /
RUN set -x && \
  chmod +x /cmd.sh && \
  rm -rf /usr/local/bin/cmd && \
  ln -s /cmd.sh /usr/local/bin/cmd && \
  ln -s /cmd.sh /usr/local/bin/svc
