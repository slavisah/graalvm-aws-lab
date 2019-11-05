FROM centos:7
# FROM amazonlinux:2.0.20191016.0

COPY ./grl-aws-graalvm-ce /grl-aws-graalvm-ce/
COPY ./grl-aws-quarkus /grl-aws-quarkus/

RUN yum groups mark convert && yum groupinstall -y "Development Tools"
RUN yum install -y which zip unzip
RUN curl -s "https://get.sdkman.io" | bash
RUN bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && \
    sdk install java 19.2.1-grl && \
    java -version && \
    sdk install maven 3.5.4 && \
    mvn --version && \
    gu install native-image"
# installing maven dependencies, to have them cached for later runs
RUN bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && \
    cd /grl-aws-quarkus/ && \
    mvn clean install"
RUN yum install -y zlib-devel