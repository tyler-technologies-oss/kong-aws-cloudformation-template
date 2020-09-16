#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd "$SCRIPTPATH"
source aws-functions.sh

verifyStackNameParam $1

STACK_ID=`getStackIdFromName $1`
BASTION_STACK_ID=`getChildStackNameFromResourceType $STACK_ID 'bastion'`
KONG_STACK_ID=`getChildStackNameFromResourceType $STACK_ID 'kong'`
PGB_STACK_ID=`getChildStackNameFromResourceType $STACK_ID 'pgbouncer'`

BASTION_IP=`getStackASGPublicIPs $BASTION_STACK_ID 'BastionAutoScalingGroup'`
KONG_NODE_IPS=`getStackASGPrivateIPs $KONG_STACK_ID 'KongScalingGroup'`
CTL_NODE_IPS=`getStackASGPrivateIPs $KONG_STACK_ID 'CollectorScalingGroup'`
PGB_NODE_IPS=`getStackASGPrivateIPs $PGB_STACK_ID 'ScalingGroup'`

function getSSHHost()
{
  local HOST='
Host '$1'
  HostName '$2'
  IdentityFile ~/.ssh/<ec2_key_pair_name>.pem
  StrictHostKeyChecking no
  User ec2-user
  Port 22'

  if [ "$3" == "true" ]; then
  HOST=$HOST'
  ProxyJump lb'
  fi

  echo "$HOST"
}

SSH_CONF=`getSSHHost lb $BASTION_IP 'false'`

IDX=1
for IP in $KONG_NODE_IPS; do
  KONG_HOST=`getSSHHost 'kong'$IDX $IP 'true'`
  SSH_CONF=$SSH_CONF$KONG_HOST
  let IDX=$IDX+1
done

IDX=1
for IP in $CTL_NODE_IPS; do
  CTL_HOST=`getSSHHost 'ctl'$IDX $IP 'true'`
  SSH_CONF=$SSH_CONF$CTL_HOST
  let IDX=$IDX+1
done

IDX=1
for IP in $PGB_NODE_IPS; do
  CTL_HOST=`getSSHHost 'pgb'$IDX $IP 'true'`
  SSH_CONF=$SSH_CONF$CTL_HOST
  let IDX=$IDX+1
done

echo -e "$SSH_CONF"
