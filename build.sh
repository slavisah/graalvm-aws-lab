#!/usr/bin/env bash

set -eo pipefail

if ! hash native-image 2>/dev/null
then
    echo "'native-image' was not found in PATH"
    exit
fi

scriptdir=$(cd "$(dirname "$0")" || exit; pwd)
echo "Running in $scriptdir"
packagedir="$scriptdir/target"
rm -rf "$packagedir"
mkdir "$packagedir"

(cd "$scriptdir/grl-aws-java-basic" &&
mvn clean package &&
cp "$scriptdir/grl-aws-java-basic/target/grl-aws-java-basic-0.0.1-SNAPSHOT.jar" "$packagedir/grl-aws-java-basic.jar"
)

(cd "$scriptdir/grl-aws-quarkus" &&
mvn clean install &&
cp "$scriptdir/grl-aws-quarkus/target/grl-aws-quarkus-0.0.1-SNAPSHOT-runner.jar" "$packagedir/grl-aws-quarkus-basic.jar"
)

./build-native-in-docker.sh