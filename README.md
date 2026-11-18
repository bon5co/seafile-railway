# seafile-railway

Wrapper image for [Seafile](https://github.com/haiwen/seafile) Community Edition (14.0.9) on [Railway](https://railway.com).

Upstream's nginx listens on a hard-coded port 80 and its start script waits for that exact port, while Railway's edge and healthcheck dial the
injected `PORT`. The wrapper moves nginx and the readiness check to `PORT` at every boot, refuses to start without an administrator login, and bakes
every constant setting into the image so the deploy form only holds generated secrets.

- Needs a MariaDB/MySQL server (`SEAFILE_MYSQL_DB_HOST`, `SEAFILE_MYSQL_DB_PASSWORD`, `INIT_SEAFILE_MYSQL_ROOT_PASSWORD`) and a Redis (`REDIS_HOST`, `REDIS_PASSWORD`)
- Variables: `SEAFILE_SERVER_HOSTNAME`, `INIT_SEAFILE_ADMIN_EMAIL`, `INIT_SEAFILE_ADMIN_PASSWORD` (8+ characters), `JWT_PRIVATE_KEY` (32+ characters)
- Volume: `/shared` (libraries, configuration, logs)
- Health: `GET /api2/ping/`
- WebDAV (`ENABLE_SEAFDAV`) stays off: it would need port 8080, which Railway injects as `PORT`

Published as `ghcr.io/bon5co/seafile-railway`.
