FROM alpine:3.10.2

ENV JETTY_VER=9.4.20.v20190813
ENV JETTY_BIN=https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${JETTY_VER}/jetty-distribution-${JETTY_VER}.tar.gz
ENV FCREPO_JETTY_PORT=8080
ENV FEDORA_VER=5.1.0
ENV FEDORA_BIN=https://github.com/fcrepo4/fcrepo4/releases/download/fcrepo-${FEDORA_VER}/fcrepo-webapp-${FEDORA_VER}.war
ENV JSONLD_ADDON_VERSION=0.0.6 \
COMPACTION_URI=https://oa-pass.github.io/pass-data-model/src/main/resources/context-3.4.jsonld \
JSONLD_STRICT=true \
JSONLD_CONTEXT_PERSIST=true \
JSONLD_CONTEXT_MINIMAL=true

ADD pom.xml /

ADD src/ /src/

RUN apk add --no-cache openjdk8-jre openjdk8 && \
    wget -O jetty.tar.gz ${JETTY_BIN} && \
    tar -xzf jetty.tar.gz && \
    rm -rf jetty.tar.gz && \
    cd jetty-distribution-${JETTY_VER}/webapps && \
    wget -O fcrepo.war ${FEDORA_BIN} && \
    mkdir fcrepo && \
    cd fcrepo && \
    /usr/lib/jvm/java-1.8-openjdk/bin/jar -xf ../fcrepo.war && \
    cd ../ && \
    rm fcrepo.war && \
    cd .. / && \
    mkdir /data && \
    cd / && \
    apk add --no-cache maven && \
    mvn package && \
    cp target/jetty-shib-loginservice-0.0.1-SNAPSHOT.jar / && \
    rm -rf target && \
    apk del openjdk8 && \
    apk del maven && \
    rm -rf ~/.m2

WORKDIR /jetty-distribution-${JETTY_VER}

RUN wget -O webapps/fcrepo/WEB-INF/lib/jsonld-addon-filters-${JSONLD_ADDON_VERSION}-shaded.jar \
        http://central.maven.org/maven2/org/dataconservancy/fcrepo/jsonld-addon-filters/${JSONLD_ADDON_VERSION}/jsonld-addon-filters-${JSONLD_ADDON_VERSION}-shaded.jar && \
    echo "53883365d715e64bf55ec0e433a2266f9374254e *webapps/fcrepo/WEB-INF/lib/jsonld-addon-filters-${JSONLD_ADDON_VERSION}-shaded.jar" \
        | sha1sum -c -

COPY fedora-env.sh /

COPY init-fedora.sh /

COPY run_tests.sh /

COPY web.xml webapps/fcrepo/WEB-INF/

COPY fcrepo-config.xml webapps/fcrepo/WEB-INF/classes/spring

COPY fcrepo.xml webapps/

# Fedora basic auth users and roles
ADD fcrepo-realm.properties etc/

# See https://www.eclipse.org/jetty/documentation/9.4.x/startup-modules.html#start-vs-startd
RUN mv /jetty-shib-loginservice-0.0.1-SNAPSHOT.jar lib/ext && \
    java -jar ./start.jar --create-startd && \
    java -jar ./start.jar --add-to-start=http-forwarded

# when true, enables the debug,debuglog Jetty modules at *build*
ARG ENABLE_CONTAINER_DEBUG=false

RUN if [ "${ENABLE_CONTAINER_DEBUG}" = "true" ] ; then \
 java -jar ./start.jar --add-to-start=debug,debuglog ; \
 fi

ADD fcrepo.ini start.d/

VOLUME /data

EXPOSE ${FCREPO_JETTY_PORT}

CMD [ "/init-fedora.sh" ]

