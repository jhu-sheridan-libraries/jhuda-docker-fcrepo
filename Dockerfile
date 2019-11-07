FROM maven:3.6.2-jdk-8-slim

ADD jetty-shib-authenticator /jetty-shib-authenticator

RUN cd /jetty-shib-authenticator && \
    mvn package

FROM openjdk:8-jdk-slim

ENV JETTY_VER=9.4.20.v20190813
ENV JETTY_BIN=https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${JETTY_VER}/jetty-distribution-${JETTY_VER}.tar.gz
ENV FEDORA_VER=5.1.0
ENV FEDORA_BIN=https://github.com/fcrepo4/fcrepo4/releases/download/fcrepo-${FEDORA_VER}/fcrepo-webapp-${FEDORA_VER}.war

RUN apt-get update && \
    apt-get install -y curl && \
    curl -Lo jetty.tar.gz ${JETTY_BIN} && \
    tar -xzf jetty.tar.gz && \
    rm -rf jetty.tar.gz && \
    cd jetty-distribution-${JETTY_VER}/webapps && \
    curl -Lo fcrepo.war ${FEDORA_BIN} && \
    mkdir fcrepo && \
    cd fcrepo && \
    jar -xf ../fcrepo.war && \
    cd ../ && \
    rm fcrepo.war

FROM alpine:3.10.2

ENV JETTY_VER=9.4.20.v20190813
ENV FCREPO_JETTY_PORT=8080
ENV JSONLD_ADDON_VERSION=0.0.6 \
    COMPACTION_URI=https://oa-pass.github.io/pass-data-model/src/main/resources/context-3.4.jsonld \
    JSONLD_STRICT=true \
    JSONLD_CONTEXT_PERSIST=true \
    JSONLD_CONTEXT_MINIMAL=true
ENV FCREPO_BASE_URI=http://localhost:8080/fcrepo/rest \
    FCREPO_USER=fedoraAdmin \
    FCREPO_PASS=moo \
    FCREPO_DATA_DIR=/data/fcrepo \
    FCREPO_SP_AUTH_HEADER=REMOTE_USER \
    FCREPO_SP_AUTH_ROLES=fedoraUser \
    FCREPO_AUTH_REALM=fcrepo \
    FCREPO_AUTH_LOGLEVEL=DEBUG \
    FCREPO_MODESHAPE_CONFIG=classpath:/config/file-simple/repository.json \
    FCREPO_LOGLEVEL=DEBUG

COPY --from=1 /jetty-distribution-${JETTY_VER}/ /jetty-distribution-${JETTY_VER}/

COPY --from=0 /jetty-shib-authenticator/target/jetty-shib-authenticator-0.0.1-SNAPSHOT.jar /jetty-distribution-${JETTY_VER}/lib/ext

WORKDIR /jetty-distribution-${JETTY_VER}

RUN wget -O webapps/fcrepo/WEB-INF/lib/jsonld-addon-filters-${JSONLD_ADDON_VERSION}-shaded.jar \
        http://central.maven.org/maven2/org/dataconservancy/fcrepo/jsonld-addon-filters/${JSONLD_ADDON_VERSION}/jsonld-addon-filters-${JSONLD_ADDON_VERSION}-shaded.jar && \
    echo "53883365d715e64bf55ec0e433a2266f9374254e *webapps/fcrepo/WEB-INF/lib/jsonld-addon-filters-${JSONLD_ADDON_VERSION}-shaded.jar" \
        | sha1sum -c -

COPY fedora-env.sh /

COPY init-fedora.sh /

COPY run_tests.sh /

COPY web.xml webapps/fcrepo/WEB-INF/

# Fedora Spring context with the optional headerProvider enabled
COPY fcrepo-config.xml webapps/fcrepo/WEB-INF/classes/spring

# Context descriptor configuring Fedora's custom authentication stack
COPY fcrepo.xml webapps/

# Fedora basic auth users and roles
ADD fcrepo-realm.properties etc/

# See https://www.eclipse.org/jetty/documentation/9.4.x/startup-modules.html#start-vs-startd
RUN apk add --no-cache openjdk8-jre && \
    java -jar ./start.jar --create-startd && \
    java -jar ./start.jar --add-to-start=http-forwarded

# when true, enables the debug,debuglog Jetty modules at *build*
ARG ENABLE_CONTAINER_DEBUG=false
RUN if [ "${ENABLE_CONTAINER_DEBUG}" = "true" ] ; then \
 java -jar ./start.jar --add-to-start=debug,debuglog ; \
 fi

RUN mkdir /data

VOLUME /data

EXPOSE ${FCREPO_JETTY_PORT}

CMD [ "/init-fedora.sh" ]

