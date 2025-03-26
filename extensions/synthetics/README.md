# Synthetics

## Synthetic private locations

Private locations allow you to run monitors from your own premises. They require an Elastic agent and Agent policy which you can control and maintain via Fleet.

## Synthetic project monitors

Project monitors allow you to create monitors from configuration project.

## Usage

If you want to include the Synthetics extension, run Docker Compose from the root of the repository with an additional
command line argument referencing the `synthetics-compose.yml` file:

```bash
$ docker-compose -f docker-compose.yml -f extensions/synthetics/synthetics-compose.yml up
```

This sample setup demonstrates how to run `synthetic-private-location` agent and how to import monitors using NodeJS `synthetic-project-monitors`.

All configuration files are available in the `config/` directory.

## Exposed ports

No exposed ports.

## Documentation

[Synthetic Monitoring Reference](https://www.elastic.co/guide/en/observability/current/monitor-uptime-synthetics.html)

## Miscellianous information about project monitors

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
$ npx @elastic/synthetics init projects-elk
```

TF95RzBwVUI2aFE4ZDMxT2ZhZVI6MUZiVVFqYWdTOUdxX0xWTG1kNDFzQQ==
export SYNTHETICS_API_KEY=TF95RzBwVUI2aFE4ZDMxT2ZhZVI6MUZiVVFqYWdTOUdxX0xWTG1kNDFzQQ==
SYNTHETICS_API_KEY=TF95RzBwVUI2aFE4ZDMxT2ZhZVI6MUZiVVFqYWdTOUdxX0xWTG1kNDFzQQ== npm run push