#!/bin/bash
set -x

if [ -z "$MONGO_PRIMARY_SERVICE_HOST" ]; then
	exit 1
else
	primary=${MONGO_PRIMARY_SERVICE_HOST}
	echo $primary
fi

function initiate_rs() {
   sleep 5
   mongo --eval "printjson(rs.initiate())"
}

function add_rs_member() {
  sleep 5
  while true; do
    ismaster=$(mongo --host ${primary} --port 27017 --eval "printjson(db.isMaster())" | grep -o true)
    if [[ "$ismaster" == "true" ]]; then
	mongo --host ${primary} --port 27017 --eval "printjson(rs.add('$POD_IP:27017'))"
    else
	primary=$(find_master)
	mongo --host ${primary} --port 27017 --eval "printjson(rs.add('$POD_IP:27017'))"
    fi
    if [[ "$?" == "0" ]]; then
      break
    fi
    echo "Connecting to primary failed.  Waiting..."
    sleep 10
  done
}

function find_master() {
    master=$(mongo --host ${primary} --port 27017 --eval "printjson(db.isMaster())" | grep  primary | cut -d"\"" -f4 | cut -d":" -f1)
    echo $master
    return $master
}

if [[ $PRIMARY == "true" ]]; then
	initiate_rs &
else
	add_rs_member &
fi

/entrypoint.sh $@
