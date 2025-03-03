# Synthetic Private Location

Private locations allow you to run monitors from your own premises. They require an Elastic agent and Agent policy which you can control and maintain via Fleet.

## Usage

If you want to include the Synthetic Private Location extension, run Docker Compose from the root of the repository with an additional
command line argument referencing the `synthetic-private-location-compose.yml` file:

```bash
$ docker-compose -f docker-compose.yml -f extensions/synthetic-private-location/synthetic-private-location-compose.yml up
```

This sample setup demonstrates how to run `synthetic-private-location` agent.

All configuration files are available in the `config/` directory.

## Exposed ports

No exposed ports.

## Documentation

[Synthetic Monitoring Reference](https://www.elastic.co/guide/en/observability/current/monitor-uptime-synthetics.html)