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
    apk del openjdk8 && \
    mkdir start.d && \
    mkdir /data

WORKDIR /jetty-distribution-${JETTY_VER}

RUN wget -O webapps/fcrepo/WEB-INF/lib/jsonld-addon-filters-${JSONLD_ADDON_VERSION}-shaded.jar \
        http://central.maven.org/maven2/org/dataconservancy/fcrepo/jsonld-addon-filters/${JSONLD_ADDON_VERSION}/jsonld-addon-filters-${JSONLD_ADDON_VERSION}-shaded.jar && \
    echo "53883365d715e64bf55ec0e433a2266f9374254e *webapps/fcrepo/WEB-INF/lib/jsonld-addon-filters-${JSONLD_ADDON_VERSION}-shaded.jar" \
        | sha1sum -c -

ADD fcrepo-realm.xml fcrepo-realm.properties etc/

ADD fcrepo.ini start.d/

COPY fedora-env.sh /

COPY init-fedora.sh /

COPY run_tests.sh /

COPY web.xml webapps/fcrepo/WEB-INF/

COPY fcrepo-config.xml webapps/fcrepo/WEB-INF/classes/spring

VOLUME /data

EXPOSE ${FCREPO_JETTY_PORT}

CMD [ "/init-fedora.sh" ]

