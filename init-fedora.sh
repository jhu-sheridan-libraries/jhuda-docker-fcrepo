#!/bin/ash

#set -vx

source /fedora-env.sh

echo "fcrepo container environment:"
env | sort -u

if [ ! -d ${FCREPO_DATA_DIR} ] ;
then
  mkdir ${FCREPO_DATA_DIR}
fi

is_empty ${FCREPO_DATA_DIR}

if [ $? -eq 0 ] ;
then
  echo "Initializing Fedora..."
  apk -q --no-progress add curl
  java -jar start.jar -Djetty.http.port=${FCREPO_JETTY_PORT} 2>/dev/null 1>/dev/null &

  fedora_up 30

  if [ $? -ne 0 ] ;
  then
    echo "Exiting."
    exit 1;
  fi

  sleep 2
  apk -q del curl
  killall java
  echo "Initialization complete..."
fi

echo "Starting Fedora..."
java -jar start.jar \
  -Djetty.http.port=${FCREPO_JETTY_PORT} \
  -Dfcrepo.modeshape.configuration=${FCREPO_MODESHAPE_CONFIG} \
  -Dfcrepo.home=${FCREPO_DATA_DIR}  \
  -Dfcrepo.log=${FCREPO_LOGLEVEL} \
  -Dfcrepo.log.auth=${FCREPO_AUTH_LOGLEVEL} \
  -Djhuda.fcrepo.authheader=${FCREPO_SP_AUTH_HEADER} \
  -Djhuda.fcrepo.roles=${FCREPO_SP_AUTH_ROLES} \
  -Djhuda.fcrepo.authrealm=${FCREPO_AUTH_REALM}