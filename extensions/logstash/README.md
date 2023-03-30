# Logstash

Logstash is a server-side data processing pipeline that ingests data from a multitude of sources simultaneously, transforms it, and then sends it to your favorite "stash".

## Usage

If you want to include the Logstash extension, run Docker Compose from the root of the repository with an additional
command line argument referencing the `logstash-compose.yml` file:

```bash
$ docker-compose -f docker-compose.yml -f extensions/logstash/logstash-compose.yml up
```

This sample setup demonstrates how to run `logstash` server.

All configuration files are available in the `config/` directory.

## Implementation

The Logstash configuration is stored in `config/logstash.yml` and pipelines configuration is done in `config/pipelines.yml`.

There are 3 pipelines implemented:
- Beats input with filters that routes logs (filebeat), metrics (metricbeat) and synthetics (hearbeat) to logs-\* metrics-\*, synthetics-\* data streams (instead of filebeat-\*, metricbeat-\* and heartbeat-\*).
- TCP input
- DLQ (Dead-Letter-Queue) : transfer not ingested message to a specific index.

## Exposed ports

Default exposed ports are:

- 9600: Logstash API
- 5000: TCP input
- 5044: Beats input

You can change them in .env file.

## Documentation

[Logstash Reference](https://www.elastic.co/guide/en/logstash/8.6/introduction.html)