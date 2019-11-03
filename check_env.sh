#!/usr/bin/env bash

if [[ -z "$GRL_AWS_LAB_BUILDS_S3_BUCKET" ]]; then
    echo "Must provide S3 bucket name in GRL_AWS_LAB_BUILDS_S3_BUCKET environment variable" 1>&2
    exit 1
fi

aws configure list

echo 
echo "GRL_AWS_LAB_BUILDS_S3_BUCKET=$GRL_AWS_LAB_BUILDS_S3_BUCKET"
echo 

read -p "Check profile, region and environment! Do you want to proceed (y/n)? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi