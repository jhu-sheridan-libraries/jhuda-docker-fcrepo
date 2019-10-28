#!/bin/ash

FCREPO_USER=fedoraAdmin
FCREPO_PASS=moo
FCREPO_BASE_URI=http://localhost:8080/fcrepo/rest
FCREPO_DATA_DIR=/data/fcrepo

function is_empty() {
  local DIR=$1
  local FILE_COUNT=`ls ${DIR} | wc -l | sed -e 's: ::g'`
  return ${FILE_COUNT}
}

function create_container() {
  local RESOURCE=$1
  curl -u ${FCREPO_USER}:${FCREPO_PASS} -X PUT -H "Content-Type: text/turtle" -s -o /dev/null ${FCREPO_BASE_URI}/${RESOURCE}
}

function fedora_up() {
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
    echo "Unable to verify Fedora is up."
    return 1;
  fi

  return 0;
}