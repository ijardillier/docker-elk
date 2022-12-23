# Elastic stack (ELK) on Docker

Run the latest version of the [Elastic stack][elk-stack], [Prometheus][prometheus] with Docker and Docker Compose.

It gives you the ability to analyze any data set by using the searching/aggregation capabilities of Elasticsearch and
the visualization power of Kibana.

> The Docker images backing this stack include [Stack Features][stack-features] (formerly X-Pack)
with [paid features][paid-features] enabled by default (see [How to disable paid
features](#how-to-disable-paid-features) to disable them). The [trial license][trial-license] is valid for 30 days.

Based on the official Docker images from Elastic:

* [Elasticsearch](https://github.com/elastic/elasticsearch)
* [Logstash](https://github.com/elastic/logstash)
* [Kibana](https://github.com/elastic/kibana)
* [Beats](https://github.com/elastic/beats)
* [Prometheus](https://github.com/prometheus)

## Contents

- [Elastic stack (ELK) on Docker](#elastic-stack-elk-on-docker)
  - [Contents](#contents)
  - [Requirements](#requirements)
    - [Host setup](#host-setup)
      - [Linux](#linux)
      - [Windows](#windows)
  - [Usage](#usage)
    - [Bringing up the stack](#bringing-up-the-stack)
    - [Cleanup](#cleanup)
  - [Initial setup](#initial-setup)
    - [Setting up user authentication](#setting-up-user-authentication)
    - [Injecting data](#injecting-data)
    - [Injecting logs and metrics from our stack](#injecting-logs-and-metrics-from-our-stack)
    - [Default Kibana data view creation](#default-kibana-data-view-creation)
  - [Configuration](#configuration)
    - [How to configure Elasticsearch](#how-to-configure-elasticsearch)
    - [How to configure Kibana](#how-to-configure-kibana)
    - [How to configure Logstash](#how-to-configure-logstash)
    - [How to configure Filebeat](#how-to-configure-filebeat)
    - [How to configure Metricbeat](#how-to-configure-metricbeat)
    - [How to disable paid features](#how-to-disable-paid-features)
    - [How to scale out the Elasticsearch cluster](#how-to-scale-out-the-elasticsearch-cluster)
  - [JVM tuning](#jvm-tuning)
    - [How to specify the amount of memory used by a service](#how-to-specify-the-amount-of-memory-used-by-a-service)
  - [Going further](#going-further)
    - [Using a newer stack version](#using-a-newer-stack-version)

## Requirements

### Host setup

#### Linux

* [Docker Engine](https://docs.docker.com/engine/install/)
* [Docker Compose](https://docs.docker.com/compose/)

#### Windows

* [Docker Desktop](https://docs.docker.com/desktop/install/windows-install/)
* [Use the WSL 2 based engine](https://docs.docker.com/desktop/windows/wsl/)

> Especially on Linux, make sure your user has the [required permissions][linux-postinstall] to
> interact with the Docker daemon.

By default, the stack exposes the following ports:
* 5000: Logstash TCP input
* 5044: Logstash Beats input
* 9200: Elasticsearch HTTP (first node only)
* 5601: Kibana
* 9090: Prometheus

> This docker compose is based on the official one provided by Elastic and available on Elasticsearch Guide [Install Elasticsearch with Docker][elasticsearch-docker] for development purpose. For production setups, we recommend users to set up their host according to the instructions from the Elasticsearch documentation: [Important System Configuration][es-sys-config].

## Usage

### Bringing up the stack

Clone this repository onto the Docker host that will run the stack, then start services locally using Docker Compose:

```console
$ docker-compose up
```

You can also run all services in the background (detached mode) by adding the `-d` flag to the above command.

If you are starting the stack for the very **first time**, please read the section below attentively.

### Cleanup

Elasticsearch, Kibana, Logstash and Prometheus data are persisted inside volumes by default.

In order to entirely shutdown the stack and remove all persisted data, use the following Docker Compose command:

```console
$ docker-compose down -v
```

## Initial setup

### Setting up user authentication

> Refer to [How to disable paid features](#how-to-disable-paid-features) to disable authentication.

The stack is pre-configured with the following **privileged** bootstrap user:

* user: *elastic*
* password: *changeme*

This is done by setting the ELASTIC_PASSWORD in the environment variables on each node (esxx).

Since v8 of Elastic stack, components won't work with this user, so we have to configure the unprivileged [built-in users][builtin-users].

1. Initialize passwords for built-in users

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

1. Replace usernames and passwords in configuration files

The `logstash_system` and `beats_system` users are not used at this time.

Normally, you should use the `remote_monitoring_user` password in Metricbeat xpack modules configuration files (`metricbeat/config/modules.d/*-xpack.yml`) but this is no more working at this time.

Replace the password for the `elastic` user for each occurence of "changeme" password.

> Do not use the `logstash_system` user inside the Logstash *pipeline* file, it does not have
> sufficient permissions to create indices. Follow the instructions at [Configuring Security in Logstash][ls-security]
> to create a user with suitable roles.

See also the [Configuration](#configuration) section below.

1. Unset the bootstrap password (_optional_)

Remove the `ELASTIC_PASSWORD` environment variable from the `elasticsearch` service inside the Compose file
(`docker-compose.yml`). It is only used to initialize the keystore during the initial startup of Elasticsearch.

4. Restart Kibana, Logstash, Filebeat and Metricbeat to apply changes

```console
$ docker-compose restart kibana logstash filebeat metricbeat
```

> Learn more about the security of the Elastic stack at [Tutorial: Getting started with security][secure-cluster].

### Injecting data

Give Kibana about a minute to initialize, then access the Kibana web UI by hitting
[http://localhost:5601](http://localhost:5601) with a web browser and use the following default credentials to log in:

* user: *elastic*
* password: *\<your generated elastic password>*

Now that the stack is running, you can go ahead and inject some log entries. The shipped Logstash configuration allows
you to send content via TCP:


```console
# Using BSD netcat (Debian, Ubuntu, MacOS system, ...)
$ cat /path/to/logfile.log | nc -q0 localhost 5000
```

```console
# Using GNU netcat (CentOS, Fedora, MacOS Homebrew, ...)
$ cat /path/to/logfile.log | nc -c localhost 5000
```

You can also load the sample data provided by your Kibana installation.

### Injecting logs and metrics from our stack

Filebeat and Metricbeat are configured to automatically send logs and metrics from our stack to elasticsearch. It will create filebeat-{version} and metricbeat-{version} datastreams.

Logstash is configured for Beats input on 5044 port and TCP input on 5000.

Stack Monitoring is available thanks to Metricbeat xpack modules.

### Default Kibana data view creation

When Kibana launches for the first time, it is not configured with any data view.

> You need to configure filebeat (`filebeat-*`) and metricbeat (`metricbeat-*`) data view.s (see below) in order to discover data.

> You need to inject data into Logstash before being able to configure a Logstash data view via the Kibana web UI.

## Configuration

> Configuration is not dynamically reloaded, you will need to restart individual components after any configuration change.

### How to configure Elasticsearch

The Elasticsearch configuration is stored in [`elasticsearch/config/elasticsearch.yml`][config-es].

You can also specify the options you want to override by setting environment variables inside the Compose file:

```yml
elasticsearch:

  environment:
    network.host: _non_loopback_
    cluster.name: my-cluster
```

Please refer to the following documentation page for more details about how to configure Elasticsearch inside Docker
containers: [Install Elasticsearch with Docker][es-docker].

### How to configure Kibana

The Kibana default configuration is stored in [`kibana/config/kibana.yml`][config-kbn].

It is also possible to map the entire `config` directory instead of a single file.

Please refer to the following documentation page for more details about how to configure Kibana inside Docker
containers: [Running Kibana on Docker][kbn-docker].

### How to configure Logstash

The Logstash configuration is stored in [`logstash/config/logstash.yml`][config-ls] and pipelines configuration is done in [`logstash/config/pipelines.yml`][config-pl].

It is also possible to map the entire `config` directory instead of a single file, however you must be aware that
Logstash will be expecting a [`log4j2.properties`][log4j-props] file for its own logging.

Please refer to the following documentation page for more details about how to configure Logstash inside Docker
containers: [Configuring Logstash for Docker][ls-docker].

### How to configure Filebeat

The Filebeat configuration is stored in [`filebeat/config/filebeat.yml`][config-fb].

Modules are configured in `modules.d` subdirectory. This folder is configured with automatic reload.

### How to configure Metricbeat

The Metricbeat configuration is stored in [`metricbeat/config/metricbeat.yml`][config-mb].

Modules are configured in `modules.d` subdirectory. This folder is configured with automatic reload.

### How to disable paid features

Switch the value of Elasticsearch's `xpack.license.self_generated.type` option from `trial` to `basic` (see [License
settings][trial-license]).

### How to scale out the Elasticsearch cluster

Follow the instructions from the Wiki: [Scaling out Elasticsearch](https://github.com/deviantony/docker-elk/wiki/Elasticsearch-cluster)

## JVM tuning

### How to specify the amount of memory used by a service

By default, Elasticsearch, Kibana and Logstash are limited to 1Gb of memory. You can change this value with the MEM_LIMIT variable in the .env file.

The startup scripts for Elasticsearch and Logstash can append extra JVM options from the value of an environment
variable, allowing the user to adjust the amount of memory that can be used by each component:

| Service       | Environment variable |
|---------------|----------------------|
| Elasticsearch | ES_JAVA_OPTS         |
| Logstash      | LS_JAVA_OPTS         |

For each Elasticsearch node, JVM will automatically be limited to 50% of allocated memory, that's to say 512Mb.

For Logstash, we need to limit the JVM to 50% of the allocated memory. 
This is done by setting the LS_JAVA_OPTS in the .env file.

## Going further

### Using a newer stack version

To use a different Elastic Stack version than the one currently available in the repository, simply change the version
number inside the `.env` file, and rebuild the stack with:

```console
$ docker-compose up
```

> Always pay attention to the [upgrade instructions][upgrade] for each individual component before performing a stack upgrade.

[elk-stack]: https://www.elastic.co/elk-stack
[prometheus]: https://prometheus.io
[stack-features]: https://www.elastic.co/elastic-stack/features
[paid-features]: https://www.elastic.co/subscriptions
[trial-license]: https://www.elastic.co/guide/en/elasticsearch/reference/current/license-settings.html

[linux-postinstall]: https://docs.docker.com/install/linux/linux-postinstall/

[elasticsearch-docker]: https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html
[es-sys-config]: https://www.elastic.co/guide/en/elasticsearch/reference/current/system-config.html

[win-shareddrives]: https://docs.docker.com/docker-for-windows/#shared-drives
[mac-mounts]: https://docs.docker.com/docker-for-mac/osxfs/

[builtin-users]: https://www.elastic.co/guide/en/elasticsearch/reference/current/built-in-users.html
[ls-security]: https://www.elastic.co/guide/en/logstash/current/ls-security.html
[secure-cluster]: https://www.elastic.co/guide/en/elasticsearch/reference/current/secure-cluster.html

[connect-kibana]: https://www.elastic.co/guide/en/kibana/current/connect-to-elasticsearch.html
[index-pattern]: https://www.elastic.co/guide/en/kibana/current/index-patterns.html

[config-es]: ./elasticsearch/config/elasticsearch.yml
[config-kbn]: ./kibana/config/kibana.yml
[config-ls]: ./logstash/config/logstash.yml
[config-pl]: ./logstash/config/pipelines.yml
[config-mb]: ./metricbeat/config/metricbeat.yml
[config-fb]: ./filebeat/config/filebeat.yml

[es-docker]: https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html
[kbn-docker]: https://www.elastic.co/guide/en/kibana/current/docker.html
[ls-docker]: https://www.elastic.co/guide/en/logstash/current/docker-config.html

[log4j-props]: https://github.com/elastic/logstash/tree/7.6/docker/data/logstash/config
[esuser]: https://github.com/elastic/elasticsearch/blob/7.6/distribution/docker/src/docker/Dockerfile#L23-L24

[upgrade]: https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-upgrade.html






"FLEET_SERVER_ENABLE=1",
                "FLEET_ENROLL=1",
                "FLEET_URL=https://fleet-server:8220",
                "FLEET_CA=/usr/share/elastic-agent/certificates/ca/ca.crt",
                "FLEET_SERVER_ELASTICSEARCH_PASSWORD=JcRZwmwBPduguAuv",
                "FLEET_SERVER_ELASTICSEARCH_HOST=https://elasticsearch:9200",
                "FLEET_SERVER_ELASTICSEARCH_CA=/usr/share/elastic-agent/certificates/ca/ca.crt",
                "FLEET_SERVER_CERT=/usr/share/elastic-agent/certificates/fleet-server/fleet-server.crt",
                "FLEET_SERVER_CERT_KEY=/usr/share/elastic-agent/certificates/fleet-server/fleet-server.key",
                "CERTIFICATE_AUTHORITIES=/usr/share/elastic-agent/certificates/ca/ca.crt",
                "KIBANA_FLEET_SETUP=1",
                "KIBANA_HOST=http://kibana:5601",
                "KIBANA_PASSWORD=JcRZwmwBPduguAuv",
                "ELASTICSEARCH_PASSWORD=JcRZwmwBPduguAuv",
                "ELATICSEARCH_CA=/usr/share/elastic-agent/certificates/ca/ca.crt",
                "FLEET_SERVER_POLICY_ID=default-policy",
                "PATH=/usr/share/elastic-agent:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "BEAT_SETUID_AS=elastic-agent",
                "ELASTIC_CONTAINER=true",
                "GODEBUG=madvdontneed=1",
                "LIBBEAT_MONITORING_CGROUPS_HIERARCHY_OVERRIDE=/"