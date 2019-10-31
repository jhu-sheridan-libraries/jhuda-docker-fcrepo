# Fedora Image

Provides the Fedora repository image used by the JHU Data Archive.  Notably the image adds servlet filters enhancing Fedora's capablity with respect to interacting with JSON-LD.

## Status
![Automated Build](https://img.shields.io/docker/cloud/automated/jhuda/fcrepo) ![Build Status](https://img.shields.io/docker/cloud/build/jhuda/fcrepo)

## Locations
* [Docker Hub](https://hub.docker.com/r/jhuda/fcrepo/tags) 
* [Dockerfile](Dockerfile)
* [Build History](https://hub.docker.com/r/jhuda/fcrepo/builds)

## Environment Variables

|Description|Variable|Default Value| 
|---|---|---|   
|Port used by Jetty at runtime|`JETTY_PORT`|`8080`|
|The Fedora REST API endpoint (must be updated if `JETTY_PORT` changes)| `FCREPO_BASE_URI`|`http://localhost:8080/fcrepo/rest`|
|REST API username|`FCREPO_USER`|`fedoraAdmin`|
|REST API password|`FCREPO_PASS`|`moo`|
|Base directory containing Fedora repository assets|`FCREPO_DATA_DIR`|`/data/fcrepo`|
