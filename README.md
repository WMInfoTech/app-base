# Banner 9 Self Service Base

Banner 9 Self Service Base is a base image to build the Banner 9 self service application on
top of.

The intent is that images built on this base will be portable across production, test, and
development instance of your install. We attempt to set everything required by Tomcat, and
some settings that are contained in your war file, typically those found in xml files.

If a setting exists in a groovy file, we suggest you have Groovy fetch an environment
variable that's set by your container orchestrator.

## Image Variations

We have build files for an alpine and a Debian slim based release. Alpine is smaller, but
likely doesn't have an up to date version of OpenJDK ready to use.

## How to use

Copy extracted war files to `/usr/local/tomcat/webapps/`, where application.war becomes
`webapps/application`. Copy groovy files to whatever location you've configured your war
file to use.

A Dockerfile might look like
```Dockerfile
FROM app-base

COPY --chown=tomcat:tomcat application /usr/local/tomcat/webapps/application/
COPY *.groovy /app_config/
```

Properties used by Tomcat can be loaded from environment variables or files
(typically provided by your orchestrator as configs or secrets). The settings
required by Tomcat for JNDI connections are appended to catalina.properties before Tomcat starts.

If you don't set something, the default values from the Dockerfile are used.

### Environment Variable Defaults

```shell
TIMEZONE -  default: America/New_York
XMS - default: 2g
XMX - default: 4g
BANNERDB_JDBC - default: jdbc:oracle:thin:@//oracle.example.edu:1521/prod
BANPROXY_USERNAME - default: banproxy
BANPROXY_PASSWORD - no default
BANPROXY_INITALSIZE - default: 25
BANPROXY_MAXTOTAL - default: 400
BANPROXY_MAXIDLE - default: -1
BANPROXY_MAXWAIT - default: 30000  
BANSSUSER_USERNAME - default: ban_ss_user
BANSSUSER_PASSWORD - no default
BANSSUSER_INITALSIZE - default: 25
BANSSUSER_MAXTOTAL - default: 400
BANSSUSER_MAXIDLE - default: -1
BANSSUSER_MAXWAIT - default: 30000
REMOVE_ABANDONED_ON_MAINTENANCE - default: true
REMOVE_ABANDONED_ON_BORROW - default: true
REMOVE_ABANDONED_TIMEOUT - default: 2100
LOG_ABANDONED - default: true
CAS_URL - default: https://cas.local.com/cas
BANNER9_URL - default: https://banner9.school.edu
```

### Loading Properties from Config file

When loading from a config file, set the environment variable `CONFIG_FILE` to the location
of the configuration file, from there all other environment variables will be ignored by run.sh,
but can be used by your custom application config files.

```shell
bannerdb.jdbc = jdbc:oracle:thin:@//oracle.example.edu:1521/prod
banproxy.username = banproxy
banproxy.username = password
banproxy.initialsize = 25
banproxy.maxtotal = 400
banproxy.maxidle = -1
banproxy.maxwait = 30000
banssuser.username = ban_ss_user
banssuser.password = password
banssuser.initialsize = 25
banssuser.maxtotal = 400
banssuser.maxidle = -1
banssuser.maxwait = 30000
remove.abandoned.on.maintenance = true
remove.abandoned.on.borrow = true
remove.abandoned.timeout = 2100
log.abandoned = true
cas.url = https://cas.local.com/cas
banner9.url = https://banner9.school.edu
```

## Monitoring

JMX can be enabled by setting the `JMX_PORT` environment variable.

### Prometheus

If you'd prefer to directly expose metrics in a format that Prometheus
can scrape, set the `PROMETHEUS_JMX_PORT` environment variable to the
port number you'd like for the
[JMX exporter](https://github.com/prometheus/jmx_exporter) to listen on.

The [example tomcat config file](https://github.com/prometheus/jmx_exporter/blob/master/example_configs/tomcat.yml)
is included in the image, but it can over overriden by setting the
`JMX_EXPORTER_CONFIG` environment variable to the location of the config
file you'd like to use.