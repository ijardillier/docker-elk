# Enterprise search

Elastic Enterprise Search enables developers and teams to build search-powered applications using the Elastic search platform. Build search for ecommerce, customer support, workplace content, websites, or any other application using a curated collection of tools.

## Usage

If you want to include the Enterprise search extension, run Docker Compose from the root of the repository with an additional
command line argument referencing the `enterprise-search-compose.yml` file:

```bash
$ docker-compose -f docker-compose.yml -f extensions/enterprise-search/apm-search-compose.yml up
```

This sample setup demonstrates how to run `enterprise-search` server.

All configuration files are available in the `config/` directory.

## Exposed ports

Default exposed ports are:

- 3002: Enterprise search

You can change them in .env file.

## Documentation

[Enterprise search Reference](https://www.elastic.co/guide/en/enterprise-search/current/start.html)