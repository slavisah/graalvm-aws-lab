#!/usr/bin/env bash

scriptdir=$(cd "$(dirname "$0")" || exit; pwd)
echo "Running in $scriptdir"
packagedir="$scriptdir/target"

(cd "$packagedir" || { echo "Making the target/ folder!"; mkdir "$packagedir"; })

cd "$scriptdir/grl-aws-graalvm-ce" && rm -rf target && mkdir target && cd target &&
native-image --allow-incomplete-classpath \
            --enable-url-protocols=http \
            -Djava.net.preferIPv4Stack=true \
            --report-unsupported-elements-at-runtime \
            --initialize-at-build-time \
            --no-server \
            -jar "$scriptdir/grl-aws-java-basic/target/grl-aws-java-basic-0.0.1-SNAPSHOT.jar" \
            -H:Name=grl-aws-graalvm-ce \
            -H:ReflectionConfigurationFiles=/working/grl-aws-graalvm-ce/reflect.json

zip -j "$packagedir/grl-aws-graalvm-ce.zip" "$scriptdir/grl-aws-graalvm-ce/bootstrap" "$scriptdir/grl-aws-graalvm-ce/target/grl-aws-graalvm-ce"

(cd "$scriptdir/grl-aws-quarkus" &&
mvn clean install -Dnative &&
cp "$scriptdir/grl-aws-quarkus/target/function.zip" "$packagedir/grl-aws-quarkus-native.zip"
)