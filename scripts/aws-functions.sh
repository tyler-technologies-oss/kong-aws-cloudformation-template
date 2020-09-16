#!/bin/bash

verifyStackNameParam() {
  if [ "$#" -ne 1 ]; then
      echo "Usage: $0 StackName"
      exit 1
  fi
}

getStackIdFromName() {
  echo `aws cloudformation describe-stacks --stack-name $1 --query "Stacks[*].StackId" --output text`
}

getChildStackNameFromResourceType() {
  echo `aws cloudformation describe-stacks --query "Stacks[?ParentId=='$1' && Tags[?Key=='resources'].Value==['$2']].StackName" --output text `
}

getOutputValueFromStack() {
  echo `aws cloudformation describe-stacks --stack-name $1 --query "Stacks[*].Outputs[?OutputKey=='$2'].OutputValue" --output text`
}

getStackASGPublicIPs() {
  echo `aws ec2 describe-instances --filters Name=instance-state-name,Values=running Name=tag:aws:cloudformation:stack-name,Values=$1 Name=tag:aws:cloudformation:logical-id,Values=$2 --query "Reservations[*].Instances[].PublicIpAddress" --output text`
}

getStackASGPrivateIPs() {
  echo `aws ec2 describe-instances --filters Name=instance-state-name,Values=running Name=tag:aws:cloudformation:stack-name,Values=$1 Name=tag:aws:cloudformation:logical-id,Values=$2 --query "Reservations[*].Instances[].PrivateIpAddress" --output text`
}

getHostedZoneByDNSName() {
  echo `aws route53 list-hosted-zones-by-name --dns-name $1 --query "HostedZones[*].Id" --output text`
}

getRecordInHostedZone() {
  echo `aws route53 list-resource-record-sets --hosted-zone-id $1 --query "ResourceRecordSets[?Name=='$2.'].{Name:Name, Value:ResourceRecords[0].Value}" --output text`
}

getStackResourceIdByName() {
  echo `aws cloudformation list-stack-resources --stack-name $i --query "StackResourceSummaries[?LogicalResourceId=='$2'].PhysicalResourceId" --output text`
}

removeDeleteProtectionFromDBCluster() {
  echo `aws rds modify-db-cluster --db-cluster-identifier $1 --no-deletion-protection`
}

addDeleteProtectionToDBCluster() {
  echo `aws rds modify-db-cluster --db-cluster-identifier $1 --deletion-protection`
}