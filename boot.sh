#!/bin/bash
# Railway boot for Seafile.
#
# Upstream's nginx listens on a hard-coded port 80 (in /etc/nginx/nginx.conf and in the site file) and start.py's wait_for_nginx()
# looks for ":80 " in `netstat -nltp`, so a server that listens on any other port is never considered ready and seahub never
# starts. Railway's edge and healthcheck dial the injected PORT, so both are rewritten here, on every boot, before my_init
# starts nginx. The administrator is created by upstream from INIT_SEAFILE_ADMIN_EMAIL / INIT_SEAFILE_ADMIN_PASSWORD on the first boot.
set -u
: "${PORT:=8080}"
if [ -z "${INIT_SEAFILE_ADMIN_PASSWORD:-}" ] || [ -z "${INIT_SEAFILE_ADMIN_EMAIL:-}" ]; then
  echo "[railway] INIT_SEAFILE_ADMIN_EMAIL and INIT_SEAFILE_ADMIN_PASSWORD must be set" >&2
  exit 1
fi
if [ "${#INIT_SEAFILE_ADMIN_PASSWORD}" -lt 8 ]; then
  echo "[railway] INIT_SEAFILE_ADMIN_PASSWORD must be at least 8 characters" >&2
  exit 1
fi
if [ -z "${SEAFILE_MYSQL_DB_HOST:-}" ] || [ -z "${SEAFILE_MYSQL_DB_PASSWORD:-}" ] || [ -z "${REDIS_HOST:-}" ]; then
  echo "[railway] SEAFILE_MYSQL_DB_HOST, SEAFILE_MYSQL_DB_PASSWORD and REDIS_HOST must be set" >&2
  exit 1
fi
if [ "$PORT" = "8000" ] || [ "$PORT" = "8082" ] || [ "$PORT" = "3000" ]; then
  echo "[railway] PORT $PORT collides with an internal Seafile listener" >&2
  exit 1
fi

# nginx: main config (catch-all server) and the Seafile site, IPv4 and IPv6
sed -i "s/listen 80;/listen $PORT;/; s/listen \[::\]:80 /listen [::]:$PORT /" /etc/nginx/nginx.conf /etc/nginx/sites-enabled/seafile.nginx.conf
# readiness check in start.py
sed -i "s/if ':80 ' in output:/if ':$PORT ' in output:/" /scripts/utils.py
if ! grep -q "':$PORT ' in output" /scripts/utils.py; then echo "[railway] could not patch wait_for_nginx" >&2; exit 1; fi
echo "[railway] Seafile 14 on :$PORT, administrator $INIT_SEAFILE_ADMIN_EMAIL, database $SEAFILE_MYSQL_DB_HOST, cache $REDIS_HOST"
exec /sbin/my_init -- /scripts/enterpoint.sh
