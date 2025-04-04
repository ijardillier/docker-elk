# Synthetics

Synthetics periodically checks the status of your services and applications. Monitor the availability of network endpoints and services using the following types of monitors:

    - Lightweight HTTP/S, TCP, and ICMP monitors
    - Browser monitors

This extension provides 3 containers:

    - Private location: allows you to run monitors from your own premises. They require an Elastic agent and Agent policy which you can control and maintain via Fleet.
    - Setup: initializes agent policy, private location agent and lightweight and project monitors. 

## Usage

If you want to include the Synthetics extension, run Docker Compose from the root of the repository with an additional
command line argument referencing the `synthetics-compose.yml` file:

```bash
$ docker-compose -f docker-compose.yml -f extensions/synthetics/synthetics-compose.yml up
```

This sample setup demonstrates how to run `synthetic-private-location` agent and how to import monitors using NodeJS `synthetic-project-monitors`.

## Exposed ports

No exposed ports.

## Documentation

[Synthetic Monitoring Reference](https://www.elastic.co/guide/en/observability/current/monitor-uptime-synthetics.html)

### Miscellianous information about lightweight monitors

There are two ways to create lightweight monitors:

    - by using Kibana UI / Synthetic app
    - by using Kibana Synthetic API

### Miscellianous information about project monitors

There are two ways to create lightweight monitors:

    - by using Kibana UI / Synthetic app
    - by creating Synthetic NodeJS project and pushing it to Kibana

#### Development environment initalization

- Install NodeJS on Linux: 

```bash
$ sudo apt install nodejs npm
```

- Install the package: 

```bash
$ npm install -g @elastic/synthetics
```

- Confirm your system is setup correctly:

```bash
$ npx @elastic/synthetics -h
```

- Create a project:

```bash
$ npx @elastic/synthetics init projects-sample
```

- Add lightweight and journeys

```ts
...
```

- Test journeys:

```bash
$ npx @elastic/synthetics journeys
```

You can then push your project to Kibana using the CLI, in this project, it is automatically done by the setup container.

More information on: https://www.elastic.co/guide/en/observability/current/synthetics-command-reference.html#elastic-synthetics-push-command

#### Synthetic Monitoring Recorder

Instead of scripting synthetic tests, you can use the Synthetic Monitoring Recorder to record it and just make some adjustments if needed.

More information on: https://github.com/elastic/synthetics-recorder/blob/main/docs/DOWNLOAD.md

