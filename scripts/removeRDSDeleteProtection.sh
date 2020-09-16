#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd "$SCRIPTPATH"
source aws-functions.sh

verifyStackNameParam $1

STACK_ID=`getStackIdFromName $1`
KONG_DB_STACK_ID=`getChildStackNameFromResourceType $STACK_ID 'kong-db'`
CTL_DB_STACK_ID=`getChildStackNameFromResourceType $STACK_ID 'collector-db'`

STACK_ARRAY=( $KONG_DB_STACK_ID $CTL_DB_STACK_ID )

for i in ${STACK_ARRAY[@]}; do
  DB=`getStackResourceIdByName $i 'PostgresDB'`
  removeDeleteProtectionFromDBCluster $DB
done

