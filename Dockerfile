# Seafile wrapper for Railway. Upstream's nginx listens on a hard-coded port 80 and its start script waits for that exact port,
# while Railway's edge and healthcheck dial the injected PORT (8080). Upstream also expects the deployer to hand it a database
# host, an administrator and a cache host, none of which have defaults a generated deploy form can fill. The wrapper moves nginx
# (and the readiness check) to PORT at every boot, refuses to start without an administrator password, and bakes every constant
# setting into the image so the deploy form only holds generated secrets.
# upstream: haiwen/seafile
FROM seafileltd/seafile-mc:14.0.9@sha256:75d8b88e8bfaa54099082aec0e99ff1a962bd364bfc21da34125fa66998f0861

COPY --chmod=0755 boot.sh /railway-boot.sh

ENV PORT=8080 \
    SEAFILE_SERVER_PROTOCOL=https \
    SEAFILE_MYSQL_DB_USER=seafile \
    SEAFILE_MYSQL_DB_PORT=3306 \
    SEAFILE_MYSQL_DB_CCNET_DB_NAME=ccnet_db \
    SEAFILE_MYSQL_DB_SEAFILE_DB_NAME=seafile_db \
    SEAFILE_MYSQL_DB_SEAHUB_DB_NAME=seahub_db \
    CACHE_PROVIDER=redis \
    REDIS_PORT=6379 \
    TIME_ZONE=UTC \
    SEAFILE_LOG_TO_STDOUT=true \
    ENABLE_SEADOC=false \
    ENABLE_NOTIFICATION_SERVER=false \
    ENABLE_SEAFDAV=false \
    ENABLE_METADATA_MANAGEMENT=false
EXPOSE 8080
ENTRYPOINT ["/bin/bash", "/railway-boot.sh"]
