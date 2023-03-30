# Prometheus

Prometheus powers your metrics and alerting with the leading open-source monitoring solution.

## Usage

If you want to include the Prometheus extension, run Docker Compose from the root of the repository with an additional
command line argument referencing the `prometheus-compose.yml` file:

```bash
$ docker-compose -f docker-compose.yml -f extensions/prometheus/prometheus-compose.yml up
```

This sample setup demonstrates how to run `prometheus` server.

All configuration files are available in the `config/` directory.

## Exposed ports

Default exposed ports are:

- 9090: Prometheus server

You can change them in .env file.

## Documentation

[Prometheus Reference](https://prometheus.io/docs/introduction/overview/)