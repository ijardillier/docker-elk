# APM server

Elastic APM is an application performance monitoring system built on the Elastic Stack. It allows you to monitor software services and applications in real-time, by collecting detailed performance information on response time for incoming requests, database queries, calls to caches, external HTTP requests, and more. This makes it easy to pinpoint and fix performance problems quickly.

## Usage

If you want to include the APM server extension, run Docker Compose from the root of the repository with an additional
command line argument referencing the `apm-server-compose.yml` file:

```bash
$ docker-compose -f docker-compose.yml -f extensions/apm-server/apm-server-compose.yml up
```

This sample setup demonstrates how to run `apm-server` server.

All configuration files are available in the `config/` directory.

## Exposed ports

Default exposed ports are:

- 8200: APM server

You can change them in .env file.

## Documentation

[APM Reference](https://www.elastic.co/guide/en/apm/guide/current/apm-overview.html)