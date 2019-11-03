#!/usr/bin/env bash

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
) || exit

(cd "$scriptdir/grl-aws-graalvm-ce" && rm -rf target && mkdir target && cd target &&
native-image --enable-url-protocols=http \
            -Djava.net.preferIPv4Stack=true \
            -H:ReflectionConfigurationFiles="$scriptdir/grl-aws-graalvm-ce/reflect.json" \
            -H:+ReportUnsupportedElementsAtRuntime \
            --no-server \
            -jar "$scriptdir/grl-aws-java-basic/target/grl-aws-java-basic-0.0.1-SNAPSHOT.jar" \
            -H:Name=grl-aws-graalvm-ce
) || exit

zip -j "$packagedir/grl-aws-graalvm-ce.zip" "$scriptdir/grl-aws-graalvm-ce/bootstrap" "$scriptdir/grl-aws-graalvm-ce/target/grl-aws-graalvm-ce"

(cd "$scriptdir/grl-aws-quarkus" &&
mvn clean install &&
cp "$scriptdir/grl-aws-quarkus/target/grl-aws-quarkus-0.0.1-SNAPSHOT-runner.jar" "$packagedir/grl-aws-quarkus-basic.jar"
) || exit

(cd "$scriptdir/grl-aws-quarkus" &&
mvn clean install -Dnative &&
cp "$scriptdir/grl-aws-quarkus/target/function.zip" "$packagedir/grl-aws-quarkus-native.zip"
) || exit