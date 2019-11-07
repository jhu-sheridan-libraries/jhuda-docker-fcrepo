#!/bin/ash

#set -vx

source /fedora-env.sh

echo "fcrepo container environment:"
env | sort -u

if [ ! -d ${FCREPO_DATA_DIR} ] ;
then
  mkdir -p ${FCREPO_DATA_DIR}
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