# Beats

Beats are great for gathering data. They sit on your servers, with your containers, or deploy as functions — and then centralize data in Elasticsearch.

## Usage

If you want to include the Beats extension, run Docker Compose from the root of the repository with an additional
command line argument referencing the `beats-compose.yml` file:

```bash
$ docker-compose -f docker-compose.yml -f extensions/beats/beats-compose.yml up
```

This sample setup demonstrates how to run `beats` server.

All configuration files are available in the dedicated `<agent-name>/config/` directory.

## Exposed ports

Default exposed ports are:

- None

You can change them in .env file.

## Injecting data

All beats agents are configured to automatically send their data (logs, metrics and synthetics) from our stack to elasticsearch. It will create filebeat-{version} and metricbeat-{version} datastreams.

Logstash is configured for Beats input on 5044 port. So, if you change the output to Logstash in your beats configuration, beats agents will send their data to Logstash before. It will create logs-*, metrics-*, sythetics-* datastreams instead.

Stack Monitoring is available thanks to Metricbeat xpack modules.

## Documentation

[Beats Reference](https://www.elastic.co/fr/beats/)