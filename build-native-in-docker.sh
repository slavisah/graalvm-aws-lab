#!/usr/bin/env bash

scriptdir=$(cd "$(dirname "$0")" || exit; pwd)
echo "Running in $scriptdir"
packagedir="$scriptdir/target"

cd "$packagedir" || { echo "Making the target/ folder!"; mkdir "$packagedir"; }

image_name="grl-aws-build"

docker build -t "$image_name" "$scriptdir"

docker run --rm --name grl-aws-build-container --volume "$scriptdir":/working -it "$image_name":latest \
    /bin/bash -c "(cd working/grl-aws-graalvm-ce && rm -rf target && mkdir target && cd target &&
        source ~/.sdkman/bin/sdkman-init.sh &&
        native-image --enable-url-protocols=http \
                    -Djava.net.preferIPv4Stack=true \
                    -H:ReflectionConfigurationFiles=/working/grl-aws-graalvm-ce/reflect.json \
                    -H:+ReportUnsupportedElementsAtRuntime \
                    --no-server \
                    -jar /working/grl-aws-java-basic/target/grl-aws-java-basic-0.0.1-SNAPSHOT.jar \
                    -H:Name=grl-aws-graalvm-ce)"

zip -j "$packagedir/grl-aws-graalvm-ce.zip" "$scriptdir/grl-aws-graalvm-ce/bootstrap" "$scriptdir/grl-aws-graalvm-ce/target/grl-aws-graalvm-ce"

docker run --rm --name grl-aws-build-container --volume "$scriptdir":/working -it "$image_name":latest \
    /bin/bash -c "source ~/.sdkman/bin/sdkman-init.sh && \
        cd /grl-aws-quarkus/ && \
        mvn clean install -Dnative && \
        cp /grl-aws-quarkus/target/function.zip /working/target/grl-aws-quarkus-native.zip"