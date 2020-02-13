####
# This Dockerfile is used in order to build a container that runs the Quarkus application in JVM mode
####

# Stage 1 : build with maven builder image with native capabilities
FROM quay.io/quarkus/centos-quarkus-maven:19.3.1-java8 AS build
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app
USER root
RUN chown -R quarkus /usr/src/app
USER quarkus
RUN mvn -f /usr/src/app/pom.xml clean package

## Stage 2 : create the oci final image
FROM registry.redhat.io/openjdk/openjdk-8-rhel8:1.2-2
COPY --from=build /usr/src/app/target/**-runner.jar /deployments/
EXPOSE 8080
