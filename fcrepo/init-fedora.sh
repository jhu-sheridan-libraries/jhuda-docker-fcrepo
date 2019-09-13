#!/bin/ash

#set -vx

FCREPO_USER=fedoraAdmin
FCREPO_PASS=moo
FCREPO_BASE_URI=http://localhost:8080/fcrepo/rest
FCREPO_DATA_DIR=/data/fcrepo
BUNDLES_RELATIVE_URI=bundles

function is_empty() {
  local DIR=$1
  local FILE_COUNT=`ls ${DIR} | wc -l | sed -e 's: ::g'`
  return ${FILE_COUNT}
}

function create_container() {
  local RESOURCE=$1
  curl -u ${FCREPO_USER}:${FCREPO_PASS} -X PUT -H "Content-Type: text/turtle" -s -o /dev/null ${FCREPO_BASE_URI}/${RESOURCE}
}

if [ ! -d ${FCREPO_DATA_DIR} ] ;
then
  mkdir ${FCREPO_DATA_DIR}
fi

is_empty ${FCREPO_DATA_DIR}

if [ $? -eq 0 ] ;
then
  echo "Initializing Fedora..."
  apk -q --no-progress add curl
  java -jar start.jar -Djetty.http.port=8080 2>/dev/null 1>/dev/null &

  HTTP_STATUS_CODE=0
  COUNT=0
  while [ ${HTTP_STATUS_CODE} -ne 200 ] && [ ${COUNT} -lt 10 ] ;
  do
    HTTP_STATUS_CODE=`curl -u ${FCREPO_USER}:${FCREPO_PASS} -s -o /dev/null -w %{http_code} ${FCREPO_BASE_URI}`
    let COUNT=${COUNT}+1
    sleep 4
  done

  if [ ${HTTP_STATUS_CODE} -ne 200 ] ;
  then
    echo "Unable to verify Fedora is up, exiting."
    exit 0;
  fi

  create_container ${BUNDLES_RELATIVE_URI}
  sleep 2
  apk -q del curl
  killall java
fi

java -jar start.jar -Djetty.http.port=${JETTY_PORT}