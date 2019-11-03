#!/usr/bin/env bash

set -eo pipefail

./check_env.sh

s3bucket=$GRL_AWS_LAB_BUILDS_S3_BUCKET

echo "-------------------------------------------------------"
echo " Updating function code from S3 bucket                 "
echo "-------------------------------------------------------"

echo 
echo "Updating grl-aws-java-basic-256 function from S3 bucket."
aws lambda update-function-code --function-name grl-aws-java-basic-256 \
           --s3-bucket "$s3bucket" --s3-key "grl-aws-java-basic.jar"
echo 
echo "Updating grl-aws-graalvm-ce-256 function from S3 bucket."
aws lambda update-function-code --function-name grl-aws-graalvm-ce-256 \
           --s3-bucket "$s3bucket" --s3-key "grl-aws-graalvm-ce.zip"

echo 
echo "Updating grl-aws-quarkus-basic-256 function from S3 bucket."
aws lambda update-function-code --function-name grl-aws-quarkus-basic-256 \
           --s3-bucket "$s3bucket" --s3-key "grl-aws-quarkus-basic.jar"
echo 
echo "Updating grl-aws-quarkus-native-256 function from S3 bucket."
aws lambda update-function-code --function-name grl-aws-quarkus-native-256 \
           --s3-bucket "$s3bucket" --s3-key "grl-aws-quarkus-native.zip"