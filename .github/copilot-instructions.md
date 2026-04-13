# Copilot instructions for docker-elk

Purpose: concise guidance to help Copilot sessions work effectively in this repository.

1) Build / start / stop

- Start full stack (foreground):
  docker-compose up

- Start full stack (detached):
  docker compose up -d

- Start the complete stack including extensions (uses multiple compose files):
  docker compose -f docker-compose.yml -f extensions/logstash/logstash-compose.yml -f extensions/fleet-server/fleet-server-compose.yml -f extensions/apm-server/apm-server-compose.yml -f extensions/beats/beats-compose.yml -f extensions/synthetics/synthetics-compose.yml up -d

- Start a single service (example: kibana):
  docker compose up kibana

- Tear down and remove persistent data volumes:
  docker-compose down -v

Notes: service-specific healthchecks and init steps (certs + user bootstrap) are implemented in the `setup` service.

2) Test / Lint

- No native test or lint scripts in this repository (no package.json or CI scripts). Integration-like checks are performed by running the stack and verifying services (Kibana on :5601, Elasticsearch on :9200).

- To run a focused integration check, bring up the minimal set of services and use curl on the relevant endpoints with the configured credentials.

3) High-level architecture (big picture)

- 3 Elasticsearch nodes (es01, es02, es03) forming a cluster.
- A `setup` helper container that generates TLS certs and bootstraps built-in user passwords using environment variables from the .env file.
- Kibana (kibana) connects to the cluster and depends on healthy Elasticsearch nodes.
- Optional extensions live under `extensions/` and provide additional compose files for Logstash, Beats, Fleet/APM/Synthetics, Enterprise Search.
- Persistent volumes: per-node data volumes (es01_data, es02_data, es03_data) and kibana_data; certs stored in a `certs` volume.
- Configuration files are bind-mounted from the repository: `elasticsearch/config/elasticsearch.yml` and `kibana/config/kibana.yml`.

4) Key files / locations

- docker-compose.yml — main composition and service definitions
- .env (not committed) — controls ELASTIC_STACK_VERSION, ELASTIC_PASSWORD, KIBANA_SYSTEM_PASSWORD, LOGSTASH_SYSTEM_PASSWORD, BEATS_SYSTEM_PASSWORD, REMOTE_MONITORING_USER_PASSWORD, ES_MEM_LIMIT, KBN_MEM_LIMIT, and ports
- elasticsearch/config/elasticsearch.yml — ES node settings
- kibana/config/kibana.yml — Kibana settings
- extensions/ — per-extension compose overrides and documentation

5) Key conventions and patterns

- Secrets & bootstrap: passwords and stack version come from the local `.env`. The `setup` service enforces `.env` variables and generates TLS certs into the `certs` volume. Copilot should avoid suggesting hardcoding secrets into repo files.

- Certs: certificates are created by `elasticsearch-certutil` inside the `setup` service and stored under the `certs` volume. File permissions and ownership are set after generation.

- Service names: uses stable names (es00, es01, es02, es03, kibana) and healthchecks to manage startup ordering.

- Read-only mounts: repository config files are mounted read-only into containers; use those files as the source of truth for configuration changes.

- Running extensions: add extension compose files with `-f` when launching the stack to include extra services.

- JVM and memory tuning: memory limits are controlled via MEM_LIMIT variables in `.env`. JVM options for Logstash (LS_JAVA_OPTS) come from env too.

6) Helpful hints for Copilot sessions

- When asked to modify runtime configuration, point to the bind-mounted files under `elasticsearch/config/` and `kibana/config/` instead of editing container images.
- For tasks involving certificates, reference the `setup` service flow (instances.yml generation, elasticsearch-certutil, unzip, chown/chmod).
- For adding services, place compose snippets under `extensions/` and document how to include them with the multi-file `docker compose -f ...` invocation.


---

Generated: Copilot instructions file to assist future Copilot sessions.
