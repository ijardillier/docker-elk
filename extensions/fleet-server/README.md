# Fleet server

Fleet Server is a component that connects Elastic Agents to Fleet. It supports many Elastic Agent connections and serves as a control plane for updating agent policies, collecting status information, and coordinating actions across Elastic Agents. 

## Usage

If you want to include the Fleet server extension, run Docker Compose from the root of the repository with an additional
command line argument referencing the `fleet-server-compose.yml` file:

```bash
$ docker-compose -f docker-compose.yml -f extensions/fleet-server/fleet-server-compose.yml up
```

This sample setup demonstrates how to run `fleet-server` server.

All configuration files are available in the `config/` directory.

You will need to create a link to ca.crt it you want to install elastic agent without Docker on you host machine :

```bash
$ ln -s /var/lib/docker/volumes/certs/_data/ca/ca.crt /usr/share/elastic-agent/certs/ca/ca.crt
```

## Exposed ports

Default exposed ports are:

- 8220: Fleet server

You can change them in .env file.

## Documentation

[Fleet server Reference](https://www.elastic.co/guide/en/fleet/current/fleet-server.html)


## Install agent

./elastic-agent install --url=https://fleet-server:8220 --enrollment-token=<given_token> --certificate-authorities=/usr/share/elastic-agent/certs/ca/ca.crt
