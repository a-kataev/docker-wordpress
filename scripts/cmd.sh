#!/bin/bash

set -e

log_info() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') [info] ${@}"
}

log_error() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') [error] ${@}" >&2
  exit 1
}

SERVICE_NAME="${SERVICE_NAME:-${SERVICE}}"

cmd_extract() {
  local archive="/usr/src/${SERVICE}-${SERVICE_VERSION}.tar.xz"
  log_info "Extract archive '${archive}' to /var/www/${SERVICE_NAME}"
  if [[ ! -f "${archive}" ]]; then
    log_error "Archive '${archive}' not found"
  fi
  if [[ -z "$(file ${archive} | grep ' XZ ')" ]]; then
    log_error "File '${archive}' is not archive"
  fi
  mkdir -p "/var/www/${SERVICE_NAME}"
  chown www-data:www-data "/var/www/${SERVICE_NAME}"
  tar xJf "${archive}" -C "/var/www/${SERVICE_NAME}" \
    --strip-components=1 --keep-newer-files
}

cmd_rm() {
  log_info "Remove all data in /var/www/${SERVICE_NAME}"
  (set +e; rm -rf "/var/www/${SERVICE_NAME}" 2>/dev/null)
}

cmd_su() {
  log_info "Execute command as www-data user: ${*}"
  set -- su -l www-data -s /bin/bash -c "${*}"
  exec "${@}"
}

if [[ "${1}" == 'extract' ]]; then
  cmd_extract
elif [[ "${1}" == 'remove' ]]; then
  cmd_rm
elif [[ "${1}" == 'wp' ]]; then
  cmd_su ${@}
elif [[ "${1}" == 'compose' ]]; then
  cmd_su ${@}
elif [[ "${1}" == 'php-ext-enable' ]]; then
  args=${@}
  shift
  log_info "Enable php extensions ${*}"
  /docker-entrypoint.sh ${args}
fi
