# Fedora Image

Provides the Fedora repository image used by the JHU Data Archive.  Notably the image adds:
 * servlet filters enhancing Fedora's capablity with respect to interacting with JSON-LD.
 * custom Spring context which supports authorization
 * custom Jetty `Authenticator` stack supporting Shibboleth and Basic Auth 

## Status
![Automated Build](https://img.shields.io/docker/cloud/automated/jhuda/fcrepo) ![Build Status](https://img.shields.io/docker/cloud/build/jhuda/fcrepo)

## Locations
* [Docker Hub](https://hub.docker.com/r/jhuda/fcrepo/tags) 
* [Dockerfile](Dockerfile)
* [Build History](https://hub.docker.com/r/jhuda/fcrepo/builds)

## Environment Variables

|Description|Variable|Default Value| 
|---|---|---|   
|Port used by Jetty at runtime|`FCREPO_JETTY_PORT`|`8080`|
|The Fedora REST API endpoint (must be updated if `FCREPO_JETTY_PORT` changes)| `FCREPO_BASE_URI`|`http://localhost:8080/fcrepo/rest`|
|REST API username|`FCREPO_USER`|`fedoraAdmin`|
|REST API password|`FCREPO_PASS`|`moo`|
|Base directory containing Fedora repository assets|`FCREPO_DATA_DIR`|`/data/fcrepo`|
|Default log level for Fedora|`FCREPO_LOGLEVEL`|`DEBUG`|
|Modeshape configuration file (a Spring Resource URI)|`FCREPO_MODESHAPE_CONFIG`|`classpath:/config/file-simple/repository.json`|
|Shibboleth SP HTTP header containing the authenticated username|`FCREPO_AUTH_HEADER`|`REMOTE_USER`|
|Role(s) assigned to Shibboleth authentiated users (CSV string)|`FCREPO_AUTH_ROLES`|`fedoraUser`|
|Default log level for Fedora authentication|`FCREPO_AUTH_LOGLEVEL`|`DEBUG`|

## Build Arguments

|Description|Variable|Default Value| 
|---|---|---| 
|Enables the `debug` and `debuglog` Jetty modules when `true`|`ENABLE_CONTAINER_DEBUG`|`false`|

