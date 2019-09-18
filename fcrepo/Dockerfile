FROM alpine:3.10.2

ENV JETTY_VER=9.4.20.v20190813
ENV JETTY_BIN=https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${JETTY_VER}/jetty-distribution-${JETTY_VER}.tar.gz
ENV JETTY_PORT=8080
ENV FEDORA_VER=5.1.0
ENV FEDORA_BIN=https://github.com/fcrepo4/fcrepo4/releases/download/fcrepo-${FEDORA_VER}/fcrepo-webapp-${FEDORA_VER}.war

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

ADD fcrepo-realm.xml fcrepo-realm.properties etc/

ADD fcrepo.ini start.d/

COPY init-fedora.sh /

COPY namespaces.yml webapps/fcrepo/WEB-INF/classes/

VOLUME /data

EXPOSE ${JETTY_PORT}

CMD [ "/init-fedora.sh" ]