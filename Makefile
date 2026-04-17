.PHONY: help up down clean logs ps health test reset up-full

help:
	@echo "Docker ELK Stack - Available commands:"
	@echo ""
	@echo "Startup:"
	@echo "  make up         - Start core stack (Elasticsearch 3-node cluster + Kibana)"
	@echo "  make up-full    - Start stack with all extensions (Logstash, Beats, Fleet, APM, Synthetics)"
	@echo ""
	@echo "Shutdown:"
	@echo "  make down       - Stop all containers (keep data volumes)"
	@echo "  make clean      - Stop all containers and remove all data volumes"
	@echo ""
	@echo "Monitoring:"
	@echo "  make ps         - Show container status and health"
	@echo "  make logs       - Follow logs from all services (Ctrl+C to stop)"
	@echo "  make health     - Check Elasticsearch cluster health"
	@echo ""
	@echo "Maintenance:"
	@echo "  make reset      - Full reset: stop, remove all data, regenerate certs, restart"
	@echo ""
	@echo "Examples:"
	@echo "  make up && make logs"
	@echo "  make health"
	@echo "  make clean"

up:
	docker-compose up -d
	@echo "Stack starting... Run 'make logs' to follow progress"

down:
	docker-compose down

clean:
	docker-compose down -v

logs:
	docker-compose logs -f

ps:
	docker-compose ps

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

up-full:
	@echo "Starting stack with all extensions..."
	docker compose -f docker-compose.yml \
		-f extensions/logstash/logstash-compose.yml \
		-f extensions/fleet-server/fleet-server-compose.yml \
		-f extensions/apm-server/apm-server-compose.yml \
		-f extensions/beats/beats-compose.yml \
		-f extensions/synthetics/synthetics-compose.yml up -d
	@echo "Full stack starting... Run 'make logs' to follow progress"
