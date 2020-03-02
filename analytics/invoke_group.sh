#!/usr/bin/env bash
usage_text='
Usage:
./invoke_group.sh NUMBER_OF_REQUESTS

For example:
./invoke_group.sh 10
'

set -eo pipefail

.././check_env.sh

count=1
re='^[0-9]+$'

if [ $# -gt 1 ]; then
  echo "Incorrect number of arguments supplied"
  echo "$usage_text"
  exit 1
fi
if [ $# -eq 1 ]; then
  count=$1
fi
if ! [[ $count =~ $re ]]; then
  echo "Argument 1 should be number"
  echo "$usage_text"
  exit 1
fi

echo
echo "-------------------------------------------------------"
echo " Invoking group of functions in a loop                 "
echo "-------------------------------------------------------"

for i in $( seq 1 "$count" ); do

    payload='{"name": "Comsysto '"$i"'", "greeting": "Hello"}'

    name="grl-aws-java-basic-256"

    echo -e "\nInvoking $name function. Try $i.\n"
    aws lambda invoke --function-name $name --payload "$(echo "$payload" | base64)" out1 --log-type Tail --query 'LogResult' --output text |  base64 --decode

    name="grl-aws-graalvm-ce-256"

    echo -e "\nInvoking $name function. Try $i.\n"
    aws lambda invoke --function-name $name --payload "$(echo "$payload" | base64)" out2 --log-type Tail --query 'LogResult' --output text |  base64 --decode

    name="grl-aws-quarkus-basic-256"

    echo -e "\nInvoking $name function. Try $i.\n"
    aws lambda invoke --function-name $name --payload "$(echo "$payload" | base64)" out3 --log-type Tail --query 'LogResult' --output text |  base64 --decode

    name="grl-aws-quarkus-native-256"

    echo -e "\nInvoking $name function. Try $i.\n"
    aws lambda invoke --function-name $name --payload "$(echo "$payload" | base64)" out4 --log-type Tail --query 'LogResult' --output text |  base64 --decode

done
