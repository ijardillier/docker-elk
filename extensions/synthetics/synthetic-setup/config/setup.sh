#!/bin/sh

# Private location setup
echo -e "Create agent policy for private location";
curl -s -X POST -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" -H "kbn-xsrf: true" \
    http://kibana:5601/api/fleet/agent_policies -d @/opt/synthetic-setup/config/private-location/agent-policy.json

echo -e "Create private location";
curl -s -X POST -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" -H "kbn-xsrf: true" \
    http://kibana:5601/api/synthetics/private_locations -d @/opt/synthetic-setup/config/private-location/private-location.json

# API monitors setup
echo -e "\nCreate monitor es01";
curl -s -X POST -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" -H "kbn-xsrf: true" \
    http://kibana:5601/api/synthetics/monitors -d @/opt/synthetic-setup/config/api-monitors/es01.json

echo -e "\nCreate monitor es02";
curl -s -X POST -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" -H "kbn-xsrf: true" \
    http://kibana:5601/api/synthetics/monitors -d @/opt/synthetic-setup/config/api-monitors/es02.json

echo -e "\nCreate monitor es03";
curl -s -X POST -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" -H "kbn-xsrf: true" \
    http://kibana:5601/api/synthetics/monitors -d @/opt/synthetic-setup/config/api-monitors/es03.json

echo -e "\nCreate monitor kibana";
curl -s -X POST -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" -H "kbn-xsrf: true" \
    http://kibana:5601/api/synthetics/monitors -d @/opt/synthetic-setup/config/api-monitors/kibana.json

echo -e "\nCreate monitor filebeat";
curl -s -X POST -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" -H "kbn-xsrf: true" \
    http://kibana:5601/api/synthetics/monitors -d @/opt/synthetic-setup/config/api-monitors/filebeat.json

echo -e "\nCreate monitor metricbeat";
curl -s -X POST -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" -H "kbn-xsrf: true" \
    http://kibana:5601/api/synthetics/monitors -d @/opt/synthetic-setup/config/api-monitors/metricbeat.json

echo -e "\nCreate monitor auditbeat";
curl -s -X POST -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" -H "kbn-xsrf: true" \
    http://kibana:5601/api/synthetics/monitors -d @/opt/synthetic-setup/config/api-monitors/auditbeat.json

echo -e "\nCreate monitor heartbeat";
curl -s -X POST -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" -H "kbn-xsrf: true" \
    http://kibana:5601/api/synthetics/monitors -d @/opt/synthetic-setup/config/api-monitors/heartbeat.json

echo -e "\nCreate monitor packetbeat";
curl -s -X POST -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" -H "kbn-xsrf: true" \
    http://kibana:5601/api/synthetics/monitors -d @/opt/synthetic-setup/config/api-monitors/packetbeat.json

echo -e "\nCreate monitor logstash";
curl -s -X POST -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" -H "kbn-xsrf: true" \
    http://kibana:5601/api/synthetics/monitors -d @/opt/synthetic-setup/config/api-monitors/logstash.json

echo -e "\nCreate monitor fleet-server";
curl -s -X POST -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" -H "kbn-xsrf: true" \
    http://kibana:5601/api/synthetics/monitors -d @/opt/synthetic-setup/config/api-monitors/fleet-server.json

echo -e "\nCreate monitor apm-server";
curl -s -X POST -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" -H "kbn-xsrf: true" \
    http://kibana:5601/api/synthetics/monitors -d @/opt/synthetic-setup/config/api-monitors/apm-server.json

# Project monitors setup
echo -e "\nDelete (invalidate) synthetis api key";
curl --cacert /opt/synthetic-setup/certs/ca/ca.crt -s -X DELETE -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" \
    https://es01:9200/_security/api_key -d "{\"name\":\"synthetics-api-key\"}"

echo -e "\nCreate synthetis api key";
SYNTHETICS_API_KEY=$(curl --cacert /opt/synthetic-setup/certs/ca/ca.crt -s -X POST -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" \
    https://es01:9200/_security/api_key -d @/opt/synthetic-setup/config/project-monitors/api-key.json | jq -r '.encoded')
echo "$SYNTHETICS_API_KEY"

echo -e "\nCreate synthetis api key";
cd /opt/synthetic-setup/config/project-monitors/project-sample
npx @elastic/synthetics push --auth $SYNTHETICS_API_KEY --id project-sample --url http://kibana:5601 --private-locations "Dev Machine" --yes

echo -e "\nOk";