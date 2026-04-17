# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Docker Compose setup for running the full Elastic stack (Elasticsearch 3-node cluster + Kibana) with optional extensions: Logstash, Beats agents, Fleet Server, APM Server, and Synthetics monitoring.

Current stack version: controlled by `ELASTIC_STACK_VERSION` in `.env` (currently 9.3.3).

## Commands

**Start core stack:**
```bash
docker-compose up           # foreground
docker-compose up -d        # detached
```

**Start with all extensions:**
```bash
docker compose -f docker-compose.yml \
  -f extensions/logstash/logstash-compose.yml \
  -f extensions/fleet-server/fleet-server-compose.yml \
  -f extensions/apm-server/apm-server-compose.yml \
  -f extensions/beats/beats-compose.yml \
  -f extensions/synthetics/synthetics-compose.yml \
  up -d
```

**Start a single service:**
```bash
docker compose up kibana
```

**Teardown (including all persistent data):**
```bash
docker-compose down -v
```

**Quick integration check:**
```bash
curl -s -u elastic:<password> --cacert <certs_volume>/ca/ca.crt https://localhost:9200
curl -s -I http://localhost:5601
```

## Architecture

### Startup sequence

1. `setup` (container: `es00`) — runs first; generates TLS CA and node certs via `elasticsearch-certutil`, then bootstraps built-in user passwords via the ES REST API. Its healthcheck gates all other services on cert readiness.
2. `es01`, `es02`, `es03` — form a 3-node Elasticsearch cluster. Each node shares `elasticsearch/config/elasticsearch.yml` (bind-mounted read-only) and uses a dedicated data volume.
3. `kibana` — starts only after all three ES nodes are healthy.

### Volumes

| Volume | Purpose |
|---|---|
| `certs` | TLS certificates shared by all services |
| `es01_data`, `es02_data`, `es03_data` | Per-node Elasticsearch data |
| `kibana_data` | Kibana persistent data |

### Network

All services share the `docker_elk_bridge` bridge network.

### Extensions

Each extension under `extensions/` provides its own compose override file (e.g., `logstash-compose.yml`). Add extensions by appending `-f extensions/<name>/<name>-compose.yml` at startup.

## Configuration

### `.env` file

Controls everything: stack version, passwords, ports, memory limits, and license type. **Change passwords before first run.** Key variables:

- `ELASTIC_STACK_VERSION` — used for all image tags
- `ELASTIC_PASSWORD` — bootstrap `elastic` superuser password
- `KIBANA_SYSTEM_PASSWORD`, `LOGSTASH_SYSTEM_PASSWORD`, `BEATS_SYSTEM_PASSWORD`, `REMOTE_MONITORING_USER_PASSWORD` — set by `setup` on first run
- `ES_LICENSE` — `basic` or `trial`
- `ES_MEM_LIMIT`, `KBN_MEM_LIMIT`, `LS_MEM_LIMIT`, etc. — container memory limits
- `LS_JAVA_OPTS` — Logstash JVM heap (should be ~50% of `LS_MEM_LIMIT`)

### Config files (bind-mounted read-only)

- `elasticsearch/config/elasticsearch.yml` — ES node settings (shared by all three nodes)
- `kibana/config/kibana.yml` — Kibana settings

Configuration is **not** hot-reloaded; restart the relevant container after changes. Exception: Logstash pipelines, and Beats modules/inputs support auto-reload.

### TLS / Certs

Certs are generated once by `setup` into the `certs` volume. To regenerate certs, remove the `certs` volume (`docker volume rm certs`) and restart — `setup` will recreate them.

### Adding a new service / extension

Place the compose override under `extensions/<name>/` and document the `-f` invocation. If the new service needs TLS, add its entry to the `instances.yml` inline block inside the `setup` service command in `docker-compose.yml`.

## Ports (defaults)

| Service | Port |
|---|---|
| Elasticsearch node 1 | 9200 |
| Elasticsearch node 2 | 9201 |
| Elasticsearch node 3 | 9202 |
| Kibana | 5601 |
| Fleet Server | 8220 |
| APM Server | 8200 |
| Logstash API | 127.0.0.1:9600 |
| Logstash TCP input | 127.0.0.1:5000 |
| Logstash Beats input | 127.0.0.1:5044 |

## Default credentials

- `elastic` / value of `ELASTIC_PASSWORD` in `.env`
- `kibana_system` / value of `KIBANA_SYSTEM_PASSWORD` in `.env`

Do not use `logstash_system` or `beats_system` in pipeline/beats config — they lack index creation permissions. Create a dedicated user with appropriate roles instead.
