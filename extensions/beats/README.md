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

## Documentation

[Beats Reference](https://www.elastic.co/fr/beats/)