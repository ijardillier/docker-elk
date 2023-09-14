# Elastic stack (ELK) on Docker

Run the latest version of the [Elastic stack][elk-stack] with Docker and Docker Compose.

It gives you the ability to analyze any data set by using the searching/aggregation capabilities of Elasticsearch and
the visualization power of Kibana.

With this project, you will be able to launch a complete Elastic stack:

- 3 Elasticsearch nodes
- 1 Kibana instance
- Extensions: 
  - Logstash
  - On instance of each beat agent: filebeat, metricbeat, heartbeat, auditbeat, packetbeat
  - Fleet server / APM server
  - Enterprise Search

## Contents

- [Elastic stack (ELK) on Docker](#elastic-stack-elk-on-docker)
  - [Contents](#contents)
  - [Requirements](#requirements)
    - [Host setup (Tested on Linux only)](#host-setup-tested-on-linux-only)
      - [Linux](#linux)
  - [Usage](#usage)
    - [Bringing up the stack](#bringing-up-the-stack)
    - [Bringing up extensions](#bringing-up-extensions)
    - [Cleanup](#cleanup)
  - [Initial setup](#initial-setup)
    - [Setting up user authentication](#setting-up-user-authentication)
    - [Injecting data](#injecting-data)
    - [Default Kibana data view creation](#default-kibana-data-view-creation)
  - [Configuration](#configuration)
    - [How to configure Elasticsearch](#how-to-configure-elasticsearch)
    - [How to configure Kibana](#how-to-configure-kibana)
  - [JVM tuning](#jvm-tuning)
  - [Using a newer stack version](#using-a-newer-stack-version)

## Requirements

### Host setup (Tested on Linux only)

#### Linux

* [Docker Engine](https://docs.docker.com/engine/install/)
* [Docker Compose](https://docs.docker.com/compose/)

Kake sure your user has the [required permissions][linux-postinstall] to interact with the Docker daemon.

By default, the stack exposes the following ports:
* 9200: Elasticsearch HTTP (first node only)
* 5601: Kibana

> This docker compose is based on the official one provided by Elastic and available on Elasticsearch Guide [Install Elasticsearch with Docker][elasticsearch-docker] for development purpose. For production setups, we recommend users to set up their host according to the instructions from the Elasticsearch documentation: [Important System Configuration][es-sys-config].

## Usage

### Bringing up the stack

Clone this repository onto the Docker host that will run the stack, then start services locally using Docker Compose:

```console
$ docker-compose up
```

You can also run all services in the background (detached mode) by adding the `-d` flag to the above command.

If you are starting the stack for the very **first time**, please read the section below attentively.

### Bringing up extensions

You can find extension documentation in dedicated folder.

To launch the complete stack will all extensions:

```console
$ docker compose -f docker-compose.yml -f extensions/logstash/logstash-compose.yml -f extensions/fleet-server/fleet-server-compose.yml -f extensions/apm-server/apm-server-compose.yml -f extensions/beats/beats-compose.yml -f extensions/enterprise-search/enterprise-search-compose.yml up -d
```

### Cleanup

Elasticsearch, Kibana, ... data are persisted inside volumes by default.

In order to entirely shutdown the stack and remove all persisted data, use the following Docker Compose command:

```console
$ docker-compose down -v
```

## Initial setup

### Setting up user authentication

The stack is pre-configured with the following **privileged** bootstrap user:

* user: *elastic*
* password: *changeme*

This is done by setting the ELASTIC_PASSWORD in the environment variables on each node (esxx).

Since v8 of Elastic stack, components won't work with this user, so we have to configure the unprivileged built-in users.

The stack automatically configure the following builtin-users:

* user: *kibana_system*
* password: *changeme*

* user: *logstash_system*
* password: *changeme*

* user: *beats_system*
* password: *changeme*

* user: *remote_monitoring_user*
* password: *changeme*

In this docker compose, we use a temporary elasticsearch container to setup built-in users passwords (es00).

The passwords are defined in the .env file. **Don't forget to change them before you run the docker compose for the first time**.

The `logstash_system` and `beats_system` users are no more used since logstash and beats monitoring is now done with metricbeat.

The `remote_monitoring_user` password is used in in Metricbeat xpack modules, for Elasticsearch and Kibana monitoring.

> Do not use the `logstash_system` user inside the Logstash *pipeline* file, it does not have sufficient permissions to create indices. [Configuring Security in Logstash]> 
> Follow the instructions at [Secure you connection to Elasticsearch][ls-security] to create a user with suitable roles.

> Learn more about the security of the Elastic stack at [Tutorial: Getting started with security][secure-cluster].

### Injecting data

Give Kibana about a minute to initialize, then access the Kibana web UI by hitting
[http://localhost:5601](http://localhost:5601) with a web browser and use the following default credentials to log in:

* user: *elastic*
* password: *\<your generated elastic password>*

Now that the stack is running, you can load the sample data provided by your Kibana installation.

### Default Kibana data view creation

When Kibana launches for the first time, it is not configured with any data view.

> You need to configure each needed data view in order to discover data.

## Configuration

> Configuration is not dynamically reloaded, you will need to restart individual components after any configuration change, except for logstash pipelines, beats modules and inputsn which have auto reload enabled.

### How to configure Elasticsearch

The Elasticsearch configuration is stored in `elasticsearch/config/elasticsearch.yml`.

You can also specify the options you want to override by setting environment variables inside the Compose file.

### How to configure Kibana

The Kibana default configuration is stored in `kibana/config/kibana.yml`.

You can also specify the options you want to override by setting environment variables inside the Compose file.

## JVM tuning

By default, Elasticsearch, Kibana and Logstash are limited to XGb of memory. You can change this value with the MEM_LIMIT variable in the .env file.

For each Elasticsearch node, JVM will automatically be limited to 50% of allocated memory.

For Logstash, we need to limit the JVM to 50% of the allocated memory. This is done by setting the LS_JAVA_OPTS in the .env file.

## Using a newer stack version

To use a different Elastic Stack version than the one currently available in the repository, simply change the version
number inside the `.env` file, and rebuild the stack with:

```console
$ docker-compose up
```

> Always pay attention to the [upgrade instructions][upgrade] for each individual component before performing a stack upgrade.

[elk-stack]: https://www.elastic.co/elk-stack

[linux-postinstall]: https://docs.docker.com/install/linux/linux-postinstall/

[elasticsearch-docker]: https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html
[es-sys-config]: https://www.elastic.co/guide/en/elasticsearch/reference/current/system-config.html

[ls-security]: https://www.elastic.co/guide/en/logstash/current/ls-security.html
[secure-cluster]: https://www.elastic.co/guide/en/elasticsearch/reference/current/secure-cluster.html

[upgrade]: https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-upgrade.html