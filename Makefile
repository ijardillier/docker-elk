.PHONY: help up up-full down down-full clean clean-full logs ps health test reset

COMPOSE_FILES = -f docker-compose.yml
COMPOSE_FILES_FULL = -f docker-compose.yml \
	-f extensions/logstash/logstash-compose.yml \
	-f extensions/fleet-server/fleet-server-compose.yml \
	-f extensions/apm-server/apm-server-compose.yml \
	-f extensions/beats/beats-compose.yml \
	-f extensions/synthetics/synthetics-compose.yml

help:
	@echo "Docker ELK Stack - Available commands:"
	@echo ""
	@echo "Startup:"
	@echo "  make up         - Start core stack (Elasticsearch 3-node cluster + Kibana)"
	@echo "  make up-full    - Start stack with all extensions (Logstash, Beats, Fleet, APM, Synthetics)"
	@echo ""
	@echo "Shutdown:"
	@echo "  make down       - Stop core stack (keep data volumes)"
	@echo "  make down-full  - Stop core stack + all extensions (keep data volumes)"
	@echo "  make clean      - Stop core stack and remove all data volumes"
	@echo "  make clean-full - Stop core stack + extensions and remove all data volumes"
	@echo ""
	@echo "Monitoring:"
	@echo "  make ps         - Show container status and health"
	@echo "  make logs       - Follow logs from all services (Ctrl+C to stop)"
	@echo "  make health     - Check Elasticsearch cluster health"
	@echo ""
	@echo "Maintenance:"
	@echo "  make reset      - Full reset: stop core, remove all data, regenerate certs, restart"
	@echo ""
	@echo "Examples:"
	@echo "  make up && make logs"
	@echo "  make up-full && make logs"
	@echo "  make health"
	@echo "  make down-full"
	@echo "  make clean-full"

up:
	docker compose $(COMPOSE_FILES) up -d
	@echo "Stack starting... Run 'make logs' to follow progress"

up-full:
	@echo "Starting stack with all extensions..."
	docker compose $(COMPOSE_FILES_FULL) up -d
	@echo "Full stack starting... Run 'make logs' to follow progress"

down:
	docker compose $(COMPOSE_FILES) down

down-full:
	docker compose $(COMPOSE_FILES_FULL) down

clean:
	docker compose $(COMPOSE_FILES) down -v

clean-full:
	docker compose $(COMPOSE_FILES_FULL) down -v

logs:
	docker compose $(COMPOSE_FILES) logs -f

ps:
	docker compose $(COMPOSE_FILES) ps

health:
	@echo "Checking Elasticsearch cluster health..."
	@curl -s -u elastic:changeme --cacert certs/ca/ca.crt \
		https://localhost:9200/_cluster/health?pretty | jq . 2>/dev/null || \
	curl -s -u elastic:changeme --cacert certs/ca/ca.crt \
		https://localhost:9200/_cluster/health?pretty

test: health
	@echo "Stack health check passed!"

reset: clean
	@echo "Removing certificates volume..."
	@docker volume rm certs 2>/dev/null || true
	@echo "Starting fresh stack..."
	@$(MAKE) up

